"""
Lynx Editor - Professional IDE
Main application entry point
"""

import sys
import asyncio
from pathlib import Path
from typing import Dict, List, Optional

from PySide6.QtCore import QObject, Slot, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine, qmlRegisterType

from core.editor.document import Document
from profiles.profile_manager import ProfileManager
from core.lsp.client import LSPClient


class LynxEditor(QObject):
    """Aplicación principal del editor"""

    def __init__(self):
        super().__init__()

        self.documents: Dict[str, Document] = {}
        self.current_document: Optional[Document] = None
        self.profile_manager = ProfileManager()
        self.lsp_clients: Dict[str, LSPClient] = {}

    @Slot(str, result=QObject)
    def open_document(self, file_path: str) -> Document:
        """Abre un documento"""
        if file_path in self.documents:
            self.current_document = self.documents[file_path]
            return self.current_document

        doc = Document(file_path)
        self.documents[file_path] = doc
        self.current_document = doc

        # Iniciar LSP si es necesario
        self._start_lsp_for_document(doc)

        return doc

    @Slot(result=QObject)
    def new_document(self) -> Document:
        """Crea un nuevo documento"""
        doc = Document()
        self.current_document = doc
        return doc

    def _start_lsp_for_document(self, document: Document):
        """Inicia servidor LSP para el documento"""
        if not document.file_path:
            return

        language = document._detect_language(document.file_path)

        # Obtener comando del LSP desde el perfil actual
        if self.profile_manager.current_profile:
            lsp_command = self.profile_manager.current_profile.lsp_servers.get(language)
            if lsp_command and language not in self.lsp_clients:
                workspace = str(Path(document.file_path).parent)
                client = LSPClient(lsp_command, workspace)
                self.lsp_clients[language] = client

                # Iniciar en background
                asyncio.create_task(client.start())


def main():
    app = QGuiApplication(sys.argv)
    app.setOrganizationName("Lynx")
    app.setApplicationName("Lynx Editor")

    # Registrar tipos QML
    qmlRegisterType(Document, "Lynx", 1, 0, "Document")

    # Crear aplicación
    editor = LynxEditor()

    # Crear engine QML
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("editor", editor)
    engine.rootContext().setContextProperty("profileManager", editor.profile_manager)

    # Cargar QML principal - buscar en varias ubicaciones posibles
    qml_locations = [
        Path(__file__).parent / "ui" / "qml" / "main.qml",
        Path(__file__).parent / "main.qml",
        Path("src/ui/qml/main.qml"),
        Path("ui/qml/main.qml"),
    ]

    qml_file = None
    for location in qml_locations:
        if location.exists():
            qml_file = location
            break

    if not qml_file:
        print("Error: No se pudo encontrar main.qml en las ubicaciones:")
        for location in qml_locations:
            print(f"  - {location}")
        return -1

    print(f"Cargando QML desde: {qml_file}")
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        print("Error: No se pudieron cargar los objetos QML")
        return -1

    print("✅ Lynx Editor iniciado correctamente")
    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
