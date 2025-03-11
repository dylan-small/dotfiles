from _typeshed import Unused
from typing import Final

from Xlib.display import Display
from Xlib.protocol import rq
from Xlib.xobject import drawable, resource

extname: Final = "XINERAMA"

class QueryVersion(rq.ReplyRequest): ...

def query_version(self: Display | resource.Resource) -> QueryVersion: ...

class GetState(rq.ReplyRequest): ...

def get_state(self: drawable.Window) -> GetState: ...

class GetScreenCount(rq.ReplyRequest): ...

def get_screen_count(self: drawable.Window) -> GetScreenCount: ...

class GetScreenSize(rq.ReplyRequest): ...

def get_screen_size(self: drawable.Window, screen_no: int) -> GetScreenSize: ...

class IsActive(rq.ReplyRequest): ...

def is_active(self: Display | resource.Resource) -> int: ...

class QueryScreens(rq.ReplyRequest): ...

def query_screens(self: Display | resource.Resource) -> QueryScreens: ...

class GetInfo(rq.ReplyRequest): ...

def get_info(self: Display | resource.Resource, visual: int) -> None: ...
def init(disp: Display, info: Unused) -> None: ...
