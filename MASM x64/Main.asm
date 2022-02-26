;.686
;.MMX
;.XMM
;.model flat,stdcall
;.stack 4096
;option casemap:none

ifndef __UNICODE__
__UNICODE__ equ 1
endif

;include invoke_macros.asm
;include C:\masm32\include64\masm64rt.inc
include VariableDefinitions.asm
include FunctionProtos.asm
include CFile.asm
include CSplashScreen.asm

.data
	fileName  WORD "s", "e", "t", "t", "i", "n", "g", "s", ".", "s", "p", "l", "a", "s", "h", 0
	;UCSTR fileName, "settings.splash", 0
	ErrorSettings BYTE "An unexpected error ocurred while reading 'settings.splash'.", 13, 10, "Please make sure the file and format are correct.", 0
	ErrorApp BYTE "Could not find the file in the following path:", 13, 10, 0

	file			QWORD	NULL
	splash			QWORD	NULL
	nFadeoutTime	QWORD	NULL
	hModuleHandle	QWORD	NULL
	lpszImagePath	LPCTSTR	NULL
	lpszPrefix		LPCTSTR	NULL
	lpszAppFileName	LPCTSTR	NULL

.code
main PROC
	sub rsp, 8	; align stack to 16 bits boundary
	sub rsp, 32	; save 32 bits for shallow space

	; Get the current handle
	mov rcx, NULL
	call GetModuleHandle
	mov hModuleHandle, rax
	cmp rax, NULL
	je exit_main

	; If settings.splash doesn't exist, then exit the program
	mov rcx, OFFSET fileName
	call GetFileAttributes
	cmp rax, INVALID_FILE_ATTRIBUTES	;.IF ( rax == INVALID_FILE_ATTRIBUTES or FILE_ATTRIBUTE_DIRECTORY )	; 0FFFFFFFF
	je next01
	cmp rax, FILE_ATTRIBUTE_DIRECTORY
	jne next02
	next01:
		mov r9, MB_ICONERROR
		mov r8, NULL
		mov rdx, OFFSET ErrorSettings
		mov rcx, NULL
		call MessageBoxA	; https://stackoverflow.com/questions/46439802/multiple-lines-of-output-in-a-message-box-assembly-language
		jmp exit_main
	next02:		; .ENDIF

	; Create CFile instance and call the constructor CFile_Init
	call GetProcessHeap
	mov rcx, rax
	mov rdx, NULL
	mov r8, SIZEOF CFile 
	call HeapAlloc
	mov file, rax
	mov rbx, rax
	mov QWORD PTR [rsp], rbx	; move rax to the first shallow space
	call CFile_Init
	; pop rax	; Not necessary!

	mov rcx, offset fileName
	mov QWORD PTR [rsp+8], rcx	; 2nd argument, move rcx to the 2nd shallow space
	;mov QWORD PTR [rsp], rbx	; move rax to the first shallow space
	call (CFile PTR [rbx]).OpenFile
	; add rsp, 16	; Not necessary!

	;mov QWORD PTR [rsp], rbx	; move rbx to the first shallow space
	call (CFile PTR [rbx]).ConvertToLine	;	invoke (CFile PTR [eax]).OpenFile, eax
	;lea rsp, [rsp+8]	; add rsp, 8

	; Read the first line: the image path
	call (CFile PTR [rbx]).GetLine
	cmp rax, 0
	mov lpszImagePath, rax

	; Read the second line: the application path
	call (CFile PTR [rbx]).GetLine
	cmp rax, 0	; .IF eax!=0
	mov lpszAppFileName, rax
	
	; Read the third line: the fadeout milliseconds
	call (CFile PTR [rbx]).GetLine
	cmp rax, 0	; .IF (eax != 0)
		mov nFadeoutTime, rax
		mov QWORD PTR [rsp], rax	; move rax (nFadeoutTime) to the first shallow space 
		call StringToInt
		mov nFadeoutTime, rax

	; If the application doesn't exist, then exit the program
	mov rcx, lpszAppFileName
	call GetFileAttributes				; invoke GetFileAttributesW, lpszAppFileName
	cmp rax, INVALID_FILE_ATTRIBUTES	; .IF ( eax == INVALID_FILE_ATTRIBUTES or FILE_ATTRIBUTE_DIRECTORY )	; 0FFFFFFFF
	je next03
	cmp rax, FILE_ATTRIBUTE_DIRECTORY
	jne next04
	next03:
		mov r9, MB_ICONERROR
		mov r8, NULL
		mov rdx, OFFSET ErrorApp
		mov rcx, NULL
		call MessageBoxA	; invoke MessageBoxA, NULL, OFFSET ErrorApp, NULL, MB_ICONERROR
		je exit_main_dispose_CFile
	next04:								; .ENDIF

	; Create CSplashScreen instance
	call GetProcessHeap
	mov r8, SIZEOF CSplashScreen
	mov rdx, NULL
	mov rcx, rax
	call HeapAlloc	; invoke HeapAlloc, eax, NULL, SIZEOF CSplashScreen
	mov splash, rax	; THIS pointer
	mov rbx, rax	; save for later
	
	mov rax, nFadeoutTime
	mov QWORD PTR [rsp+32], rax	; 5th argument
	mov rax, lpszAppFileName
	mov QWORD PTR [rsp+24], rax	; 4th argument
	mov rax, lpszImagePath
	mov QWORD PTR [rsp+16], rax	; 3rd argument
	mov rax, hModuleHandle
	mov QWORD PTR [rsp+8], rax	; 2nd argument
	mov QWORD PTR [rsp], rbx	; THIS pointer
	call CSplashScreen_Init
	;add rsp, 32	; we are leaving rax (splash) on the stack for the next call
	
	mov QWORD PTR [rsp], rbx
	call (CSplashScreen PTR [rbx]).Show
	;add rsp, 8	; we now completely clean the stack

	exit_main_dispose_CFile:
		; If a CFile instance was succesffully created, first call the CFile desturctor
		cmp file, NULL
		je exit_main_dispose_CSplashScreen
		mov rax, file
		mov QWORD PTR [rsp], rax
		call QWORD PTR [rax]

		; Then destroy instance from heap
		call GetProcessHeap
		mov rcx, rax	; ProcessHeap
		mov rdx, NULL
		mov r8, file	; file
		call HeapFree	; Arguments: ProcessHeap, NULL, file
		
	exit_main_dispose_CSplashScreen:
		; Destroy CSplash instance from heap
		cmp splash, NULL
		je exit_main
		mov rax, splash
		mov QWORD PTR [rsp], rax
		call QWORD PTR [rax]
		
		call GetProcessHeap
		mov r8, splash
		mov rdx, NULL
		mov rcx, rax
		call HeapFree	; invoke HeapFree, eax, NULL, splash

	; Exit
	exit_main:
		mov   rcx, 0
		call ExitProcess	; invoke ExitProcess, 0

