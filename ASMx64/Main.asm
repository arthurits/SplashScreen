;.686
;.MMX
;.XMM
;.model flat,stdcall
;.stack 4096
;option casemap:none

ifndef __UNICODE__
__UNICODE__ equ 1
endif

include invoke_macros.asm
;include C:\masm32\include64\masm64rt.inc
include VariableDefinitions.asm
include FunctionProtos.asm
include CFile.asm

.data
	;fileName  WORD "s", "e", "t", "t", "i", "n", "g", "s", ".", "t", "x", "t", 0
	fileName	WORD "C", ":", "\", "U", "s", "e", "r", "s", "\"
			WORD "A", "r", "t", "h", "u", "r", "i", "t", "\"
			WORD "D", "o", "c", "u", "m", "e", "n", "t", "s", "\"
			WORD "V", "i", "s", "u", "a", "l", " ", "S", "t", "u", "d", "i", "o", " ", "2", "0", "1", "7", "\"
			WORD "P", "r", "o", "j", "e", "c", "t", "s", "\"
			WORD "S", "p", "l", "a", "s", "h", "S", "c", "r", "e", "e", "n", "\"
			WORD "A", "S", "M", "x", "6", "4", "\", "x", "6", "4", "\", "D", "e", "b", "u", "g", "\", "s", "e", "t", "t", "i", "n", "g", "s", ".", "t", "x", "t", 0
	;fileName	WORD "C", ":", "\", "U", "s", "e", "r", "s", "\"
	;		WORD "a", "l", "f", "r", "e", "d", "o", "a", "\"
	;		WORD "s", "o", "u", "r", "c", "e", "\"
	;		WORD "r", "e", "p", "o", "s", "\"
	;		WORD "S", "p", "l", "a", "s", "h", "S", "c", "r", "e", "e", "n", "\"
	;		WORD "A", "S", "M", "x", "6", "4", "\", "x", "6", "4", "\", "D", "e", "b", "u", "g", "\", "s", "e", "t", "t", "i", "n", "g", "s", ".", "t", "x", "t", 0

	;UCSTR fileName, "settings.txt", 0
	ErrorSettings BYTE "An unexpected error ocurred while reading 'settings.txt'.", 13, 10, "Please make sure the file and format are correct.", 0
	ErrorApp BYTE "Could not find the file in the following path:", 13, 10, 0

	hdlModule	HMODULE	NULL
	file		QWORD	NULL

.code
main proc
	sub rsp, 8	; align stack to 16 bits boundary
	sub rsp, 32	; save 32 bits for shallow space

	; Get the current handle
	mov rcx, NULL
	call GetModuleHandleW
	mov hdlModule, rax
	cmp rax, NULL
	je exit_main

	; If settings.txt doesn't exist, then exit the program
	mov rcx, OFFSET fileName
	call GetFileAttributesW
	cmp eax, INVALID_FILE_ATTRIBUTES	;.IF ( rax == INVALID_FILE_ATTRIBUTES or FILE_ATTRIBUTE_DIRECTORY )	; 0FFFFFFFF
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
	push rax
	call CFile_Init
	pop rax

	lea rcx, offset fileName
	push rcx
	push rax
	call CFile_OpenFile
	add rsp, 16


	exit_main_deallocate:
		; If a CFile instance was succesffully created, first call the CFile desturctor
		cmp file, NULL
		je exit_main
		mov rax, file
		push rax
		call QWORD PTR [rax]
		add rsp, 8

		; Then destroy instance from heap
		call GetProcessHeap
		mov rcx, rax	; ProcessHeap
		mov rdx, NULL
		mov r8, file	; file
		call HeapFree	; Arguments: ProcessHeap, NULL, file

	; Exit
	exit_main:
		mov   rcx, 0
		call ExitProcess
	;invoke ExitProcess, rcx

main endp
end
