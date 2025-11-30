from PySide6.QtCore import QObject, Signal, Slot, Property
from core.models.document import Document
from pathlib import Path
from core.models.search_engine import SearchEngine


class DocumentController(QObject):
    textChanged = Signal()
    modifiedChanged = Signal(bool)

    def __init__(self, document: Document):
        super().__init__()
        self._document = document
        self._updating_from_backend = False
        self._search_engine = SearchEngine()

    @Property(str, notify=textChanged)
    def text(self) -> str:
        return self._document.buffer.get_text()

    @Property(bool, notify=modifiedChanged)
    def modified(self) -> bool:
        return self._document.modified

    @Property(str, constant=True)
    def fileName(self) -> str:
        return self._document.file_name

    @Property(str, constant=True)
    def language(self) -> str:
        return self._document.language

    @Property(bool, notify=textChanged)
    def canUndo(self) -> bool:
        return self._document.buffer.can_undo()

    @Property(bool, notify=textChanged)
    def canRedo(self) -> bool:
        return self._document.buffer.can_redo()

    # NUEVO: Sincronización completa del texto
    @Slot(str)
    def setText(self, new_text: str):
        """Reemplaza todo el texto - llamado desde QML"""
        if self._updating_from_backend:
            return

        old_text = self._document.buffer.get_text()
        if old_text == new_text:
            return

        # Reemplazar todo el buffer
        # (Ineficiente pero funcional para MVP)
        if len(old_text) > 0:
            self._document.buffer.delete(0, len(old_text))
        if len(new_text) > 0:
            self._document.buffer.insert(0, new_text)

        self._document._modified = True
        self._emit_changes()

    @Slot(int, str)
    def insert(self, position: int, text: str):
        """Inserta texto en posición específica"""
        self._document.buffer.insert(position, text)
        self._document._modified = True
        self._emit_changes()

    @Slot(int, int)
    def delete(self, position: int, length: int):
        """Elimina texto"""
        self._document.buffer.delete(position, length)
        self._document._modified = True
        self._emit_changes()

    @Slot()
    def undo(self):
        """Deshacer"""
        self._document.buffer.undo()
        self._update_text_from_backend()

    @Slot()
    def redo(self):
        """Rehacer"""
        self._document.buffer.redo()
        self._update_text_from_backend()

    @Slot(result=bool)
    def save(self) -> bool:
        """Guardar documento"""
        success = self._document.save()
        if success:
            self.modifiedChanged.emit(False)
        return success

    @Slot(str, result=bool)
    def saveAs(self, path: str) -> bool:
        """Guardar como"""
        success = self._document.save_as(Path(path))
        if success:
            self.modifiedChanged.emit(False)
        return success

    def _emit_changes(self):
        """Emite señales de cambio"""
        self.textChanged.emit()
        self.modifiedChanged.emit(self._document.modified)

    def _update_text_from_backend(self):
        """Actualiza texto desde el backend (para undo/redo)"""
        self._updating_from_backend = True
        self.textChanged.emit()
        self._updating_from_backend = False

    @Slot(str, bool, bool, result="QVariantList")
    def search(self, query: str, case_sensitive: bool, whole_word: bool):
        """Busca en el documento"""
        text = self._document.buffer.get_text()
        matches = self._search_engine.search(text, query, case_sensitive, whole_word)

        # Retornar lista de matches como diccionarios
        return [{"start": m.start, "end": m.end, "line": m.line} for m in matches]

    @Slot(int, result="QVariantMap")
    def findNext(self, current_position: int):
        """Encuentra siguiente coincidencia"""
        match = self._search_engine.next_match(current_position)
        if match:
            return {"start": match.start, "end": match.end, "line": match.line}
        return {}

    @Slot(int, result="QVariantMap")
    def findPrevious(self, current_position: int):
        """Encuentra coincidencia anterior"""
        match = self._search_engine.previous_match(current_position)
        if match:
            return {"start": match.start, "end": match.end, "line": match.line}
        return {}

    @Slot(str, result=bool)
    def replaceCurrent(self, replacement: str):
        """Reemplaza coincidencia actual"""
        text = self._document.buffer.get_text()
        new_text, start, end = self._search_engine.replace_current(text, replacement)

        if new_text != text:
            self.setText(new_text)
            return True
        return False

    @Slot(str, str, bool, bool, result=int)
    def replaceAll(
        self, query: str, replacement: str, case_sensitive: bool, whole_word: bool
    ):
        """Reemplaza todas las coincidencias"""
        text = self._document.buffer.get_text()
        new_text, count = self._search_engine.replace_all(
            text, query, replacement, case_sensitive, whole_word
        )

        if count > 0:
            self.setText(new_text)
        return count

    @Slot(result=int)
    def getMatchCount(self):
        """Obtiene número de coincidencias"""
        return self._search_engine.match_count

    @Slot(result=int)
    def getCurrentMatch(self):
        """Obtiene índice de coincidencia actual"""
        return self._search_engine.current_match
   
    @Slot(int, result=int)
    def goToLine(self, line_number: int):
        """Va a una línea específica y retorna la posición"""
        text = self._document.buffer.get_text()
        lines = text.split('\n')
        
        if line_number < 1 or line_number > len(lines):
            return 0
        
        # Calcular posición del inicio de la línea
        position = sum(len(lines[i]) + 1 for i in range(line_number - 1))
        return position
