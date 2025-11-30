from typing import List, Optional
from pathlib import Path
from PySide6.QtCore import QObject, Slot, Signal, Property

from core.models.document import Document
from core.models.file_tree import FileTree
from ui.controllers.document_controller import DocumentController

class EditorApplication(QObject):
    documentsChanged = Signal()
    currentDocumentChanged = Signal()
    fileTreeChanged = Signal()  # NUEVO
    workspaceFolderChanged = Signal()  # NUEVO
    
    def __init__(self):
        super().__init__()
        self._documents: List[DocumentController] = []
        self._current: Optional[DocumentController] = None
        self._file_tree = FileTree()  # NUEVO
        self._workspace_folder: Optional[Path] = None  # NUEVO
    
    # ==================== NUEVO: GESTIÓN DE WORKSPACE ====================
    
    @Slot(str)
    def openFolder(self, folder_path: str):
        """Abre una carpeta como workspace"""
        path = Path(folder_path)
        if not path.exists() or not path.is_dir():
            print(f"Invalid folder: {folder_path}")
            return
        
        self._workspace_folder = path
        self._file_tree.load_directory(path)
        
        self.workspaceFolderChanged.emit()
        self.fileTreeChanged.emit()
    
    @Slot(str)
    def toggleFileTreeNode(self, node_path: str):
        """Expande/colapsa un nodo del árbol"""
        if self._file_tree.toggle_node(node_path):
            self.fileTreeChanged.emit()
    
    @Slot()
    def refreshFileTree(self):
        """Refresca el árbol de archivos"""
        self._file_tree.refresh()
        self.fileTreeChanged.emit()
    
    @Property('QVariantList', notify=fileTreeChanged)
    def fileTree(self):
        """Lista de archivos para QML"""
        return self._file_tree.get_flat_list()
    
    @Property(str, notify=workspaceFolderChanged)
    def workspaceFolder(self) -> str:
        """Carpeta actual del workspace"""
        return str(self._workspace_folder) if self._workspace_folder else ""
    
    @Property(str, notify=workspaceFolderChanged)
    def workspaceName(self) -> str:
        """Nombre del workspace"""
        if self._workspace_folder:
            return self._workspace_folder.name
        return "No Folder Open"
    
    # ==================== MÉTODOS EXISTENTES ====================
    
    @Slot(str)
    def openDocument(self, file_path: str):
        """Abre un documento"""
        path = Path(file_path)
        
        # Si no hay workspace, usar el directorio del archivo
        if not self._workspace_folder:
            self._workspace_folder = path.parent
            self._file_tree.load_directory(path.parent)
            self.workspaceFolderChanged.emit()
            self.fileTreeChanged.emit()
        
        # Verificar si ya está abierto
        for doc in self._documents:
            if doc._document.file_path == path:
                self._current = doc
                self.currentDocumentChanged.emit()
                return
        
        # Crear nuevo documento
        doc = Document(path)
        ctrl = DocumentController(doc)
        self._documents.append(ctrl)
        self._current = ctrl
        
        self.documentsChanged.emit()
        self.currentDocumentChanged.emit()
    
    @Slot()
    def newDocument(self):
        """Crea documento nuevo"""
        doc = Document()
        ctrl = DocumentController(doc)
        self._documents.append(ctrl)
        self._current = ctrl
        
        self.documentsChanged.emit()
        self.currentDocumentChanged.emit()
    
    @Slot(QObject)
    def closeDocument(self, controller):
        """Cierra un documento"""
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
        """Cambia documento activo"""
        self._current = controller
        self.currentDocumentChanged.emit()
    
    @Property(QObject, notify=currentDocumentChanged)
    def currentDocument(self):
        return self._current
    
    @Property('QVariantList', notify=documentsChanged)
    def documents(self):
        return self._documents