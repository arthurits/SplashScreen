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
	fileName  DWORD "s", "e", "t", "t", "i", "n", "g", "s", ".", "t", "x", "t", 0
	;UCSTR fileName, "settings.txt", 0
	ErrorSettings BYTE "An unexpected error ocurred while reading 'settings.txt'.", 13, 10, "Please make sure the file and format are correct.", 0
	ErrorApp BYTE "Could not find the file in the following path:", 13, 10, 0

	sum qword 0
	MsgCaption db "Iczelion's tutorial #2a",0
	MsgBoxText db "Win64 Assembly is great!",0

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
	cmp eax, INVALID_FILE_ATTRIBUTES
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
	next02:
	
	;.IF ( rax == INVALID_FILE_ATTRIBUTES or FILE_ATTRIBUTE_DIRECTORY )	; 0FFFFFFFF
	;	mov r9, MB_ICONERROR
	;	mov r8, NULL
	;	mov rdx, OFFSET ErrorSettings
	;	mov rcx, NULL
	;	call MessageBoxA	; https://stackoverflow.com/questions/46439802/multiple-lines-of-output-in-a-message-box-assembly-language
	;	je exit_main
	;.ENDIF

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

	;invoke CFile_Init, eax

	;and rsp, -8h
	;enter 4*8,0
	;xor ecx,ecx
	;mov r9,rcx
	;lea r8,MsgCaption
	;lea edx,MsgBoxText
    ;call MessageBoxA
    ;leave

	xor r9, r9
	lea r8,MsgCaption
	lea edx,MsgBoxText
	xor rcx, rcx
	;call MessageBoxA
	call MessageBoxA


	exit_main_deallocate:
		; Destroy CFile instance from heap
		cmp file, NULL
		je exit_main
		mov rax, file
		push rax
		call QWORD PTR [rax]
		push rax
		call GetProcessHeap
		invoke HeapFree, eax, NULL, file
		pop rax

	; Exit
	exit_main:
		mov   rcx, 0
		call ExitProcess
	;invoke ExitProcess, rcx

main endp
end
