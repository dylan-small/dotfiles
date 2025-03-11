from typing import Any, Literal
from typing_extensions import LiteralString, Self

class stringPict:
    LINE = ...
    def __init__(self, s, baseline=...) -> None: ...
    @staticmethod
    def equalLengths(lines) -> list[str] | list[Any]: ...
    def height(self) -> int: ...
    def width(self) -> int: ...
    @staticmethod
    def next(*args) -> tuple[str, Any]: ...
    def right(self, *args) -> tuple[str, Any]: ...
    def left(self, *args) -> tuple[str, Any]: ...
    @staticmethod
    def stack(*args) -> tuple[LiteralString, Any]: ...
    def below(self, *args) -> tuple[LiteralString, int]: ...
    def above(self, *args) -> tuple[LiteralString, int]: ...
    def parens(self, left=..., right=..., ifascii_nougly=...) -> tuple[str, int]: ...
    def leftslash(self) -> tuple[str, Any]: ...
    def root(self, n=...): ...
    def render(self, *args, **kwargs) -> str | Any | LiteralString: ...
    def terminal_width(self) -> Any | Literal[0]: ...
    def __eq__(self, o) -> bool: ...
    def __hash__(self) -> int: ...
    def __getitem__(self, index): ...
    def __len__(self) -> int: ...

class prettyForm(stringPict):
    def __init__(self, s, baseline=..., binding=..., unicode=...) -> None: ...
    @property
    def unicode(self) -> Any: ...
    def __add__(self, *others) -> prettyForm: ...
    def __truediv__(self, den, slashed=...) -> prettyForm: ...
    def __mul__(self, *others) -> Self | prettyForm: ...
    def __pow__(self, b) -> prettyForm: ...

    simpleFunctions = ...
    @staticmethod
    def apply(function, *args) -> prettyForm: ...
