ifndef _CFile_
_CString_ equ 1

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


.code
; --=====================================================================================--
; destructor METHOD BEHAVIOR
; --=====================================================================================--
CFile_Destructor PROC uses rdi r15 lpTHIS:QWORD 
	; Stack alignment
	mov r15, rsp
	sub rsp, 8*4	; Shallow space for Win32 API x64 calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls
	mov rdi, lpTHIS

	; http://masm32.com/board/index.php?topic=7210.0
	mov rcx, (CFile PTR[rdi]).hFile
	cmp rcx, NULL
	je next01
	call CloseHandle
	
	next01:
	mov rcx, (CFile PTR[rdi]).ptrHeapText
	cmp rcx, NULL
	je next02
	call GlobalFree
	next02:   
	
	add rsp, r15	; Restore the stack pointer to point to the return address
	ret
CFile_Destructor ENDP

CString_ConcatA proc uses rsi rdi, pDst:PTR BYTE, pSrc:PTR BYTE
	cld	; clear direction flag so that movsb increments rci and rdi
	mov rsi, pSrc
	mov rdi, pDst

	; move rdi to the end of the string
	CString_ConcatA_Start_Loop1:
		cmp BYTE PTR [rdi], 0
		je CString_ConcatA_Exit_Loop1
		inc rdi
		jmp CString_ConcatA_Start_Loop1
	CString_ConcatA_Exit_Loop1:
	;.while BYTE PTR [rdi] != 0
	;	inc rdi
	;.endw 
	
	; copy rsi into rdi
	CString_ConcatA_Start_Loop2:
		cmp BYTE PTR [rsi], 0
		je CString_ConcatA_Exit_Loop2
		movsb
		jmp CString_ConcatA_Start_Loop2
	CString_ConcatA_Exit_Loop2:
	;.while BYTE PTR [rsi] != 0
	;	movsb
	;.endw 
	
	mov BYTE PTR [rdi], 0 ; Mark end of string
	
	ret
CString_ConcatA endp	

CString_ConcatW proc uses rsi rdi, pDst:PTR WORD, pSrc:PTR WORD
	cld
	mov rsi, pSrc
	mov rdi, pDst

	; move rdi to the end of the string
	CString_ConcatW_Start_Loop1:
		cmp WORD PTR [rdi], 0
		je CString_ConcatW_Exit_Loop1
		add rdi, 2
		jmp CString_ConcatW_Start_Loop1
	CString_ConcatW_Exit_Loop1:
	;.while WORD PTR [rdi] != 0
	;	add rdi, 2
	;.endw 
	
	; copy rsi into rdi
	CString_ConcatW_Start_Loop2:
		cmp WORD PTR [rsi], 0
		je CString_ConcatW_Exit_Loop2
		movsw
		jmp CString_ConcatW_Start_Loop2
	CString_ConcatW_Exit_Loop2:
	;.while WORD PTR [rsi] != 0
	;	movsb
	;.endw 
	
	mov WORD PTR [rdi], 0 ; Mark end of string
	
	ret
CString_ConcatW endp	

CString_CopyA 	proc uses rsi rdi, pDst:PTR BYTE, pSrc:PTR BYTE
	cld
	mov rsi, pSrc
	mov rdi, pDst

	; copy rsi into rdi
	CString_CopyA_Start_Loop1:
		cmp BYTE PTR [rsi], 0
		je CString_CopyA_Exit_Loop1
		movsb
		jmp CString_CopyA_Start_Loop1
	CString_CopyA_Exit_Loop1:
	;.while BYTE PTR [rsi] != 0
	;	movsb
	;.endw 
	
	mov BYTE PTR [rdi], 0 ; Mark end of string
	
	ret
CString_CopyA 	endp

CString_CopyW 	proc uses rsi rdi, pDst:PTR WORD, pSrc:PTR WORD
	cld
	mov rsi, pSrc
	mov rdi, pDst

	; copy rsi into rdi
	CString_CopyW_Start_Loop1:
		cmp WORD PTR [rsi], 0
		je CString_CopyW_Exit_Loop1
		movsw
		jmp CString_CopyW_Start_Loop1
	CString_CopyW_Exit_Loop1:
	;.while WORD PTR [rsi] != 0
	;	movsb
	;.endw 
	
	mov WORD PTR [rdi], 0 ; Mark end of string
	
	ret
CString_CopyW 	endp


CString_LengthA proc uses rsi, pSrc:PTR BYTE	
	xor rax, rax
	mov rsi, pSrc

	CString_LengthA_Start_Loop1:
		cmp BYTE PTR [rsi], 0
		je CString_LengthA_Exit_Loop1
		inc rsi
		inc rax
		jmp CString_LengthA_Start_Loop1
	CString_LengthA_Exit_Loop1:
	;.while BYTE PTR [rsi] != 0
	;	inc rsi
	;	inc rax
	;.endw 
	
	ret
CString_LengthA 	endp

CString_LengthW proc uses rsi, pSrc:PTR WORD
	xor rax, rax
	mov rsi, pSrc

	CString_LengthW_Start_Loop1:
		cmp WORD PTR [rsi], 0
		je CString_LengthW_Exit_Loop1
		add rsi, 2
		inc rax
		jmp CString_LengthW_Start_Loop1
	CString_LengthW_Exit_Loop1:
	;.while BYTE WORD [rsi] != 0
	;	add rsi, 2
	;	inc rax
	;.endw 
	
	ret
CString_LengthW 	endp

ENDIF