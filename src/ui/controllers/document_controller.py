from PySide6.QtCore import QObject, Signal, Slot, Property
from core.models.document import Document
from pathlib import Path

class DocumentController(QObject):
    textChanged = Signal()
    modifiedChanged = Signal(bool)
    
    def __init__(self, document: Document):
        super().__init__()
        self._document = document
    
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
    
    @Slot(int, str)
    def insert(self, position: int, text: str):
        self._document.buffer.insert(position, text)
        self._document._modified = True
        self.textChanged.emit()
        self.modifiedChanged.emit(True)
    
    @Slot(int, int)
    def delete(self, position: int, length: int):
        self._document.buffer.delete(position, length)
        self._document._modified = True
        self.textChanged.emit()
        self.modifiedChanged.emit(True)
    
    @Slot()
    def undo(self):
        self._document.buffer.undo()
        self.textChanged.emit()
    
    @Slot()
    def redo(self):
        self._document.buffer.redo()
        self.textChanged.emit()
    
    @Slot(result=bool)
    def save(self) -> bool:
        success = self._document.save()
        if success:
            self.modifiedChanged.emit(False)
        return success
    
    @Slot(str, result=bool)
    def saveAs(self, path: str) -> bool:
        success = self._document.save_as(Path(path))
        if success:
            self.modifiedChanged.emit(False)
        return success