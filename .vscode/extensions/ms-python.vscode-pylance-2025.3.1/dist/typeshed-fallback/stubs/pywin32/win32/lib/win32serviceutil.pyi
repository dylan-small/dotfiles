from _typeshed import Incomplete
from collections.abc import Iterable, Sequence

error = RuntimeError

def LocatePythonServiceExe(exe: Incomplete | None = ...): ...
def SmartOpenService(hscm, name, access): ...
def LocateSpecificServiceExe(serviceName): ...
def InstallPerfmonForService(serviceName, iniName, dllName: Incomplete | None = ...) -> None: ...
def InstallService(
    pythonClassString,
    serviceName,
    displayName,
    startType: Incomplete | None = ...,
    errorControl: Incomplete | None = ...,
    bRunInteractive: int = ...,
    serviceDeps: Incomplete | None = ...,
    userName: Incomplete | None = ...,
    password: Incomplete | None = ...,
    exeName: Incomplete | None = ...,
    perfMonIni: Incomplete | None = ...,
    perfMonDll: Incomplete | None = ...,
    exeArgs: Incomplete | None = ...,
    description: Incomplete | None = ...,
    delayedstart: Incomplete | None = ...,
) -> None: ...
def ChangeServiceConfig(
    pythonClassString,
    serviceName,
    startType: Incomplete | None = ...,
    errorControl: Incomplete | None = ...,
    bRunInteractive: int = ...,
    serviceDeps: Incomplete | None = ...,
    userName: Incomplete | None = ...,
    password: Incomplete | None = ...,
    exeName: Incomplete | None = ...,
    displayName: Incomplete | None = ...,
    perfMonIni: Incomplete | None = ...,
    perfMonDll: Incomplete | None = ...,
    exeArgs: Incomplete | None = ...,
    description: Incomplete | None = ...,
    delayedstart: Incomplete | None = ...,
) -> None: ...
def InstallPythonClassString(pythonClassString, serviceName) -> None: ...
def SetServiceCustomOption(serviceName, option, value) -> None: ...
def GetServiceCustomOption(serviceName, option, defaultValue: Incomplete | None = ...): ...
def RemoveService(serviceName) -> None: ...
def ControlService(serviceName, code, machine: Incomplete | None = ...): ...
def WaitForServiceStatus(serviceName, status, waitSecs, machine: Incomplete | None = ...) -> None: ...
def StopServiceWithDeps(serviceName, machine: Incomplete | None = ..., waitSecs: int = ...) -> None: ...
def StopService(serviceName, machine: Incomplete | None = ...): ...
def StartService(serviceName, args: Incomplete | None = ..., machine: Incomplete | None = ...) -> None: ...
def RestartService(
    serviceName, args: Incomplete | None = ..., waitSeconds: int = ..., machine: Incomplete | None = ...
) -> None: ...
def DebugService(cls, argv=...) -> None: ...
def GetServiceClassString(cls, argv: Incomplete | None = ...): ...
def QueryServiceStatus(serviceName, machine: Incomplete | None = ...): ...
def usage() -> None: ...
def HandleCommandLine(
    cls: type[ServiceFramework],
    serviceClassString: Incomplete | None = ...,
    argv: Sequence[str] | None = ...,
    customInstallOptions: str = ...,
    customOptionHandler: Incomplete | None = ...,
): ...

class ServiceFramework:
    ssh: Incomplete
    checkPoint: int
    def __init__(self, args: Iterable[str]) -> None: ...
    def GetAcceptedControls(self): ...
    def ReportServiceStatus(
        self, serviceStatus, waitHint: int = ..., win32ExitCode: int = ..., svcExitCode: int = ...
    ) -> None: ...
    def SvcInterrogate(self) -> None: ...
    def SvcOther(self, control) -> None: ...
    def ServiceCtrlHandler(self, control): ...
    def SvcOtherEx(self, control, event_type, data): ...
    def ServiceCtrlHandlerEx(self, control, event_type, data): ...
    def SvcRun(self) -> None: ...
