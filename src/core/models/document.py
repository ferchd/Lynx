from pathlib import Path
from typing import Optional
from core.models.text_buffer import TextBuffer

class Document:
    def __init__(self, file_path: Optional[Path] = None):
        self.file_path = file_path
        self._modified = False
        self._language = "plaintext"
        
        content = ""
        if file_path and file_path.exists():
            content = file_path.read_text(encoding='utf-8')
            self._language = self._detect_language(file_path)
        
        self.buffer = TextBuffer(content)
    
    def _detect_language(self, path: Path) -> str:
        ext_map = {
            '.py': 'python',
            '.js': 'javascript',
            '.ts': 'typescript',
            '.html': 'html',
            '.css': 'css',
            '.json': 'json',
            '.md': 'markdown',
        }
        return ext_map.get(path.suffix.lower(), 'plaintext')
    
    def save(self) -> bool:
        if not self.file_path:
            return False
        
        try:
            self.file_path.write_text(self.buffer.get_text(), encoding='utf-8')
            self._modified = False
            return True
        except Exception as e:
            print(f"Save error: {e}")
            return False
    
    def save_as(self, file_path: Path) -> bool:
        self.file_path = file_path
        self._language = self._detect_language(file_path)
        return self.save()
    
    @property
    def modified(self) -> bool:
        return self._modified
    
    @property
    def language(self) -> str:
        return self._language
    
    @property
    def file_name(self) -> str:
        if self.file_path:
            return self.file_path.name
        return "Untitled"