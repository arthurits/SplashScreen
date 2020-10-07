
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
	ConvertToLine		QWORD	?
	GetLine			QWORD	?
	hFile			QWORD	?
	ptrHeapText		QWORD	?
	ptrLine			QWORD	?
	bytesRead		QWORD	?
	EndOfFile		WORD	?
	
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
	  QWORD	0, 0, 0, 0
	  WORD	0
	  
   CFile_initend equ $-CFile_initdata

;UCSTR fileName2, "C:\Users\AlfredoA\Documents\Visual Studio 2015\Projects\SplashScreen\MASM x86\Debug\prueba.txt",0
;UCSTR fileName2, "C:\Users\AlfredoA\Documents\Visual Studio 2015\Projects\SplashScreen\MASM x86\Debug\prueba2.txt",0
fileSize2 LARGE_INTEGER <>

.const 
MAXSIZE equ 260
MEMSIZE equ 65535

.data?
SizeReadWrite2 QWORD ?	; number of bytes actually read or written

.code
; --=====================================================================================--
; CLASS CONSTRUCTOR
; --=====================================================================================--
CFile_Init  PROC uses rsi rdi lpTHIS:QWORD
	;SET_CLASS CFile
	;CFile_initsize equ sizeof CFile

	cld 
	
	; Asign the class methods to pointer lpTHIS
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

   ret
CFile_Init ENDP

; --=====================================================================================--
; destructor METHOD BEHAVIOR
; --=====================================================================================--
CFile_Destructor PROC uses rdi lpTHIS:QWORD 
	; Stack alignment
	sub rsp, 8*4	; Shallow space for Win64 calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits
	;mov r15, rbp
	;sub r15, rsp	; The difference rbp-rsp will be added to rsp at the end of the procedure
	
	mov rdi, lpTHIS
	; http://masm32.com/board/index.php?topic=7210.0
	mov rcx, (CFile ptr[rdi]).hFile
	cmp rcx, NULL
	je next01
	call CloseHandle
	
	next01:
	mov rcx, (CFile ptr[rdi]).ptrHeapText
	cmp rcx, NULL
	je next02
	call GlobalFree
	next02:   
	
	;add rsp, r15	; Restore the stack pointer to point to the return address
	ret
CFile_Destructor ENDP

