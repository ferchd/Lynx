"""
Piece Table implementation for efficient text editing
"""

from dataclasses import dataclass
from typing import List, Optional, Dict


@dataclass
class Span:
    """Representa un fragmento de texto con metadata"""

    __slots__ = ["start", "length", "source", "version"]

    def __init__(self, start: int, length: int, source: str = "add", version: int = 0):
        self.start = start
        self.length = length
        self.source = source  # 'original' o 'add'
        self.version = version


class PieceTable:
    """
    Piece Table optimizado para archivos grandes
    O(1) para insert/delete
    O(n) para get_text solo en piezas modificadas
    """

    def __init__(self, initial_content: str = ""):
        self.original_buffer = initial_content
        self.add_buffer = []  # Lista de strings para append eficiente
        self.pieces: List[Span] = []
        self.version = 0

        if initial_content:
            self.pieces.append(Span(0, len(initial_content), "original", 0))

    def insert(self, position: int, text: str) -> None:
        """Inserta texto en posición O(log n)"""
        if not text:
            return

        self.version += 1
        add_start = sum(len(s) for s in self.add_buffer)
        self.add_buffer.append(text)
        new_span = Span(add_start, len(text), "add", self.version)

        # Binary search para encontrar posición
        piece_idx, offset = self._find_piece(position)

        if piece_idx == -1:
            self.pieces.append(new_span)
            return

        piece = self.pieces[piece_idx]

        if offset == 0:
            self.pieces.insert(piece_idx, new_span)
        elif offset == piece.length:
            self.pieces.insert(piece_idx + 1, new_span)
        else:
            # Split piece
            left = Span(piece.start, offset, piece.source, piece.version)
            right = Span(
                piece.start + offset, piece.length - offset, piece.source, piece.version
            )
            self.pieces[piece_idx : piece_idx + 1] = [left, new_span, right]

    def delete(self, position: int, length: int) -> str:
        """Elimina texto y retorna el texto eliminado"""
        if length <= 0:
            return ""

        self.version += 1
        deleted_text = self.get_text_range(position, position + length)

        piece_idx, offset = self._find_piece(position)
        if piece_idx == -1:
            return ""

        end_position = position + length
        new_pieces = []
        current_pos = 0

        for i, piece in enumerate(self.pieces):
            piece_end = current_pos + piece.length

            if piece_end <= position or current_pos >= end_position:
                new_pieces.append(piece)
            else:
                # Partial overlap
                if current_pos < position:
                    new_pieces.append(
                        Span(
                            piece.start,
                            position - current_pos,
                            piece.source,
                            piece.version,
                        )
                    )

                if piece_end > end_position:
                    skip = end_position - current_pos
                    new_pieces.append(
                        Span(
                            piece.start + skip,
                            piece_end - end_position,
                            piece.source,
                            piece.version,
                        )
                    )

            current_pos += piece.length

        self.pieces = new_pieces
        return deleted_text

    def get_text(self) -> str:
        """Obtiene todo el texto O(n) en piezas"""
        result = []
        for piece in self.pieces:
            if piece.source == "original":
                result.append(
                    self.original_buffer[piece.start : piece.start + piece.length]
                )
            else:
                # Reconstruir desde add_buffer
                current = 0
                for chunk in self.add_buffer:
                    if current + len(chunk) > piece.start:
                        start_in_chunk = max(0, piece.start - current)
                        end_in_chunk = min(
                            len(chunk), piece.start + piece.length - current
                        )
                        result.append(chunk[start_in_chunk:end_in_chunk])
                        if current + len(chunk) >= piece.start + piece.length:
                            break
                    current += len(chunk)
        return "".join(result)

    def get_text_range(self, start: int, end: int) -> str:
        """Obtiene texto en rango específico"""
        # Optimización: solo procesar piezas en el rango
        result = []
        current_pos = 0

        for piece in self.pieces:
            piece_end = current_pos + piece.length

            if piece_end <= start:
                current_pos += piece.length
                continue

            if current_pos >= end:
                break

            # Pieza en el rango
            piece_start_in_range = max(0, start - current_pos)
            piece_end_in_range = min(piece.length, end - current_pos)

            if piece.source == "original":
                text = self.original_buffer[
                    piece.start
                    + piece_start_in_range : piece.start
                    + piece_end_in_range
                ]
            else:
                # Reconstruir desde add_buffer
                text = self._get_from_add_buffer(
                    piece.start + piece_start_in_range,
                    piece_end_in_range - piece_start_in_range,
                )

            result.append(text)
            current_pos += piece.length

        return "".join(result)

    def get_line(self, line_number: int) -> str:
        """Obtiene una línea específica"""
        lines = self.get_text().split("\n")
        return lines[line_number] if 0 <= line_number < len(lines) else ""

    def get_line_count(self) -> int:
        """Cuenta líneas eficientemente"""
        return self.get_text().count("\n") + 1

    def _find_piece(self, position: int) -> tuple:
        """Encuentra el piece que contiene la posición"""
        current_pos = 0
        for i, piece in enumerate(self.pieces):
            if current_pos + piece.length >= position:
                return i, position - current_pos
            current_pos += piece.length
        return -1, 0

    def _get_from_add_buffer(self, start: int, length: int) -> str:
        """Extrae texto del add_buffer"""
        result = []
        current = 0
        for chunk in self.add_buffer:
            if current + len(chunk) > start:
                start_in_chunk = max(0, start - current)
                end_in_chunk = min(len(chunk), start + length - current)
                result.append(chunk[start_in_chunk:end_in_chunk])
                if current + len(chunk) >= start + length:
                    break
            current += len(chunk)
        return "".join(result)

    def create_snapshot(self) -> Dict:
        """Crea snapshot para undo/redo eficiente"""
        return {
            "version": self.version,
            "pieces": [(p.start, p.length, p.source, p.version) for p in self.pieces],
            "add_buffer_length": sum(len(s) for s in self.add_buffer),
        }

    def restore_snapshot(self, snapshot: Dict) -> None:
        """Restaura desde snapshot"""
        self.version = snapshot["version"]
        self.pieces = [
            Span(start, length, source, ver)
            for start, length, source, ver in snapshot["pieces"]
        ]


