
; ************************** win64 equates ********************************
TRUE	equ	1
FALSE	equ	0
NULL	equ	0

MB_ICONERROR	equ 10h

INVALID_FILE_ATTRIBUTES	equ	-1 ;0FFFFFFFFh
FILE_ATTRIBUTE_DIRECTORY	equ	10h

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

; ************************** Win64 structs ********************************
LARGE_INTEGER UNION
	STRUCT
		LowPart  DWORD ?
		HighPart DWORD ?
	ENDS
	QuadPart QWORD ?
LARGE_INTEGER ENDS