"""
Document model with Qt integration
"""

from typing import Optional
from pathlib import Path
from PySide6.QtCore import QObject, Property, Signal, Slot

from ..buffer.piece_table import PieceTable, UndoStack, Edit
from ..syntax.tokenizer import IncrementalTokenizer


class Document(QObject):
    """
    Documento con integración Qt
    Conecta PieceTable con QML
    """

    textChanged = Signal()
    modifiedChanged = Signal(bool)
    cursorPositionChanged = Signal(int, int)  # line, column

    def __init__(self, file_path: Optional[str] = None):
        super().__init__()

        self.file_path = file_path
        self._modified = False
        self.version = 0

        # Core buffer
        initial_content = ""
        if file_path and Path(file_path).exists():
            with open(file_path, "r", encoding="utf-8") as f:
                initial_content = f.read()

        self.buffer = PieceTable(initial_content)
        self.undo_stack = UndoStack()

        # Syntax highlighting
        language = self._detect_language(file_path)
        self.tokenizer = IncrementalTokenizer(language)

        # Cursor state
        self.cursor_line = 0
        self.cursor_column = 0

    def _detect_language(self, file_path: Optional[str]) -> str:
        """Detecta lenguaje por extensión"""
        if not file_path:
            return "plaintext"

        ext = Path(file_path).suffix.lower()
        language_map = {
            ".py": "python",
            ".js": "javascript",
            ".ts": "typescript",
            ".rs": "rust",
            ".cpp": "cpp",
            ".c": "c",
            ".h": "c",
            ".hpp": "cpp",
            ".html": "html",
            ".css": "css",
            ".json": "json",
            ".yaml": "yaml",
            ".yml": "yaml",
            ".md": "markdown",
        }
        return language_map.get(ext, "plaintext")

    @Property(str, notify=textChanged)
    def text(self) -> str:
        """Obtiene todo el texto"""
        return self.buffer.get_text()

    @Property(bool, notify=modifiedChanged)
    def modified(self) -> bool:
        """Indica si el documento está modificado"""
        return self._modified

    @Slot(int, int, str)
    def insert(self, position: int, length: int, text: str):
        """Inserta texto"""
        import time

        self.buffer.insert(position, text)
        self.version += 1
        self._modified = True

        edit = Edit(position, 0, text, time.time(), self.version)
        snapshot = self.buffer.create_snapshot()
        self.undo_stack.push(edit, snapshot)

        # Marcar líneas como dirty para re-tokenización
        start_line = self.buffer.get_text()[:position].count("\n")
        end_line = start_line + text.count("\n")
        self.tokenizer.mark_dirty(start_line, end_line)

        self.textChanged.emit()
        self.modifiedChanged.emit(self._modified)

    @Slot(int, int)
    def delete(self, position: int, length: int):
        """Elimina texto"""
        import time

        deleted = self.buffer.delete(position, length)
        self.version += 1
        self._modified = True

        edit = Edit(position, length, deleted, time.time(), self.version)
        snapshot = self.buffer.create_snapshot()
        self.undo_stack.push(edit, snapshot)

        # Marcar líneas como dirty
        start_line = self.buffer.get_text()[:position].count("\n")
        self.tokenizer.mark_dirty(start_line, start_line + 1)

        self.textChanged.emit()
        self.modifiedChanged.emit(self._modified)

    @Slot()
    def undo(self):
        """Deshacer"""
        edit = self.undo_stack.undo()
        if not edit:
            return

        # Aplicar undo al buffer
        if edit.length == 0:  # Was insert
            self.buffer.delete(edit.position, len(edit.text))
        else:  # Was delete
            self.buffer.insert(edit.position, edit.text)

        self.version = edit.version - 1
        self.tokenizer.invalidate_cache()
        self.textChanged.emit()

    @Slot()
    def redo(self):
        """Rehacer"""
        edit = self.undo_stack.redo()
        if not edit:
            return

        # Aplicar redo
        if edit.length == 0:  # Was insert
            self.buffer.insert(edit.position, edit.text)
        else:  # Was delete
            self.buffer.delete(edit.position, edit.length)

        self.version = edit.version
        self.tokenizer.invalidate_cache()
        self.textChanged.emit()

    @Slot(result=bool)
    def save(self) -> bool:
        """Guarda el documento"""
        if not self.file_path:
            return False

        try:
            with open(self.file_path, "w", encoding="utf-8") as f:
                f.write(self.buffer.get_text())
            self._modified = False
            self.modifiedChanged.emit(False)
            return True
        except Exception as e:
            print(f"Save error: {e}")
            return False

    @Slot(str, result=bool)
    def save_as(self, file_path: str) -> bool:
        """Guarda con nuevo nombre"""
        self.file_path = file_path
        return self.save()
