from core.buffer.gap_buffer import GapBuffer
from core.buffer.undo_stack import UndoStack, Edit

class TextBuffer:
    def __init__(self, content: str = ""):
        self._buffer = GapBuffer(content)
        self._undo_stack = UndoStack()
        self._version = 0
    
    def insert(self, position: int, text: str):
        self._buffer.insert(position, text)
        self._version += 1
        edit = Edit(position=position, deleted_text="", inserted_text=text)
        self._undo_stack.push(edit)
    
    def delete(self, position: int, length: int):
        deleted = self._buffer.delete(position, length)
        self._version += 1
        edit = Edit(position=position, deleted_text=deleted, inserted_text="")
        self._undo_stack.push(edit)
    
    def undo(self):
        edit = self._undo_stack.undo()
        if not edit:
            return
        
        if edit.inserted_text:
            self._buffer.delete(edit.position, len(edit.inserted_text))
        if edit.deleted_text:
            self._buffer.insert(edit.position, edit.deleted_text)
        
        self._version += 1
    
    def redo(self):
        edit = self._undo_stack.redo()
        if not edit:
            return
        
        if edit.deleted_text:
            self._buffer.delete(edit.position, len(edit.deleted_text))
        if edit.inserted_text:
            self._buffer.insert(edit.position, edit.inserted_text)
        
        self._version += 1
    
    def get_text(self) -> str:
        return self._buffer.get_text()
    
    def can_undo(self) -> bool:
        return self._undo_stack.can_undo()
    
    def can_redo(self) -> bool:
        return self._undo_stack.can_redo()
    
    @property
    def version(self) -> int:
        return self._version