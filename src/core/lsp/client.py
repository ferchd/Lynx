"""
Language Server Protocol client implementation
"""

import asyncio
import json
from typing import Dict, List, Optional, Any
from pathlib import Path
from PySide6.QtCore import QObject, Signal


class LSPClient(QObject):
    """
    Language Server Protocol Client
    Implementación completa del protocolo LSP
    """

    initialized = Signal()
    diagnostics_received = Signal(str, list)  # uri, diagnostics
    completion_received = Signal(list)
    hover_received = Signal(str)
    definition_received = Signal(str, int, int)  # uri, line, char

    def __init__(self, server_command: List[str], workspace_root: str):
        super().__init__()
        self.server_command = server_command
        self.workspace_root = workspace_root
        self.process = None
        self.request_id = 0
        self.pending_requests: Dict[int, asyncio.Future] = {}
        self.server_capabilities = {}

    async def start(self):
        """Inicia el servidor LSP"""
        import subprocess

        self.process = await asyncio.create_subprocess_exec(
            *self.server_command,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

        # Inicializar
        await self.initialize()
        await self.initialized_notification()

    async def initialize(self):
        """Envía initialize request"""
        response = await self.send_request(
            "initialize",
            {
                "processId": None,
                "rootUri": f"file://{self.workspace_root}",
                "capabilities": {
                    "textDocument": {
                        "completion": {"completionItem": {"snippetSupport": True}},
                        "hover": {"contentFormat": ["markdown", "plaintext"]},
                        "signatureHelp": {},
                        "definition": {},
                        "references": {},
                        "documentHighlight": {},
                        "documentSymbol": {},
                        "formatting": {},
                        "rangeFormatting": {},
                        "rename": {},
                        "publishDiagnostics": {},
                        "codeAction": {},
                    },
                    "workspace": {
                        "applyEdit": True,
                        "workspaceEdit": {"documentChanges": True},
                        "didChangeConfiguration": {},
                        "didChangeWatchedFiles": {},
                        "symbol": {},
                        "executeCommand": {},
                    },
                },
                "initializationOptions": {},
                "workspaceFolders": [
                    {
                        "uri": f"file://{self.workspace_root}",
                        "name": Path(self.workspace_root).name,
                    }
                ],
            },
        )

        self.server_capabilities = response.get("capabilities", {})
        self.initialized.emit()

    async def initialized_notification(self):
        """Envía initialized notification"""
        await self.send_notification("initialized", {})

    async def did_open(self, uri: str, language_id: str, version: int, text: str):
        """Notifica que un documento se abrió"""
        await self.send_notification(
            "textDocument/didOpen",
            {
                "textDocument": {
                    "uri": uri,
                    "languageId": language_id,
                    "version": version,
                    "text": text,
                }
            },
        )

    async def did_change(self, uri: str, version: int, changes: List[Dict]):
        """Notifica cambios en el documento"""
        await self.send_notification(
            "textDocument/didChange",
            {
                "textDocument": {"uri": uri, "version": version},
                "contentChanges": changes,
            },
        )

    async def did_save(self, uri: str, text: Optional[str] = None):
        """Notifica que se guardó el documento"""
        params = {"textDocument": {"uri": uri}}
        if text is not None:
            params["text"] = text
        await self.send_notification("textDocument/didSave", params)

    async def did_close(self, uri: str):
        """Notifica que se cerró el documento"""
        await self.send_notification(
            "textDocument/didClose", {"textDocument": {"uri": uri}}
        )

    async def completion(self, uri: str, line: int, character: int) -> List[Dict]:
        """Solicita completions"""
        response = await self.send_request(
            "textDocument/completion",
            {
                "textDocument": {"uri": uri},
                "position": {"line": line, "character": character},
            },
        )
        return (
            response.get("items", []) if isinstance(response, dict) else response or []
        )

    async def hover(self, uri: str, line: int, character: int) -> Optional[str]:
        """Solicita información de hover"""
        response = await self.send_request(
            "textDocument/hover",
            {
                "textDocument": {"uri": uri},
                "position": {"line": line, "character": character},
            },
        )

        if response and "contents" in response:
            contents = response["contents"]
            if isinstance(contents, str):
                return contents
            elif isinstance(contents, dict):
                return contents.get("value", "")
            elif isinstance(contents, list) and contents:
                return (
                    contents[0].get("value", "")
                    if isinstance(contents[0], dict)
                    else str(contents[0])
                )
        return None

    async def definition(self, uri: str, line: int, character: int) -> Optional[Dict]:
        """Solicita go to definition"""
        response = await self.send_request(
            "textDocument/definition",
            {
                "textDocument": {"uri": uri},
                "position": {"line": line, "character": character},
            },
        )

        if response:
            if isinstance(response, list) and response:
                return response[0]
            elif isinstance(response, dict):
                return response
        return None

    async def document_symbol(self, uri: str) -> List[Dict]:
        """Solicita símbolos del documento"""
        response = await self.send_request(
            "textDocument/documentSymbol", {"textDocument": {"uri": uri}}
        )
        return response or []

    async def formatting(self, uri: str) -> List[Dict]:
        """Solicita formateo del documento"""
        response = await self.send_request(
            "textDocument/formatting",
            {
                "textDocument": {"uri": uri},
                "options": {"tabSize": 4, "insertSpaces": True},
            },
        )
        return response or []

    async def send_request(self, method: str, params: Dict) -> Any:
        """Envía una request y espera respuesta"""
        self.request_id += 1
        request_id = self.request_id

        message = {
            "jsonrpc": "2.0",
            "id": request_id,
            "method": method,
            "params": params,
        }

        await self._send_message(message)

        # Crear future para esperar respuesta
        future = asyncio.Future()
        self.pending_requests[request_id] = future

        try:
            response = await asyncio.wait_for(future, timeout=30.0)
            return response.get("result")
        except asyncio.TimeoutError:
            del self.pending_requests[request_id]
            return None

    async def send_notification(self, method: str, params: Dict):
        """Envía una notificación (sin esperar respuesta)"""
        message = {"jsonrpc": "2.0", "method": method, "params": params}
        await self._send_message(message)

    async def _send_message(self, message: Dict):
        """Envía mensaje al servidor"""
        if not self.process or not self.process.stdin:
            return

        content = json.dumps(message)
        header = f"Content-Length: {len(content)}\r\n\r\n"

        self.process.stdin.write((header + content).encode("utf-8"))
        await self.process.stdin.drain()

    async def _read_messages(self):
        """Lee mensajes del servidor (debe ejecutarse en loop)"""
        if not self.process or not self.process.stdout:
            return

        while True:
            try:
                # Leer header
                header = await self.process.stdout.readuntil(b"\r\n\r\n")
                header_text = header.decode("utf-8")

                # Extraer Content-Length
                import re

                match = re.search(r"Content-Length: (\d+)", header_text)
                if not match:
                    continue

                content_length = int(match.group(1))

                # Leer contenido
                content = await self.process.stdout.readexactly(content_length)
                message = json.loads(content.decode("utf-8"))

                await self._handle_message(message)

            except asyncio.CancelledError:
                break
            except Exception as e:
                print(f"LSP read error: {e}")

    async def _handle_message(self, message: Dict):
        """Maneja mensaje recibido del servidor"""
        if "id" in message:
            # Es una respuesta a una request
            request_id = message["id"]
            if request_id in self.pending_requests:
                future = self.pending_requests.pop(request_id)
                if "error" in message:
                    future.set_exception(Exception(message["error"]))
                else:
                    future.set_result(message)

        elif "method" in message:
            # Es una notificación del servidor
            method = message["method"]
            params = message.get("params", {})

            if method == "textDocument/publishDiagnostics":
                uri = params.get("uri")
                diagnostics = params.get("diagnostics", [])
                self.diagnostics_received.emit(uri, diagnostics)
