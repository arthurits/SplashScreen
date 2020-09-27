
; ************************** win64 equates ********************************
TRUE	equ	1
FALSE	equ	0
NULL	equ	0

MB_ICONERROR	equ 10h

INVALID_FILE_ATTRIBUTES	equ	-1 ;0FFFFFFFFh
FILE_ATTRIBUTE_DIRECTORY	equ	10h

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

; ************************** win64 types ********************************
IFDEF __UNICODE__
    TCHAR                       typedef WORD
ELSE
    TCHAR                       typedef BYTE
ENDIF
PPROC	typedef PTR PROC
COLORREF	typedef	DWORD

HMODULE	typedef	QWORD
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