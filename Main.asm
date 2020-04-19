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
include C:\masm32\include\user32.inc 
include C:\masm32\include\kernel32.inc 
include C:\masm32\include\comdlg32.inc
include C:\masm32\include\masm32.inc
include C:\masm32\include\msvcrt.inc 

include C:\masm32\macros\macros.asm

includelib C:\masm32\lib\masm32.lib

includelib C:\masm32\lib\user32.lib 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\comdlg32.lib
includelib C:\masm32\lib\gdi32.lib
includelib C:\masm32\lib\ole32.lib
includelib C:\masm32\lib\gdiplus.lib
includelib C:\masm32\lib\shlwapi.lib	; For PathRemoveFileSpec and PathCombine

includelib C:\masm32\lib\msvcrt.lib

include CFile.asm
include CSplashScreen.asm

; https://stackoverflow.com/questions/2595550/detecting-architecture-at-compile-time-from-masm-masm64
IFDEF RAX
  POINTER TYPEDEF QWORD
ELSE
  POINTER TYPEDEF DWORD
ENDIF

;_CloseFile PROTO :DWORD
;_OpenFile PROTO
;_Dispose PROTO :DWORD

; https://www.madwizard.org/programming/toolarchive OOP in MASM32
; https://stackoverflow.com/questions/22677608/including-files-in-assembly-80x86
; https://stackoverflow.com/questions/56506869/how-to-initialize-a-local-struct-in-masm-assembly
; http://www.asmcommunity.net/forums/topic/?id=4739
;CFile STRUCT
;  Name WORD L"Z:\Visual Studio 2015\Projects\SplashScreen\ASM x86\Debug\settings.txt",0
;  EndOfFile WORD 0
;  handle DWORD 0
;  ptrHeapText POINTER 0
;  bytes DWORD 0
;  CloseFile DWORD ?
;  OpenFile DWORD ?
;  Dispose DWORD ?
;CFile ENDS

;Splash STRUCT
;	handle DWORD ?
;	AppPath DWORD ?
;	ImagePath DWORD ?
;	TimeFadeOut DWORD ?
;Splash ENDS

.const 
MAXSIZE equ 260
MEMSIZE equ 65535

.data 
;UCSTR fileName, "C:\Users\Arthurit\Documents\Visual Studio 2017\Projects\SplashScreen\ASM x86\Debug\prueba.txt",0
;UCSTR fileName, "C:\Users\AlfredoA\Documents\Visual Studio 2015\Projects\SplashScreen\ASM x86\Debug\prueba2.txt",0
UCSTR fileName, "C:\Users\Arthurit\Documents\Visual Studio 2017\Projects\SplashScreen\ASM x86\Debug\settings.txt",0
fileSize LARGE_INTEGER <>

.data? 
	lpModuleName	LPCSTR	?
	CommandLine		LPSTR	? 
	hwndEdit		HWND	?	; Handle to the edit control 
	hFile			HANDLE	?	; File handle 
	hMemory			HANDLE	?	; handle to the allocated memory block 
	pMemory			DWORD	?	; pointer to the allocated memory block
	pMemoryW		DWORD	?
	SizeReadWrite	DWORD	?	; number of bytes actually read or write

	file			DWORD	?
	splash			DWORD	?
	nFadeoutTime	DWORD	?
	lpszImagePath	LPCTSTR	?
	lpszPrefix		LPCTSTR	?
	lpszAppFileName	LPCTSTR	?

.code
main proc

	;LOCAL file:CFile
	;mov file.Dispose, OFFSET CFile_Dispose
	;mov file.CloseFile, OFFSET CFile_CloseFile
	;mov file.OpenFile, OFFSET CFile_OpenFile

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
	invoke	MessageBox, NULL, (CFile PTR [eax]).ptrHeapText, NULL, MB_OK

	lea esp, [esp-4]
	mov eax, file
	mov [esp], eax
	call (CFile PTR [eax]).ConvertToLine
	;invoke (CFile PTR [eax]).OpenFile, eax
	;lea esp, [esp+4]

	salto:
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
	lea esp, [esp-4]
	mov eax, file
	mov [esp], eax
	call (CFile PTR [eax]).GetLine
	.IF eax!=0
		mov lpszAppFileName, eax
	.ENDIF
	lea esp, [esp-4]
	mov eax, file
	mov [esp], eax
	call (CFile PTR [eax]).GetLine
	.IF eax!=0
		mov nFadeoutTime, eax
	.ENDIF

	; Destroy CFile instance
	mov eax, file
    push eax
    call DWORD PTR [eax]
    push eax
    invoke GetProcessHeap
    invoke HeapFree, eax, NULL, file
    pop eax

	invoke GetModuleHandle,NULL 
	mov lpModuleName, eax
	.IF (eax==NULL)
		jmp exit_main
	.ENDIF

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
	
	;invoke	MessageBox, NULL, NULL, NULL, MB_OK
	jmp exit_main



	invoke CreateFile, ADDR fileName,\ 
		GENERIC_READ or GENERIC_WRITE ,\ 
		FILE_SHARE_READ or FILE_SHARE_WRITE,\ 
		NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\ 
		NULL 
	mov hFile,eax

	invoke GetFileSizeEx, hFile, ADDR fileSize

	mov eax, fileSize.LowPart
	inc eax
	mov ebx,eax
	invoke GlobalAlloc, GMEM_MOVEABLE or GMEM_ZEROINIT, eax
	mov  hMemory, eax 
	
	invoke GlobalLock, hMemory 
	mov  pMemory,eax

	invoke ReadFile, hFile, pMemory, fileSize.LowPart, ADDR SizeReadWrite, NULL

	invoke CloseHandle,hFile

	mov eax, ebx
	shl eax, 1
	invoke GlobalAlloc, GMEM_ZEROINIT, eax
	mov pMemoryW,eax

	invoke MultiByteToWideChar, CP_UTF8, 0, pMemory, -1, pMemoryW, 0
	invoke MultiByteToWideChar, CP_UTF8, 0, pMemory, -1, pMemoryW, ebx

	invoke	MessageBox, NULL, pMemoryW, pMemory, MB_OK

	 
	invoke GlobalUnlock,pMemory 
	invoke GlobalFree,hMemory
	invoke GlobalFree, pMemoryW

  mov ebx, "a"
  .Repeat
	push ebx
	print esp, " "
	inc ebx
	pop eax
  .Until ebx>"z"


	exit_main:

	invoke ExitProcess,0
	
main endp

end main


; http://masm32.com/board/index.php?topic=6259.0
UnicodeString MACRO ansiArg, ucArg
  pushad
  mov esi, ansiArg
  mov edi, ucArg
  xor eax, eax
  .Repeat
	lodsb
	stosw
  .Until !eax
  popad
  EXITM <ucArg>
ENDM



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