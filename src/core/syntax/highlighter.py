from enum import Enum
from dataclasses import dataclass
from typing import List, Dict, Optional
import tree_sitter
from tree_sitter import Language, Parser

class TokenType(Enum):
    KEYWORD = "keyword"
    STRING = "string"
    COMMENT = "comment"
    NUMBER = "number"
    FUNCTION = "function"
    OPERATOR = "operator"
    IDENTIFIER = "identifier"

@dataclass
class Token:
    type: TokenType
    start: int
    end: int
    line: int

class TreeSitterHighlighter:
    """Syntax highlighter usando tree-sitter"""
    
    # Lenguajes soportados en MVP
    SUPPORTED_LANGUAGES = ['python', 'javascript']
    
    def __init__(self, language: str):
        self.language = language
        self._parser: Optional[Parser] = None
        self._tree = None
        self._setup_parser()
    
    def _setup_parser(self):
        """Configura parser de tree-sitter"""
        if self.language not in self.SUPPORTED_LANGUAGES:
            return
        
        try:
            # Cargar lenguaje pre-compilado (debes incluir los .so en el repo)
            lang = Language(f'languages/{self.language}.so', self.language)
            self._parser = Parser()
            self._parser.set_language(lang)
        except Exception as e:
            print(f"Error loading tree-sitter language: {e}")
    
    def parse(self, text: str):
        """Parsea el texto completo"""
        if not self._parser:
            return
        
        self._tree = self._parser.parse(bytes(text, 'utf8'))
    
    def get_tokens(self, start_line: int, end_line: int) -> List[Token]:
        """Obtiene tokens para rango de líneas"""
        if not self._tree:
            return []
        
        tokens = []
        root = self._tree.root_node
        
        # Query para obtener nodos interesantes
        query_str = self._get_query_for_language()
        if not query_str:
            return []
        
        query = self.language.query(query_str)
        captures = query.captures(root)
        
        for node, capture_name in captures:
            if start_line <= node.start_point[0] <= end_line:
                token_type = self._map_capture_to_type(capture_name)
                tokens.append(Token(
                    type=token_type,
                    start=node.start_byte,
                    end=node.end_byte,
                    line=node.start_point[0]
                ))
        
        return tokens
    
    def _get_query_for_language(self) -> str:
        """Queries específicas por lenguaje"""
        queries = {
            'python': '''
                (function_definition name: (identifier) @function)
                (class_definition name: (identifier) @class)
                (string) @string
                (comment) @comment
                (integer) @number
                (float) @number
                (identifier) @identifier
            ''',
            'javascript': '''
                (function_declaration name: (identifier) @function)
                (string) @string
                (comment) @comment
                (number) @number
                (identifier) @identifier
            '''
        }
        return queries.get(self.language, '')
    
    def _map_capture_to_type(self, capture: str) -> TokenType:
        """Mapea capture de tree-sitter a nuestro TokenType"""
        mapping = {
            'function': TokenType.FUNCTION,
            'string': TokenType.STRING,
            'comment': TokenType.COMMENT,
            'number': TokenType.NUMBER,
            'keyword': TokenType.KEYWORD,
            'operator': TokenType.OPERATOR,
            'identifier': TokenType.IDENTIFIER,
        }
        return mapping.get(capture, TokenType.IDENTIFIER)