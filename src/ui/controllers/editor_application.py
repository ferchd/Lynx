from typing import List, Optional
from pathlib import Path
from PySide6.QtCore import QObject, Slot, Signal, Property

from core.models.document import Document
from ui.controllers.document_controller import DocumentController

class EditorApplication(QObject):
    documentsChanged = Signal()
    currentDocumentChanged = Signal()
    
    def __init__(self):
        super().__init__()
        self._documents: List[DocumentController] = []
        self._current: Optional[DocumentController] = None
    
    @Slot(str)
    def openDocument(self, file_path: str):
        path = Path(file_path)
        
        for doc in self._documents:
            if doc._document.file_path == path:
                self._current = doc
                self.currentDocumentChanged.emit()
                return
        
        doc = Document(path)
        ctrl = DocumentController(doc)
        self._documents.append(ctrl)
        self._current = ctrl
        
        self.documentsChanged.emit()
        self.currentDocumentChanged.emit()
    
    @Slot()
    def newDocument(self):
        doc = Document()
        ctrl = DocumentController(doc)
        self._documents.append(ctrl)
        self._current = ctrl
        
        self.documentsChanged.emit()
        self.currentDocumentChanged.emit()
    
    @Slot(QObject)
    def closeDocument(self, controller):
        if controller in self._documents:
            idx = self._documents.index(controller)
            self._documents.remove(controller)
            
            if self._current == controller:
                if self._documents:
                    self._current = self._documents[min(idx, len(self._documents) - 1)]
                else:
                    self._current = None
                self.currentDocumentChanged.emit()
            
            self.documentsChanged.emit()
    
    @Slot(QObject)
    def setActiveDocument(self, controller):
        self._current = controller
        self.currentDocumentChanged.emit()
    
    @Property(QObject, notify=currentDocumentChanged)
    def currentDocument(self):
        return self._current
    
    @Property('QVariantList', notify=documentsChanged)
    def documents(self):
        return self._documents