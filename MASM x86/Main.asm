; Template for 32 MASM assembly.
; Links to Irvine32.lib

.686
.MMX
.XMM
.model flat,stdcall
.stack 4096
option casemap:none

ifndef __UNICODE__
__UNICODE__ equ 1
endif

include C:\masm32\include\windows.inc
include C:\masm32\include\masm32.inc
include C:\masm32\include\comdlg32.inc
include C:\masm32\include\gdi32.inc
include C:\masm32\include\gdiplus.inc
include C:\masm32\include\kernel32.inc
include C:\masm32\include\Ole32.inc
include C:\masm32\include\shlwapi.inc	; For PathRemoveFileSpec and PathCombine
include C:\masm32\include\user32.inc 

include C:\masm32\include\msvcrt.inc

include C:\masm32\macros\macros.asm

includelib C:\masm32\lib\masm32.lib

includelib C:\masm32\lib\comdlg32.lib
includelib C:\masm32\lib\gdi32.lib
includelib C:\masm32\lib\gdiplus.lib
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\ole32.lib
includelib C:\masm32\lib\shlwapi.lib	; For PathRemoveFileSpec and PathCombine
includelib C:\masm32\lib\user32.lib 

includelib C:\masm32\lib\msvcrt.lib

include CFile.asm
include CSplashScreen.asm

; https://stackoverflow.com/questions/2595550/detecting-architecture-at-compile-time-from-masm-masm64
;IFDEF RAX
;  POINTER TYPEDEF QWORD
;ELSE
;  POINTER TYPEDEF DWORD
;ENDIF

;_CloseFile PROTO :DWORD
;_OpenFile PROTO
;_Dispose PROTO :DWORD

; https://www.madwizard.org/programming/toolarchive OOP in MASM32
; https://stackoverflow.com/questions/22677608/including-files-in-assembly-80x86
; https://stackoverflow.com/questions/56506869/how-to-initialize-a-local-struct-in-masm-assembly
; http://www.asmcommunity.net/forums/topic/?id=4739

.const
MAXSIZE equ 260
MEMSIZE equ 65535

.data 
	UCSTR fileName, "settings.splash",0
	ErrorSettings BYTE "An unexpected error ocurred while reading 'settings.splash'.", 13, 10, "Please make sure the file and format are correct.", 0
	ErrorApp BYTE "Could not find the file in the following path:", 13, 10, 0

	file			DWORD	NULL
	splash			DWORD	NULL
	nFadeoutTime	DWORD	NULL
	lpModuleName	LPCSTR	NULL
	lpszImagePath	LPCTSTR	NULL
	lpszPrefix		LPCTSTR	NULL
	lpszAppFileName	LPCTSTR	NULL

.data? 


.code

main proc

	; Get the current handle
	invoke GetModuleHandle,NULL 
	mov lpModuleName, eax
	.IF (eax==NULL)
		jmp exit_main
	.ENDIF

	; If settings.splash doesn't exist, then exit the program
	invoke GetFileAttributes, OFFSET fileName
	.IF ( eax == INVALID_FILE_ATTRIBUTES or FILE_ATTRIBUTE_DIRECTORY )	; 0FFFFFFFF
		invoke MessageBoxA, NULL, OFFSET ErrorSettings, NULL, MB_ICONERROR	; https://stackoverflow.com/questions/46439802/multiple-lines-of-output-in-a-message-box-assembly-language
		jmp exit_main
	.ENDIF

	; Create CFile instance
	mov eax, SIZEOF CFile
	invoke GetProcessHeap
	invoke HeapAlloc, eax, NULL, SIZEOF CFile
	mov file, eax
	push eax
	call CFile_Init
	;invoke CFile_Init, eax

	lea esp, [esp-4]
	mov [esp], OFFSET fileName
	lea esp, [esp-4]
	mov eax, file
	mov [esp], eax
	call (CFile PTR [eax]).OpenFile
	;invoke (CFile PTR [eax]).OpenFile, eax
	;lea esp, [esp+4]

	mov eax, file
	;invoke	MessageBox, NULL, (CFile PTR [eax]).ptrHeapText, NULL, MB_OK

	lea esp, [esp-4]
	mov eax, file
	mov [esp], eax
	call (CFile PTR [eax]).ConvertToLine
	;invoke (CFile PTR [eax]).OpenFile, eax
	;lea esp, [esp+4]

	; Read the first line: the image path
	lea esp, [esp-4]
	mov eax, file
	mov [esp], eax
	call (CFile PTR [eax]).GetLine
	;invoke (CFile PTR [eax]).OpenFile, eax
	;lea esp, [esp+4]
	.IF eax!=0
		;invoke	MessageBox, NULL, eax, NULL, MB_OK
		mov lpszImagePath, eax
		;jmp salto
	.ENDIF
	; Read the second line: the application path
	lea esp, [esp-4]
	mov eax, file
	mov [esp], eax
	call (CFile PTR [eax]).GetLine
	.IF eax!=0
		mov lpszAppFileName, eax
	.ENDIF
	; Read the third line: the fadeout milliseconds
	lea esp, [esp-4]
	mov eax, file
	mov [esp], eax
	call (CFile PTR [eax]).GetLine
	.IF (eax != 0)
		mov nFadeoutTime, eax
		push nFadeoutTime
		call StringToInt
		mov nFadeoutTime, eax
	.ENDIF

	; If the application doesn't exist, then exit the program
	invoke GetFileAttributes, lpszAppFileName
	.IF ( eax == INVALID_FILE_ATTRIBUTES or FILE_ATTRIBUTE_DIRECTORY )	; 0FFFFFFFF
		invoke MessageBoxA, NULL, OFFSET ErrorApp, NULL, MB_ICONERROR
		jmp exit_main_deallocate
	.ENDIF
	;invoke GetFileAttributes, lpszImagePath
	;invoke GetFileAttributes, lpszAppFileName

	; Create CSplashScreen instance
	mov eax, SIZEOF CSplashScreen
	invoke GetProcessHeap
	invoke HeapAlloc, eax, NULL, SIZEOF CSplashScreen
	mov splash, eax
	push nFadeoutTime
	push lpszAppFileName
	push lpszImagePath
	push lpModuleName
	push eax
	call CSplashScreen_Init
	
	push splash
	call (CSplashScreen PTR [eax]).Show
	
	exit_main_deallocate:
	; Destroy CFile instance from heap
	cmp file, NULL
	je exit_main
	mov eax, file
    push eax
    call DWORD PTR [eax]
    push eax
    invoke GetProcessHeap
    invoke HeapFree, eax, NULL, file
    pop eax

	; Destroy CSplash instance from heap
	cmp splash, NULL
	je exit_main
	mov eax, splash
    push eax
    call DWORD PTR [eax]
    push eax
    invoke GetProcessHeap
    invoke HeapFree, eax, NULL, splash
    pop eax

	exit_main:

	invoke ExitProcess, 0
	
