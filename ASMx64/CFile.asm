
ifndef __UNICODE__
__UNICODE__ equ 1
endif

ifndef _CFile_
_CFile_ equ 1


;include C:\masm32\include\windows.inc
;include C:\masm32\include\user32.inc 
;include C:\masm32\include\kernel32.inc 
;include C:\masm32\include\comdlg32.inc
;include C:\masm32\include\masm32.inc
;include C:\masm32\include\msvcrt.inc 

;include C:\masm32\macros\macros.asm

;includelib C:\masm32\lib\masm32.lib

;includelib C:\masm32\lib\user32.lib 
;includelib C:\masm32\lib\kernel32.lib 
;includelib C:\masm32\lib\comdlg32.lib
;includelib C:\masm32\lib\msvcrt.lib

; NEWOBJECT ClassName, Param1
; mov hNewObject, eax
;	 invoke GetProcessHeap
;    invoke HeapAlloc, eax, NULL, SIZEOF CFile
;    push   eax
;    invoke CFile_Init, eax
;    pop    eax
;
;

; --=====================================================================================--
; CLASS METHOD PROTOS
; --=====================================================================================--
   CFile_Init    PROTO :QWORD
   CFile_OpenFile	PROTO :QWORD, :QWORD
   CFile_CloseFile	PROTO :QWORD
   CFile_Dispose	PROTO :QWORD

; --=====================================================================================--
; FUNCTION POINTER PROTOS
; --=====================================================================================--
   CFile_destructorPto    TYPEDEF  PROTO  :QWORD 


   .data?
; --=====================================================================================--
; CLASS STRUCTURE
; --=====================================================================================--
   CFile STRUCT
	Destructor		QWORD	?
	OpenFile		QWORD	?
	CloseFile		QWORD	?
	Dispose			QWORD	?
	ConvertToLine	QWORD	?
	GetLine			QWORD	?
	EndOfFile		WORD	?
	handle			QWORD	?
	ptrHeapText		QWORD	?
	ptrLine			QWORD	?
	bytesRead		QWORD	?

   CFile ENDS

   ;CFile_initsize equ sizeof CFile

.data

   CFile_initdata LABEL BYTE
      QWORD OFFSET CFile_Destructor
	  QWORD OFFSET CFile_OpenFile
	  QWORD OFFSET CFile_CloseFile
	  QWORD OFFSET CFile_Dispose
	  QWORD OFFSET CFile_ConvertToLine
	  QWORD OFFSET CFile_GetLine
	WORD	0
	QWORD	0, 0, 0, 0
   CFile_initend equ $-CFile_initdata

;UCSTR fileName2, "C:\Users\AlfredoA\Documents\Visual Studio 2015\Projects\SplashScreen\ASM x86\Debug\prueba.txt",0
;UCSTR fileName2, "C:\Users\AlfredoA\Documents\Visual Studio 2015\Projects\SplashScreen\ASM x86\Debug\prueba2.txt",0
fileSize2 LARGE_INTEGER <>

.const 
MAXSIZE equ 260
MEMSIZE equ 65535

.data?
SizeReadWrite2 QWORD ?	; number of bytes actually read or write

.code
; --=====================================================================================--
; CLASS CONSTRUCTOR
; --=====================================================================================--
CFile_Init  PROC lpTHIS:QWORD
	;SET_CLASS CFile
	;CFile_initsize equ sizeof CFile

	push    rsi
	push    rdi
	push	rcx
	cld 
	
	; asign the class methods to pointer lpTHIS
	mov 	rsi, offset CFile_initdata
	mov 	rdi, lpTHIS
	mov 	rcx, CFile_initend
	shr 	rcx, 2
	rep 	movsq
	mov 	rcx, CFile_initend
	and 	rcx, 7
	rep 	movsb

	mov  rdi, lpTHIS
	;assume rdi:PTR CFile
	;Initialization code
	;assume rdi:nothing

	pop		rcx
	pop		rdi
	pop		rsi

   ret
CFile_Init ENDP

; --=====================================================================================--
; destructor METHOD BEHAVIOR
; --=====================================================================================--
CFile_Destructor PROC uses rcx rdi lpTHIS:QWORD 
	mov  rdi, lpTHIS
	;assume rdi:PTR CFile

	mov rcx, (CFile ptr[rdi]).handle
	cmp rcx, NULL
	je next01
	call CloseHandle
	
	next01:
	mov rcx, (CFile ptr[rdi]).ptrHeapText
	cmp rcx, NULL
	je next02
	call GlobalFree

	next02:   
	;assume rdi:nothing
   ret
CFile_Destructor ENDP

;--------------------------------------------------------
CFile_OpenFile PROC uses rax rbx rdi lpTHIS:QWORD, lpszFileName:QWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	ret
CFile_OpenFile ENDP

;--------------------------------------------------------
CFile_Dispose PROC uses rdi lpTHIS:QWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	mov rdi, lpTHIS
	;ASSUME edi: PTR CFile
	cmp (CFile ptr[rdi]).ptrHeapText, 0
	je CFile_Dispose_next01
		mov rcx, (CFile ptr[rdi]).ptrHeapText
		call GlobalFree
		mov (CFile ptr[rdi]).ptrHeapText, 0
	CFile_Dispose_next01:
	;ASSUME edi: nothing
	ret
CFile_Dispose ENDP

;--------------------------------------------------------
CFile_CloseFile PROC lpTHIS:QWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	mov rdi, lpTHIS
	;ASSUME edi: PTR CFile
	;ASSUME edi: nothing
	ret
CFile_CloseFile ENDP

;--------------------------------------------------------
CFile_ConvertToLine PROC uses rax rdi rsi lpTHIS:QWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	mov rdi, lpTHIS		; get the parameter passed on the stack to the function

	ret
CFile_ConvertToLine ENDP

CFile_GetLine PROC uses rcx rdi rsi lpTHIS:QWORD
	mov rdi, lpTHIS		; get the parameter passed on the stack to the function

	ret
CFile_GetLine ENDP

ENDIF