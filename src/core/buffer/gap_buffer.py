class GapBuffer:
    def __init__(self, initial_content: str = "", gap_size: int = 1024):
        content_bytes = initial_content.encode('utf-8')
        self._buffer = bytearray(len(content_bytes) + gap_size)
        self._buffer[:len(content_bytes)] = content_bytes
        self._gap_start = len(content_bytes)
        self._gap_end = len(content_bytes) + gap_size
        self._total_size = len(self._buffer)
    
    def _move_gap(self, position: int):
        if position < self._gap_start:
            distance = self._gap_start - position
            self._buffer[self._gap_end - distance:self._gap_end] = \
                self._buffer[position:self._gap_start]
            self._gap_end -= distance
            self._gap_start = position
        elif position > self._gap_start:
            distance = position - self._gap_start
            self._buffer[self._gap_start:self._gap_start + distance] = \
                self._buffer[self._gap_end:self._gap_end + distance]
            self._gap_start += distance
            self._gap_end += distance
    
    def _expand_gap(self, min_size: int):
        new_gap_size = max(min_size, 1024)
        new_buffer = bytearray(len(self._buffer) + new_gap_size)
        new_buffer[:self._gap_start] = self._buffer[:self._gap_start]
        new_buffer[self._gap_start + new_gap_size:] = \
            self._buffer[self._gap_end:]
        self._buffer = new_buffer
        self._gap_end = self._gap_start + new_gap_size
    
    def insert(self, position: int, text: str):
        data = text.encode('utf-8')
        self._move_gap(position)
        
        if self._gap_end - self._gap_start < len(data):
            self._expand_gap(len(data))
        
        self._buffer[self._gap_start:self._gap_start + len(data)] = data
        self._gap_start += len(data)
    
    def delete(self, position: int, length: int) -> str:
        self._move_gap(position)
        deleted = self._buffer[self._gap_end:self._gap_end + length]
        self._gap_end += length
        return deleted.decode('utf-8', errors='replace')
    
    def get_text(self) -> str:
        before = self._buffer[:self._gap_start]
        after = self._buffer[self._gap_end:]
        return (before + after).decode('utf-8', errors='replace')
    
    def __len__(self):
        return len(self._buffer) - (self._gap_end - self._gap_start)