main endp




;*************************************************
; Computes the numeric value represented by a Unicode string
; Receives: the address of the null-terminated array of chars in Unicode (2 bytes per char)
; Returns: eax cointains the total numeric value represented by the string
; Preconditions: none
; Registers changed:  eax, ebx, ecx, esi
; https://stackoverflow.com/questions/13664778/converting-string-to-integer-in-masm-esi-difficulty
;*************************************************
StringToInt PROC uses ebx ecx esi lpString:DWORD
	xor eax, eax	; Total counter
	xor ebx, ebx	; Char pointer
	mov ecx, 10d	; Decimal factor multiplier
	;xor esi, esi
	mov esi, DWORD PTR [lpString]    ; Point at the beginning of the string

	; Loop through each char in string
	loopString:
		; Check whether we reached the end of the string
		cmp WORD PTR [esi], 0000h
		je exit_StringToInt

		; Multiply the accumulated quantity by 10
		mul ecx

		; Subtract 48 from ASCII value (number 0) of current char to get integer
		mov     bx, WORD PTR [esi]
		sub     bx, 0048d        

		; Error checking to ensure values are digits 0-9
		cmp     bx, 0            
		jl      invalidInput
		cmp     bx, 9
		jg      invalidInput

		; If it's a digit, add to the total and go on with the loop
		add     eax, ebx	; Add to total counter
		add     esi, 2		; Point to next char (2 bytes per char)
    jmp loopString

	jmp exit_StringToInt

	invalidInput:	; Reset registers and variables to 0
	    mov     eax, 0
	
	exit_StringToInt:
	ret
StringToInt ENDP

end main



; Read line by line
; http://forums.codeguru.com/showthread.php?391564-Read-line-from-a-file
; http://www.interq.or.jp/chubu/r6/masm32/tute/tute012.html
; https://www.daniweb.com/programming/software-development/threads/31282/windows-api-functions-to-read-and-write-files-in-c

; OOP in ASM
; https://stackoverflow.com/questions/7487031/how-to-invoke-a-pointer-to-a-function-in-masm 
; https://zsmith.co/OOA.php 
; https://archive.org/details/dr_dobbs_journal_vol_15/page/n215

; Visual Studio setup for MASM
; http://www.deconflations.com/2011/masm-assembly-in-visual-studio-2010/
; https://resources.infosecinstitute.com/assembly-programming-visual-studio-net/

; Push / pop alternativas
; https://stackoverflow.com/questions/4584089/what-is-the-function-of-the-push-pop-instructions-used-on-registers-in-x86-ass
; push reg   <= same as =>      sub  $8,%rsp        # subtract 8 from rsp
;                              mov  reg,(%rsp)     # store, using rsp as the address
;								lea rsp, [rsp-8]

; pop  reg    <= same as=>      mov  (%rsp),reg     # load, using rsp as the address
;                              add  $8,%rsp        # add 8 to the rsp
;								lea rsp, [rsp+8]

; Dynamic string allocation http://www.asmcommunity.net/forums/topic/?id=13531
; C++ strings https://stackoverflow.com/questions/19697296/what-is-stdwifstreamgetline-doing-to-my-wchar-t-array-its-treated-like-a-b