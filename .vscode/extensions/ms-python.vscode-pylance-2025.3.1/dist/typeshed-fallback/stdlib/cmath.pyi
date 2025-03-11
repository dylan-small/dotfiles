from typing import Final, SupportsComplex, SupportsFloat, SupportsIndex
from typing_extensions import TypeAlias

e: Final[float]
pi: Final[float]
inf: Final[float]
infj: Final[complex]
nan: Final[float]
nanj: Final[complex]
tau: Final[float]

_C: TypeAlias = SupportsFloat | SupportsComplex | SupportsIndex | complex

def acos(z: _C, /) -> complex: ...
def acosh(z: _C, /) -> complex: ...
def asin(z: _C, /) -> complex: ...
def asinh(z: _C, /) -> complex: ...
def atan(z: _C, /) -> complex: ...
def atanh(z: _C, /) -> complex: ...
def cos(z: _C, /) -> complex: ...
def cosh(z: _C, /) -> complex: ...
def exp(z: _C, /) -> complex: ...
def isclose(a: _C, b: _C, *, rel_tol: SupportsFloat = 1e-09, abs_tol: SupportsFloat = 0.0) -> bool: ...
def isinf(z: _C, /) -> bool: ...
def isnan(z: _C, /) -> bool: ...
def log(x: _C, base: _C = ..., /) -> complex: ...
def log10(z: _C, /) -> complex: ...
def phase(z: _C, /) -> float: ...
def polar(z: _C, /) -> tuple[float, float]: ...
def rect(r: float, phi: float, /) -> complex: ...
def sin(z: _C, /) -> complex: ...
def sinh(z: _C, /) -> complex: ...
def sqrt(z: _C, /) -> complex: ...
def tan(z: _C, /) -> complex: ...
def tanh(z: _C, /) -> complex: ...
def isfinite(z: _C, /) -> bool: ...
