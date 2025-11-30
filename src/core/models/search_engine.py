from typing import List, Tuple, Optional
import re

class SearchMatch:
    def __init__(self, start: int, end: int, line: int):
        self.start = start
        self.end = end
        self.line = line

class SearchEngine:
    """Motor de búsqueda para el editor"""
    
    def __init__(self):
        self._last_search = ""
        self._matches: List[SearchMatch] = []
        self._current_match_index = -1
    
    def search(
        self, 
        text: str, 
        query: str, 
        case_sensitive: bool = False,
        whole_word: bool = False
    ) -> List[SearchMatch]:
        """Busca todas las ocurrencias"""
        if not query:
            self._matches = []
            return []
        
        self._last_search = query
        self._matches = []
        
        # Construir regex
        pattern = re.escape(query)
        if whole_word:
            pattern = r'\b' + pattern + r'\b'
        
        flags = 0 if case_sensitive else re.IGNORECASE
        regex = re.compile(pattern, flags)
        
        # Buscar todas las ocurrencias
        for match in regex.finditer(text):
            line = text[:match.start()].count('\n')
            self._matches.append(
                SearchMatch(match.start(), match.end(), line)
            )
        
        self._current_match_index = 0 if self._matches else -1
        return self._matches
    
    def next_match(self, current_position: int) -> Optional[SearchMatch]:
        """Encuentra siguiente coincidencia"""
        if not self._matches:
            return None
        
        # Buscar siguiente match después de la posición actual
        for i, match in enumerate(self._matches):
            if match.start > current_position:
                self._current_match_index = i
                return match
        
        # Si no hay siguiente, volver al primero (wrap around)
        self._current_match_index = 0
        return self._matches[0]
    
    def previous_match(self, current_position: int) -> Optional[SearchMatch]:
        """Encuentra coincidencia anterior"""
        if not self._matches:
            return None
        
        # Buscar match anterior a la posición actual
        for i in range(len(self._matches) - 1, -1, -1):
            if self._matches[i].start < current_position:
                self._current_match_index = i
                return self._matches[i]
        
        # Si no hay anterior, ir al último (wrap around)
        self._current_match_index = len(self._matches) - 1
        return self._matches[-1]
    
    def replace_current(
        self, 
        text: str, 
        replacement: str
    ) -> Tuple[str, int, int]:
        """Reemplaza la coincidencia actual"""
        if self._current_match_index < 0 or not self._matches:
            return text, 0, 0
        
        match = self._matches[self._current_match_index]
        new_text = (
            text[:match.start] + 
            replacement + 
            text[match.end:]
        )
        
        return new_text, match.start, match.start + len(replacement)
    
    def replace_all(
        self, 
        text: str, 
        query: str,
        replacement: str,
        case_sensitive: bool = False,
        whole_word: bool = False
    ) -> Tuple[str, int]:
        """Reemplaza todas las coincidencias"""
        pattern = re.escape(query)
        if whole_word:
            pattern = r'\b' + pattern + r'\b'
        
        flags = 0 if case_sensitive else re.IGNORECASE
        
        new_text, count = re.subn(pattern, replacement, text, flags=flags)
        return new_text, count
    
    @property
    def match_count(self) -> int:
        return len(self._matches)
    
    @property
    def current_match(self) -> int:
        return self._current_match_index + 1 if self._current_match_index >= 0 else 0