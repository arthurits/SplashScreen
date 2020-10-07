
;IFDEF WIN32
;   STRUCT_ALIGN   equ 4
;ELSE
;   STRUCT_ALIGN   equ 8
;ENDIF

; ************************** win64 equates ********************************
TRUE	equ	1
FALSE	equ	0
NULL	equ	0
INFINITE    equ -1  ;0FFFFFFFFh

MB_OK           equ 0h
MB_OKCANCEL     equ 1h
MB_ICONERROR	equ 10h

INVALID_FILE_ATTRIBUTES     equ	-1 ;0FFFFFFFFh
FILE_ATTRIBUTE_DIRECTORY	equ	10h

ERROR_SUCCESS           equ 0
ERROR_ALREADY_EXISTS    equ 183

MONITOR_DEFAULTTOPRIMARY 	equ 1

AC_SRC_OVER     equ 00h
AC_SRC_ALPHA    equ 01h
ULW_ALPHA       equ 02h

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

; CreateWindowEx
WS_EX_LAYERED       equ 00080000h
WS_EX_TOOLWINDOW    equ 00000080h
WS_EX_TOPMOST       equ 8h
WS_POPUP            equ 80000000h
WS_VISIBLE          equ 10000000h
SWP_SHOWWINDOW      equ 40h
HWND_TOPMOST        equ -1

; Gdiplus
PixelFormat32bppARGB    EQU 26200Ah

; Messages
WM_DESTROY      equ 2h
WM_PAINT        equ 0Fh
WM_TIMER        equ 113h
WM_QUIT         equ 12h
STATUS_WAIT_0   equ 00000000h
WAIT_OBJECT_0   equ STATUS_WAIT_0
QS_ALLINPUT     equ 4FFh
PM_REMOVE       equ 1h

; ************************** win64 types ********************************
IFDEF __UNICODE__
    TCHAR                       typedef WORD
ELSE
    TCHAR                       typedef BYTE
ENDIF

ATOM    TYPEDEF WORD

PPROC	typedef PTR PROC
DebugEventProc TYPEDEF PTR

HRESULT     TYPEDEF DWORD
COLORREF    TYPEDEF	DWORD
BOOL        TYPEDEF DWORD
DWORD32     TYPEDEF DWORD
INT32       TYPEDEF DWORD
UINT32      TYPEDEF DWORD
LONG        TYPEDEF DWORD

;LPARAM  TYPEDEF QWORD
HWND    TYPEDEF QWORD
;WPARAM  TYPEDEF QWORD
HANDLE  TYPEDEF QWORD
HDC     TYPEDEF QWORD
HMODULE	typedef	QWORD
;HINSTANCE   TYPEDEF QWORD
HBITMAP  TYPEDEF QWORD
HBRUSH  TYPEDEF QWORD
;HCURSOR TYPEDEF QWORD
HMONITOR TYPEDEF QWORD
;HICON   TYPEDEF QWORD
LPHANDLE    TYPEDEF QWORD
LPVOID  TYPEDEF QWORD
PVOID   TYPEDEF QWORD
LPSTR   typedef QWORD
LPCSTR	typedef	QWORD
LPCWSTR	typedef	QWORD
LPCTSTR	typedef QWORD
LPTSTR  typedef QWORD
LPBYTE  typedef QWORD

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

POINT STRUCT
    x  LONG ?
    y  LONG ?
POINT ENDS

_SIZE STRUCT
  x    LONG   ?
  y    LONG   ?
_SIZE ENDS

RECT STRUCT
    left    LONG ?
    top     LONG ?
    right   LONG ?
    bottom  LONG ?
RECT ENDS

MONITORINFO struct
  cbSize    DWORD   ?
  rcMonitor RECT    <>
  rcWork    RECT    <>
  dwFlags   DWORD   ?
MONITORINFO ENDS

MSG STRUCT QWORD
   nHwnd     HWND ?
   message  DWORD ?
   wParam   QWORD ?
   lParam   QWORD ?
   time     DWORD ?
   pt       POINT<>
MSG ENDS

WNDCLASSEX STRUCT
  cbSize            DWORD ?
  style             DWORD ?
  lpfnWndProc       PVOID ?
  cbClsExtra        DWORD ?
  cbWndExtra        DWORD ?
  hInstance         QWORD ?
  hIcon             QWORD ?
  hCursor           QWORD ?
  hbrBackground     HBRUSH ?
  lpszMenuName      LPSTR ?
  lpszClassName     LPSTR ?
  hIconSm           QWORD ?
WNDCLASSEX ENDS

STARTUPINFO STRUCT
     cb             DWORD 2 dup(?)
     lpReserved      LPTSTR ?
     lpDesktop       LPTSTR ?
     lpTitle         LPTSTR ?
     dwX             DWORD ?
     dwY             DWORD ?
     dwXSize         DWORD ?
     dwYSize         DWORD ?
     dwXCountChars   DWORD ?
     dwYCountChars   DWORD ?
     dwFillAttribute DWORD ?
     dwFlags         DWORD ?
     wShowWindow     WORD ?
     cbReserved2     WORD 3 dup(?)
     lpReserved2    LPBYTE ?
     hStdInput      HANDLE ?
     hStdOutput     HANDLE ?
     hStdError      HANDLE ?
STARTUPINFO ENDS

PROCESS_INFORMATION STRUCT
    hProcess        HANDLE ?
    hThread         HANDLE ?
    dwProcessId     DWORD ?
    dwThreadId      DWORD ?
PROCESS_INFORMATION ENDS