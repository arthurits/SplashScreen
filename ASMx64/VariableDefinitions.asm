
; ************************** win64 equates ********************************
TRUE	equ	1
FALSE	equ	0
NULL	equ	0

MB_OK           equ 0h
MB_OKCANCEL     equ 1h
MB_ICONERROR	equ 10h

INVALID_FILE_ATTRIBUTES     equ	-1 ;0FFFFFFFFh
FILE_ATTRIBUTE_DIRECTORY	equ	10h

ERROR_SUCCESS           equ 0
ERROR_ALREADY_EXISTS    equ 183

; CreateFile constants
GENERIC_READ		equ 80000000h
GENERIC_WRITE		equ 40000000h
FILE_SHARE_READ		equ 1h
FILE_SHARE_WRITE	equ	2h
OPEN_EXISTING		equ	3h
FILE_ATTRIBUTE_ARCHIVE	equ	20h

; GlobalAlloc constants
GMEM_MOVEABLE		equ 2h
GMEM_ZEROINIT		equ 40h

; MultiByteToWideChar
CP_UTF8				equ 65001	; UTF-8 translation

; CoInitialization ole32.dll
S_OK        equ 0h
COINIT_APARTMENTTHREADED   equ 2h
COINIT_DISABLE_OLE1DDE      equ 4h


; ************************** win64 types ********************************
IFDEF __UNICODE__
    TCHAR                       typedef WORD
ELSE
    TCHAR                       typedef BYTE
ENDIF

PPROC	typedef PTR PROC
DebugEventProc TYPEDEF PTR

HRESULT     TYPEDEF DWORD
COLORREF    TYPEDEF	DWORD
BOOL        TYPEDEF DWORD
DWORD32     TYPEDEF DWORD
INT32       TYPEDEF DWORD
UINT32      TYPEDEF DWORD
LONG        TYPEDEF DWORD

HANDLE  TYPEDEF QWORD
HDC     TYPEDEF QWORD
HMODULE	typedef	QWORD
HINSTANCE   TYPEDEF QWORD
LPVOID      TYPEDEF QWORD
LPCSTR	typedef	QWORD
LPCWSTR	typedef	QWORD
LPCTSTR	typedef QWORD

; ************************** Win64 structs ********************************
LARGE_INTEGER UNION
	STRUCT
		LowPart  DWORD ?
		HighPart DWORD ?
	ENDS
	QuadPart QWORD ?
LARGE_INTEGER ENDS

BLENDFUNCTION STRUCT
    BlendOp             BYTE ?
    BlendFlags          BYTE ?
    SourceConstantAlpha BYTE ?
    AlphaFormat         BYTE ?
BLENDFUNCTION ENDS

GdiplusStartupInput STRUCT
    GdiplusVersion              UINT32 ?
                                DWORD ?
    DebugEventCallback          DebugEventProc ?
    SuppressBackgroundThread    BOOL ?
    SuppressExternalCodecs      BOOL ?
GdiplusStartupInput ENDS

BITMAP STRUCT
    bmType          LONG ?
    bmWidth         LONG ?
    bmHeight        LONG ?
    bmWidthBytes    LONG ?
    mPlanes         WORD ?
    mBitsPixel      WORD ?
                    DWORD ?
    mBits           LPVOID ?
BITMAP ENDS