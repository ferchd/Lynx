from dataclasses import dataclass
from typing import List, Optional

@dataclass
class Edit:
    position: int
    deleted_text: str
    inserted_text: str

class UndoStack:
    def __init__(self, max_size: int = 1000):
        self._undo: List[Edit] = []
        self._redo: List[Edit] = []
        self._max = max_size
    
    def push(self, edit: Edit):
        self._undo.append(edit)
        self._redo.clear()
        if len(self._undo) > self._max:
            self._undo.pop(0)
    
    def undo(self) -> Optional[Edit]:
        if not self._undo:
            return None
        edit = self._undo.pop()
        self._redo.append(edit)
        return edit
    
    def redo(self) -> Optional[Edit]:
        if not self._redo:
            return None
        edit = self._redo.pop()
        self._undo.append(edit)
        return edit
    
    def can_undo(self) -> bool:
        return len(self._undo) > 0
    
    def can_redo(self) -> bool:
        return len(self._redo) > 0