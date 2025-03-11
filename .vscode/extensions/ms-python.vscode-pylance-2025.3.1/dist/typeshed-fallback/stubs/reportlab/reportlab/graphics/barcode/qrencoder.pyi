from _typeshed import Incomplete

unicode = str

class QR:
    valid: Incomplete
    bits: Incomplete
    group: int
    data: Incomplete
    def __init__(self, data) -> None: ...
    def __len__(self) -> int: ...
    @property
    def bitlength(self): ...
    def getLengthBits(self, ver): ...
    def getLength(self): ...
    def write_header(self, buffer, version) -> None: ...
    def write(self, buffer, version) -> None: ...

class QRNumber(QR):
    valid: Incomplete
    chars: str
    bits: Incomplete
    group: int
    mode: int
    lengthbits: Incomplete

class QRAlphaNum(QR):
    valid: Incomplete
    chars: str
    bits: Incomplete
    group: int
    mode: int
    lengthbits: Incomplete

class QR8bitByte(QR):
    bits: Incomplete
    group: int
    mode: int
    lengthbits: Incomplete
    data: Incomplete
    def __init__(self, data) -> None: ...
    def write(self, buffer, version) -> None: ...

class QRKanji(QR):
    bits: Incomplete
    group: int
    mode: int
    lengthbits: Incomplete
    data: Incomplete
    def __init__(self, data) -> None: ...
    def unicode_to_qrkanji(self, data): ...
    def write(self, buffer, version) -> None: ...

class QRHanzi(QR):
    bits: Incomplete
    group: int
    mode: int
    lengthbits: Incomplete
    data: Incomplete
    def __init__(self, data) -> None: ...
    def unicode_to_qrhanzi(self, data): ...
    def write_header(self, buffer, version) -> None: ...
    def write(self, buffer, version) -> None: ...

class QRECI(QR):
    mode: int
    lengthbits: Incomplete
    data: Incomplete
    def __init__(self, data) -> None: ...
    def write(self, buffer, version) -> None: ...

class QRStructAppend(QR):
    mode: int
    lengthbits: Incomplete
    part: Incomplete
    total: Incomplete
    parity: Incomplete
    def __init__(self, part, total, parity) -> None: ...
    def write(self, buffer, version) -> None: ...

class QRFNC1First(QR):
    mode: int
    lengthbits: Incomplete
    def __init__(self) -> None: ...
    def write(self, buffer, version) -> None: ...

class QRFNC1Second(QR):
    valid: Incomplete
    mode: int
    lengthbits: Incomplete
    def write(self, buffer, version) -> None: ...

class QRCode:
    version: Incomplete
    errorCorrectLevel: Incomplete
    modules: Incomplete
    moduleCount: int
    dataCache: Incomplete
    dataList: Incomplete
    def __init__(self, version, errorCorrectLevel) -> None: ...
    def addData(self, data) -> None: ...
    def isDark(self, row, col): ...
    def getModuleCount(self): ...
    def calculate_version(self): ...
    def make(self) -> None: ...
    def makeImpl(self, test, maskPattern) -> None: ...
    def setupPositionProbePattern(self, row, col) -> None: ...
    def getBestMaskPattern(self): ...
    def setupTimingPattern(self) -> None: ...
    def setupPositionAdjustPattern(self) -> None: ...
    def setupTypeNumber(self, test) -> None: ...
    def setupTypeInfo(self, test, maskPattern) -> None: ...
    def dataPosIterator(self): ...
    def dataBitIterator(self, data): ...
    def mapData(self, data, maskPattern) -> None: ...
    PAD0: int
    PAD1: int
    @staticmethod
    def createData(version, errorCorrectLevel, dataList): ...
    @staticmethod
    def createBytes(buffer, rsBlocks): ...

class QRErrorCorrectLevel:
    L: int
    M: int
    Q: int
    H: int

class QRMaskPattern:
    PATTERN000: int
    PATTERN001: int
    PATTERN010: int
    PATTERN011: int
    PATTERN100: int
    PATTERN101: int
    PATTERN110: int
    PATTERN111: int

class QRUtil:
    PATTERN_POSITION_TABLE: Incomplete
    G15: Incomplete
    G18: Incomplete
    G15_MASK: Incomplete
    @staticmethod
    def getBCHTypeInfo(data): ...
    @staticmethod
    def getBCHTypeNumber(data): ...
    @staticmethod
    def getBCHDigit(data): ...
    @staticmethod
    def getPatternPosition(version): ...
    maskPattern: Incomplete
    @classmethod
    def getMask(cls, maskPattern): ...
    @staticmethod
    def getErrorCorrectPolynomial(errorCorrectLength): ...
    @classmethod
    def maskScoreRule1vert(cls, modules): ...
    @classmethod
    def maskScoreRule2(cls, modules): ...
    @classmethod
    def maskScoreRule3hor(cls, modules, pattern=...): ...
    @classmethod
    def maskScoreRule4(cls, modules): ...
    @classmethod
    def getLostPoint(cls, qrCode): ...

class QRMath:
    @staticmethod
    def glog(n): ...
    @staticmethod
    def gexp(n): ...

EXP_TABLE: Incomplete
LOG_TABLE: Incomplete

class QRPolynomial:
    num: Incomplete
    def __init__(self, num, shift) -> None: ...
    def get(self, index): ...
    def getLength(self): ...
    def multiply(self, e): ...
    def mod(self, e): ...

class QRRSBlock:
    RS_BLOCK_TABLE: Incomplete
    totalCount: Incomplete
    dataCount: Incomplete
    def __init__(self, totalCount, dataCount) -> None: ...
    @staticmethod
    def getRSBlocks(version, errorCorrectLevel): ...
    @staticmethod
    def getRsBlockTable(version, errorCorrectLevel): ...

class QRBitBuffer:
    buffer: Incomplete
    length: int
    def __init__(self) -> None: ...
    def get(self, index): ...
    def put(self, num, length) -> None: ...
    def getLengthInBits(self): ...
    def putBit(self, bit) -> None: ...
