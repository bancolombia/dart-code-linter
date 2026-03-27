"""Writers package: one module per output format (Cursor, VSCode)."""

from .cursor import write_cursor
from .vscode_always_on import write_vscode_always_on
from .vscode_file_based import write_vscode_file_based

__all__ = [
    "write_cursor",
    "write_vscode_always_on",
    "write_vscode_file_based",
]