main ENDP


;*************************************************
; Computes the numeric value represented by a Unicode string
; Receives: the address of the null-terminated array of chars in Unicode (2 bytes per char)
; Returns: rax cointains the total numeric value represented by the string
; Preconditions: none
; Registers changed:  rax, rbx, rcx, rdx
; https://stackoverflow.com/questions/13664778/converting-string-to-integer-in-masm-esi-difficulty
;*************************************************
StringToInt PROC uses rbx rcx rsi lpString:QWORD
	xor rax, rax	; Total counter
	xor rbx, rbx	; Char pointer
	mov rcx, 10d	; Decimal factor multiplier
	mov rsi, lpString    ; Point at the beginning of the string

	; Loop through each char in string
	loopString:
		; Check whether we reached the end of the string
		cmp WORD PTR [rsi], 0000h
		je exit_StringToInt

		; Multiply the accumulated quantity by 10
		mul rcx

		; Subtract 48 from ASCII value (number 0) of current char to get integer
		mov     bx, WORD PTR [rsi]
		sub     bx, 0048d        

		; Error checking to ensure values are digits 0-9
		cmp     bx, 0            
		jl      invalidInput
		cmp     bx, 9
		jg      invalidInput

		; If it's a digit, add to the total and go on with the loop
		add     rax, rbx	; Add to total counter
		add     rsi, 2d		; Point to next char (2 bytes per char)
    jmp loopString

	jmp exit_StringToInt

	invalidInput:	; Reset registers and variables to 0
	    mov     rax, 0
	
	exit_StringToInt:
	ret
StringToInt ENDP

END