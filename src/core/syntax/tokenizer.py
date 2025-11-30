"""
Incremental syntax tokenizer
"""

from enum import Enum
from dataclasses import dataclass
from typing import List
import re


class TokenType(Enum):
    KEYWORD = "keyword"
    STRING = "string"
    COMMENT = "comment"
    NUMBER = "number"
    FUNCTION = "function"
    CLASS = "class"
    OPERATOR = "operator"
    IDENTIFIER = "identifier"
    PUNCTUATION = "punctuation"


@dataclass
class Token:
    """Token con información de posición"""

    type: TokenType
    start: int
    end: int
    value: str


class IncrementalTokenizer:
    """
    Tokenizer incremental - solo re-tokeniza bloques modificados
    Cache por línea para máxima eficiencia
    """

    def __init__(self, language: str = "python"):
        self.language = language
        self.token_cache: Dict[int, List[Token]] = {}
        self.dirty_lines: set = set()
        self._load_grammar(language)

    def _load_grammar(self, language: str):
        """Carga gramática del lenguaje"""
        # Gramáticas básicas - expandir con TextMate o tree-sitter
        self.grammars = {
            "python": {
                "keywords": r"\b(def|class|if|else|elif|for|while|import|from|return|pass|break|continue|try|except|finally|with|as|async|await|yield)\b",
                "strings": r'(["\'])(?:(?=(\\?))\2.)*?\1',
                "comments": r"#.*$",
                "numbers": r"\b\d+\.?\d*\b",
                "functions": r"\b([a-zA-Z_]\w*)\s*(?=\()",
            },
            "javascript": {
                "keywords": r"\b(function|const|let|var|if|else|for|while|return|class|extends|async|await|import|export|default)\b",
                "strings": r'(["\'])(?:(?=(\\?))\2.)*?\1|`[^`]*`',
                "comments": r"//.*$|/\*[\s\S]*?\*/",
                "numbers": r"\b\d+\.?\d*\b",
                "functions": r"\b([a-zA-Z_]\w*)\s*(?=\()",
            },
        }

    def tokenize_line(self, line_number: int, text: str) -> List[Token]:
        """Tokeniza una línea específica"""
        if line_number in self.token_cache and line_number not in self.dirty_lines:
            return self.token_cache[line_number]

        tokens = []
        grammar = self.grammars.get(self.language, {})

        # Tokenizar según gramática
        import re

        for token_type, pattern in grammar.items():
            for match in re.finditer(pattern, text, re.MULTILINE):
                token_enum = TokenType[token_type.upper().rstrip("S")]
                tokens.append(
                    Token(
                        type=token_enum,
                        start=match.start(),
                        end=match.end(),
                        value=match.group(),
                    )
                )

        # Ordenar por posición
        tokens.sort(key=lambda t: t.start)

        # Cachear
        self.token_cache[line_number] = tokens
        self.dirty_lines.discard(line_number)

        return tokens

    def mark_dirty(self, start_line: int, end_line: int):
        """Marca líneas como dirty para re-tokenización"""
        for line in range(start_line, end_line + 1):
            self.dirty_lines.add(line)

    def invalidate_cache(self):
        """Invalida todo el cache"""
        self.token_cache.clear()
        self.dirty_lines.clear()
