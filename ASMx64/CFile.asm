
ifndef __UNICODE__
__UNICODE__ equ 1
endif

ifndef _CFile_
_CFile_ equ 1

;rax, rcx, rdx, r8-r11 are volatile.
;rbx, rbp, rdi, rsi, r12-r15 are nonvolatile.

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
CFile_Init  PROC uses rsi rdi lpTHIS:QWORD
	;SET_CLASS CFile
	;CFile_initsize equ sizeof CFile

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

	;pop		rcx
	;pop		rdi
	;pop		rsi

   ret
CFile_Init ENDP

; --=====================================================================================--
; destructor METHOD BEHAVIOR
; --=====================================================================================--
CFile_Destructor PROC uses rdi rbx lpTHIS:QWORD 
	; Stack alignment
	xor r10, r10
	mov r10b, spl	; Align to 16 bits if needed
	and r10, 0Fh		; Get the lower bit: this is always either 8 or 0
	add r10, 32		; Allow 32 bits of shallow space
	sub rsp, r10	
	
	mov  rdi, lpTHIS

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
	
	; Restore the stack pointer to point to the return address
	add rsp, r10
	ret
CFile_Destructor ENDP

;--------------------------------------------------------
CFile_OpenFile PROC uses rbx rdi lpTHIS:QWORD, lpszFileName:QWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	LOCAL hGLOBAL: QWORD
	LOCAL lpGLOBAL: QWORD

	sub rsp, 8 * 7	; Shallow space for Win64 calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits
	mov rbx, rbp
	sub ebx, esp	; The difference rsp-rbp will be added to rsp at the end of the procedure

	;xor r10, r10
	;mov r10b, spl	; Align to 16 bits if needed
	;and r10, Fh		; Get the lower bit: this is always either 8 or 0
	;add r10, 8*7		; Allow 64 bits of shallow space
	;and r10, -8h	; Add 8 bits if needed to align to 16 bits
	;sub rsp, r10

	mov rdi, lpTHIS

	mov	DWORD PTR [rsp+48], NULL
	mov	DWORD PTR [rsp+40], FILE_ATTRIBUTE_ARCHIVE
	mov	DWORD PTR [rsp+32], OPEN_EXISTING
	mov r9, NULL
	mov r8, FILE_SHARE_READ or FILE_SHARE_WRITE
	mov rdx, GENERIC_READ or GENERIC_WRITE
	mov rcx, lpszFileName
	call CreateFile
	;invoke CreateFile, lpszFileName, GENERIC_READ or GENERIC_WRITE, FILE_SHARE_READ or FILE_SHARE_WRITE, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_ARCHIVE, NULL 
	;mov edx, eax
	mov (CFile ptr[rdi]).handle, rax

	mov rdx, offset fileSize2
	mov rcx, rax
	call GetFileSizeEx
	;invoke GetFileSizeEx, [edi].handle, ADDR fileSize2
	mov eax, fileSize2.LowPart
	inc rax						; One bit for the NULL terminated
	mov rbx, rax
	mov (CFile ptr[rdi]).bytesRead, rbx		; Save the size in the in-memory struct

	mov rdx, rax
	mov rcx, GMEM_MOVEABLE or GMEM_ZEROINIT
	call GlobalAlloc
	;invoke GlobalAlloc, GMEM_MOVEABLE or GMEM_ZEROINIT, eax
	mov HGLOBAL, rax
	mov rcx, rax
	call GlobalLock
	mov lpGLOBAL, rax

	mov DWORD PTR [rsp+32], NULL
	lea r9, SizeReadWrite2
	mov r8d, fileSize2.LowPart
	mov rdx, rax
	mov rcx, (CFile ptr[rdi]).handle
	call ReadFile
	;invoke ReadFile, [edi].handle, lpGLOBAL, fileSize2.LowPart, ADDR SizeReadWrite2, NULL
	;mov DWORD PTR [ebp-8], eax
	mov rcx, (CFile ptr[rdi]).handle
	call CloseHandle
	cmp rax, 0
	jne end_if
		mov (CFile ptr[rdi]).handle, 0
	end_if:

	mov rcx, lpGLOBAL
	call GlobalUnlock
	mov rcx, hGLOBAL
	call GlobalFree

	add rsp, rbx	; Restore the stack

	ret
CFile_OpenFile ENDP

;--------------------------------------------------------
CFile_Dispose PROC uses rdi rbx lpTHIS:QWORD
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