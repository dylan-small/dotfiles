from _typeshed import GenericPath, Incomplete, StrPath
from collections.abc import Iterator
from types import CodeType
from typing import AnyStr, ClassVar, Final, Literal, TypeVar
from zipfile import _ZipFileMode

from .. import Command

_StrPathT = TypeVar("_StrPathT", bound=StrPath)

def strip_module(filename): ...
def sorted_walk(dir: GenericPath[AnyStr]) -> Iterator[tuple[AnyStr, list[AnyStr], list[AnyStr]]]: ...
def write_stub(resource, pyfile) -> None: ...

class bdist_egg(Command):
    description: str
    user_options: ClassVar[list[tuple[str, str | None, str]]]
    boolean_options: ClassVar[list[str]]
    bdist_dir: Incomplete
    plat_name: Incomplete
    keep_temp: bool
    dist_dir: Incomplete
    skip_build: bool
    egg_output: Incomplete
    exclude_source_files: Incomplete
    def initialize_options(self) -> None: ...
    egg_info: Incomplete
    def finalize_options(self) -> None: ...
    def do_install_data(self) -> None: ...
    def get_outputs(self): ...
    def call_command(self, cmdname, **kw): ...
    stubs: Incomplete
    def run(self) -> None: ...
    def zap_pyfiles(self) -> None: ...
    def zip_safe(self): ...
    def gen_header(self) -> Literal["w"]: ...
    def copy_metadata_to(self, target_dir) -> None: ...
    def get_ext_outputs(self): ...

NATIVE_EXTENSIONS: Final[dict[str, None]]

def walk_egg(egg_dir: StrPath) -> Iterator[tuple[str, list[str], list[str]]]: ...
def analyze_egg(egg_dir, stubs): ...
def write_safety_flag(egg_dir, safe) -> None: ...

safety_flags: Incomplete

def scan_module(egg_dir, base, name, stubs): ...
def iter_symbols(code: CodeType) -> Iterator[str]: ...
def can_scan() -> bool: ...

INSTALL_DIRECTORY_ATTRS: Final[list[str]]

def make_zipfile(
    zip_filename: _StrPathT,
    base_dir,
    verbose: bool = False,
    dry_run: bool = False,
    compress: bool = True,
    mode: _ZipFileMode = "w",
) -> _StrPathT: ...
