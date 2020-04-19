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


.data
sum qword 0
MsgCaption db "Iczelion's tutorial #2a",0
MsgBoxText db "Win64 Assembly is great!",0

	hdlModule	HMODULE	NULL

.code
main proc

	; Get the current handle
	mov rcx, NULL
	invoke GetModuleHandleW, rcx
	mov hdlModule, rax
	cmp rax, NULL
	je exit_main

	mov	rax, 5
	add	rax,6
	mov   sum,rax
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
	invoke MessageBoxA, rcx, rdx, r8, r9

	; Exit
	exit_main:

	mov   rcx,0
	invoke ExitProcess
	;invoke ExitProcess, rcx

main endp
end
