from pathlib import Path
from typing import List, Optional, Dict
from enum import Enum

class FileType(Enum):
    FILE = "file"
    FOLDER = "folder"

class FileNode:
    """Nodo del árbol de archivos"""
    
    def __init__(
        self, 
        name: str, 
        path: Path, 
        file_type: FileType,
        level: int = 0,
        parent: Optional['FileNode'] = None
    ):
        self.name = name
        self.path = path
        self.file_type = file_type
        self.level = level
        self.parent = parent
        self.expanded = False
        self.children: List['FileNode'] = []
    
    def to_dict(self) -> Dict:
        """Convierte a diccionario para QML"""
        return {
            'name': self.name,
            'path': str(self.path),
            'type': self.file_type.value,
            'level': self.level,
            'expanded': self.expanded,
            'isFolder': self.file_type == FileType.FOLDER,
        }

    def get_icon(self) -> str:
        """Retorna ícono según tipo de archivo"""
        if self.file_type == FileType.FOLDER:
            return "folder"
        
        ext = self.path.suffix.lower()
        icon_map = {
            '.py': 'python',
            '.js': 'javascript',
            '.ts': 'typescript',
            '.jsx': 'react',
            '.tsx': 'react',
            '.html': 'html',
            '.css': 'css',
            '.json': 'json',
            '.md': 'markdown',
            '.txt': 'text',
            '.rs': 'rust',
            '.go': 'go',
            '.java': 'java',
            '.cpp': 'cpp',
            '.c': 'c',
            '.h': 'header',
        }
        return icon_map.get(ext, 'file')
    
    def to_dict(self) -> Dict:
        """Convierte a diccionario para QML"""
        return {
            'name': self.name,
            'path': str(self.path),
            'type': self.file_type.value,
            'level': self.level,
            'expanded': self.expanded,
            'isFolder': self.file_type == FileType.FOLDER,
            'icon': self.get_icon(),  # NUEVO
        }

class FileTree:
    """Árbol de archivos del proyecto"""
    
    def __init__(self, root_path: Optional[Path] = None):
        self.root_path = root_path
        self.root_nodes: List[FileNode] = []
        self._flat_list: List[FileNode] = []
        
        if root_path:
            self.load_directory(root_path)
    
    def load_directory(self, path: Path):
        """Carga un directorio como raíz"""
        if not path.exists() or not path.is_dir():
            return
        
        self.root_path = path
        self.root_nodes = []
        
        # Crear nodo raíz
        root = FileNode(
            name=path.name,
            path=path,
            file_type=FileType.FOLDER,
            level=0
        )
        root.expanded = True
        self.root_nodes.append(root)
        
        # Cargar contenido
        self._load_children(root)
        self._rebuild_flat_list()
    
    def _load_children(self, node: FileNode, max_depth: int = 1):  # Reducir de 3 a 2
        """Carga hijos de un nodo (lazy loading optimizado)"""
        if node.file_type != FileType.FOLDER:
            return
        
        if node.level >= max_depth:
            return
        
        # Si ya tiene hijos cargados, no recargar
        if node.children:
            return
        
        try:
            entries = list(node.path.iterdir())
            
            # Filtrar y ordenar
            filtered = []
            for entry in entries:
                if entry.name.startswith('.'):
                    continue
                if entry.name in ['__pycache__', 'node_modules', '.git', '.venv', 'dist', 'build']:
                    continue
                filtered.append(entry)
            
            # Ordenar: carpetas primero, luego por nombre
            filtered.sort(key=lambda x: (not x.is_dir(), x.name.lower()))
            
            # Límite de archivos por carpeta (evitar carpetas gigantes)
            MAX_FILES = 500
            if len(filtered) > MAX_FILES:
                filtered = filtered[:MAX_FILES]
            
            for entry in filtered:
                child_type = FileType.FOLDER if entry.is_dir() else FileType.FILE
                child = FileNode(
                    name=entry.name,
                    path=entry,
                    file_type=child_type,
                    level=node.level + 1,
                    parent=node
                )
                
                node.children.append(child)
                
                # Solo auto-expandir el primer nivel
                if child.file_type == FileType.FOLDER and child.level <= 1:
                    child.expanded = False  # No expandir automáticamente
        
        except PermissionError:
            pass
        except Exception as e:
            print(f"Error loading {node.path}: {e}")
    
    def toggle_node(self, path: str) -> bool:
        """Expande/colapsa un nodo"""
        node = self._find_node_by_path(Path(path))
        if not node or node.file_type != FileType.FOLDER:
            return False
        
        node.expanded = not node.expanded
        
        # Cargar hijos si es la primera vez que se expande
        if node.expanded and not node.children:
            self._load_children(node)
        
        self._rebuild_flat_list()
        return True
    
    def _find_node_by_path(self, path: Path) -> Optional[FileNode]:
        """Busca un nodo por su path"""
        def search(nodes: List[FileNode]) -> Optional[FileNode]:
            for node in nodes:
                if node.path == path:
                    return node
                if node.children:
                    result = search(node.children)
                    if result:
                        return result
            return None
        
        return search(self.root_nodes)
    
    def _rebuild_flat_list(self):
        """Reconstruye lista plana para mostrar en QML"""
        self._flat_list = []
        
        def flatten(nodes: List[FileNode]):
            for node in nodes:
                self._flat_list.append(node)
                if node.expanded and node.children:
                    flatten(node.children)
        
        flatten(self.root_nodes)
    
    def get_flat_list(self) -> List[Dict]:
        """Obtiene lista plana como diccionarios para QML"""
        return [node.to_dict() for node in self._flat_list]
    
    def refresh(self):
        """Refresca el árbol completo"""
        if self.root_path:
            self.load_directory(self.root_path)