;--------------------------------------------------------
CFile_OpenFile PROC uses rdi lpTHIS:QWORD, lpszFileName:QWORD
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
	;mov r15, rbp
	;sub r15, rsp	; The difference rbp-rsp will be added to rsp at the end of the procedure

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
	mov (CFile ptr[rdi]).hFile, rax

	mov rdx, offset fileSize2
	mov rcx, rax
	call GetFileSizeEx
	;invoke GetFileSizeEx, [edi].handle, ADDR fileSize2
	mov eax, fileSize2.LowPart
	inc rax						; One bit for the NULL terminated
	mov r10, rax
	mov (CFile ptr[rdi]).bytesRead, r10		; Save the size in the in-memory struct

	mov rdx, rax
	mov rcx, GMEM_MOVEABLE or GMEM_ZEROINIT
	call GlobalAlloc
	;invoke GlobalAlloc, GMEM_MOVEABLE or GMEM_ZEROINIT, eax
	mov hGLOBAL, rax
	mov rcx, rax
	call GlobalLock
	mov lpGLOBAL, rax

	mov DWORD PTR [rsp+32], NULL
	lea r9, SizeReadWrite2
	mov r8d, fileSize2.LowPart
	mov rdx, rax
	mov rcx, (CFile ptr[rdi]).hFile
	call ReadFile
	;invoke ReadFile, [edi].handle, lpGLOBAL, fileSize2.LowPart, ADDR SizeReadWrite2, NULL
	;mov DWORD PTR [ebp-8], eax
	mov rcx, (CFile ptr[rdi]).hFile
	call CloseHandle
	cmp rax, 0
	jne end_if
		mov (CFile ptr[rdi]).hFile, 0
	end_if:


	; Convert text from byte to word (Unicode)
	mov rdx, (CFile ptr[rdi]).bytesRead
	shl rdx, 1		;Multiply by 2 in order to convert from char to wchar
	mov rcx, GMEM_ZEROINIT
	call GlobalAlloc
	;invoke GlobalAlloc, GMEM_ZEROINIT, eax
	;mov pMemoryW,eax
	mov (CFile ptr[rdi]).ptrHeapText, rax
	mov (CFile ptr[rdi]).ptrLine, rax

	; Convert byte string to word string
	mov DWORD PTR [rsp+40], NULL
	mov rax, (CFile ptr[rdi]).ptrHeapText
	mov QWORD PTR [rsp+32], rax
	mov r9, -1
	mov r8, lpGLOBAL
	mov rdx, NULL
	mov rcx, CP_UTF8
	call MultiByteToWideChar	; Returns the size, in characters, of the buffer indicated by [rsp+32]
	;invoke MultiByteToWideChar, CP_UTF8, 0, DWORD PTR [ebp-8], -1, [edi].ptrHeapText, 0
	mov QWORD PTR [rsp+40], rax
	;mov QWORD PTR [rsp+32], (CFile ptr[rdi]).ptrHeapText
	mov r9, -1
	mov r8, lpGLOBAL
	mov rdx, NULL
	mov rcx, CP_UTF8
	call MultiByteToWideChar
	;invoke MultiByteToWideChar, CP_UTF8, 0, DWORD PTR [ebp-8], -1, [edi].ptrHeapText, [edi].bytesRead
	;invoke MultiByteToWideChar, CP_UTF8, 0, DWORD PTR [ebp-8], -1, [edi].ptrHeapText, eax

	;print [edi].ptrHeapText
	mov		r9, NULL
	mov		r8, (CFile ptr[rdi]).ptrLine
	mov		rdx, (CFile ptr[rdi]).ptrHeapText
	mov		rcx, NULL
	call	MessageBox

	; Release heap memory
	mov rcx, lpGLOBAL
	call GlobalUnlock
	mov rcx, hGLOBAL
	call GlobalFree

	;add rsp, r15	; Restore the stack pointer to point to the return address

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
CFile_ConvertToLine PROC uses rcx rdi rsi lpTHIS:QWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	
	mov rdi, lpTHIS		; get the parameter passed on the stack to the function

	mov rcx, (CFile ptr[rdi]).bytesRead
	mov rsi, (CFile ptr[rdi]).ptrHeapText

	loop_ConvertToLine:
		mov   ax, WORD PTR [rsi]
		cmp ax, 13		; If ax==13
		jne CFile_ConvertToLine_False_01
			mov WORD PTR [rsi], 0		; True
		CFile_ConvertToLine_False_01:	; False
        add     rsi, 2
    loop    loop_ConvertToLine

	ret
CFile_ConvertToLine ENDP

CFile_GetLine PROC uses rcx rdi rsi lpTHIS:QWORD
	
	mov rdi, lpTHIS		; get the parameter passed on the stack to the function

	mov	rsi, (CFile ptr[rdi]).ptrLine
	;mov ecx, [edi].ptrHeapText
	;sub ecx, esi
	;shr ecx, 1
	;add ecx, [edi].bytesRead

	mov rcx, (CFile ptr[rdi]).bytesRead
	shl rcx, 1	;multiply by 2 since we are using Words for each character
	add rcx, (CFile ptr[rdi]).ptrHeapText
	sub rcx, rsi
	shr rcx, 1	;divide by 2 to get the number of characters

	; If we are at the beginning of the text, just return the address
	cmp rsi, (CFile ptr[rdi]).ptrHeapText	; .IF (esi == [edi].ptrHeapText)
	jne CFile_GetLine_False_01
		mov eax, esi						; True
		add esi, 2
		jmp exit_GetLine
	CFile_GetLine_False_01:					; False

	iterate:
	mov ax, WORD PTR [rsi]
	cmp ax, 0	; .IF (eax==0)
	jne CFile_GetLine_False_02
		cmp rcx, 1		; If we are at the end (ax==0), return NULL
		jne CFile_GetLine_False_03
			xor rax, rax
			jmp exit_GetLine
		CFile_GetLine_False_03:
			add rsi, 4	; Move 2+2 (Chr 13 + chr 10)
			mov rax, rsi
			jmp exit_GetLine
	CFile_GetLine_False_02:
		add rsi, 2		; Move to the next character
	loop iterate

	exit_GetLine:
	;If we are at the end, just reset the Line pointer to the beginning of the text
	cmp rcx, 1		; .IF ecx== 1
	jne CFile_GetLine_False_04
		mov rcx, (CFile ptr[rdi]).ptrHeapText 
		mov (CFile ptr[rdi]).ptrLine, rcx
		jmp CFile_GetLine_EndIf_04
	CFile_GetLine_False_04:
		mov (CFile ptr[rdi]).ptrLine, rsi
	CFile_GetLine_EndIf_04:

	ret
CFile_GetLine ENDP

ENDIF