@dataclass
class Edit:
    """Representa una operación de edición"""

    position: int
    length: int  # 0 para insert, >0 para delete
    text: str
    timestamp: float
    version: int


class UndoStack:
    """Stack de undo/redo con snapshots inteligentes"""

    def __init__(self, snapshot_interval: int = 50):
        self.undo_stack: List[Edit] = []
        self.redo_stack: List[Edit] = []
        self.snapshots: Dict[int, Dict] = {}
        self.snapshot_interval = snapshot_interval
        self.current_version = 0

    def push(self, edit: Edit, snapshot: Optional[Dict] = None):
        """Añade edición al stack"""
        self.undo_stack.append(edit)
        self.redo_stack.clear()
        self.current_version = edit.version

        # Guardar snapshot cada N operaciones
        if snapshot and edit.version % self.snapshot_interval == 0:
            self.snapshots[edit.version] = snapshot

    def undo(self) -> Optional[Edit]:
        """Deshace última edición"""
        if not self.undo_stack:
            return None

        edit = self.undo_stack.pop()
        self.redo_stack.append(edit)
        return edit

    def redo(self) -> Optional[Edit]:
        """Rehace edición"""
        if not self.redo_stack:
            return None

        edit = self.redo_stack.pop()
        self.undo_stack.append(edit)
        return edit

    def get_nearest_snapshot(self, version: int) -> Optional[Dict]:
        """Obtiene el snapshot más cercano"""
        valid_versions = [v for v in self.snapshots.keys() if v <= version]
        if not valid_versions:
            return None
        return self.snapshots[max(valid_versions)]
