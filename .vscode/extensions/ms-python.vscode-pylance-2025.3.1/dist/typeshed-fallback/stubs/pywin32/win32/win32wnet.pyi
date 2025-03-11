from _typeshed import Incomplete

import _win32typing
from win32.lib.pywintypes import error as error

def NCBBuffer(size, /): ...
def Netbios(ncb: _win32typing.NCB, /): ...
def WNetAddConnection2(
    NetResource: _win32typing.PyNETRESOURCE,
    Password: Incomplete | None = ...,
    UserName: Incomplete | None = ...,
    Flags: int = ...,
) -> None: ...
def WNetAddConnection3(
    HwndOwner: int | _win32typing.PyHANDLE,
    NetResource: _win32typing.PyNETRESOURCE,
    Password: Incomplete | None = ...,
    UserName: Incomplete | None = ...,
    Flags: int = ...,
) -> None: ...
def WNetCancelConnection2(name: str, flags, force, /) -> None: ...
def WNetOpenEnum(scope, _type, usage, resource: _win32typing.PyNETRESOURCE, /) -> int: ...
def WNetCloseEnum(handle: _win32typing.PyHANDLE, /) -> None: ...
def WNetEnumResource(handle: _win32typing.PyHANDLE, maxExtries: int = ..., /) -> list[_win32typing.PyNETRESOURCE]: ...
def WNetGetUser(connection: str | None = ..., /) -> str: ...
def WNetGetUniversalName(localPath: str, infoLevel, /) -> str: ...
def WNetGetResourceInformation(NetResource: _win32typing.PyNETRESOURCE, /) -> tuple[_win32typing.PyNETRESOURCE, Incomplete]: ...
def WNetGetLastError() -> tuple[Incomplete, Incomplete, Incomplete]: ...
def WNetGetResourceParent(NetResource: _win32typing.PyNETRESOURCE, /) -> _win32typing.PyNETRESOURCE: ...
def WNetGetConnection(connection: str | None = ..., /) -> str: ...

NETRESOURCE = _win32typing.PyNETRESOURCE
NCB = _win32typing.PyNCB
# old "deprecated" names, before types could create instances.
NETRESOURCEType = _win32typing.PyNETRESOURCE
NCBType = _win32typing.PyNCB
