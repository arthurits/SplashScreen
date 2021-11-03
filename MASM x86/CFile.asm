
ifndef __UNICODE__
__UNICODE__ equ 1
endif

ifndef _CFile_
_CFile_ equ 1

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
   CFile_Init    PROTO :DWORD
   CFile_OpenFile	PROTO :DWORD, :DWORD
   CFile_CloseFile	PROTO :DWORD
   CFile_Dispose	PROTO :DWORD

; --=====================================================================================--
; FUNCTION POINTER PROTOS
; --=====================================================================================--
   CFile_destructorPto    TYPEDEF  PROTO  :DWORD 


   .data?
; --=====================================================================================--
; CLASS STRUCTURE
; --=====================================================================================--
   CFile STRUCT
	Destructor		DWORD	?
	OpenFile		DWORD	?
	CloseFile		DWORD	?
	Dispose			DWORD	?
	ConvertToLine	DWORD	?
	GetLine			DWORD	?
	EndOfFile		WORD	?
	handle			DWORD	?
	ptrHeapText		DWORD	?
	ptrLine			DWORD	?
	bytesRead		DWORD	?

   CFile ENDS

   ;CFile_initsize equ sizeof CFile

.data

   CFile_initdata LABEL BYTE
      DWORD OFFSET CFile_Destructor
	  DWORD OFFSET CFile_OpenFile
	  DWORD OFFSET CFile_CloseFile
	  DWORD OFFSET CFile_Dispose
	  DWORD OFFSET CFile_ConvertToLine
	  DWORD OFFSET CFile_GetLine
	WORD	0
	DWORD	0, 0, 0, 0
   CFile_initend equ $-CFile_initdata

;UCSTR fileName2, "C:\Users\...\Documents\Visual Studio 2015\Projects\SplashScreen\ASM x86\Debug\prueba.txt",0
fileSize2 LARGE_INTEGER <>

.const 
MAXSIZE equ 260
MEMSIZE equ 65535

.data?
SizeReadWrite2 DWORD ?	; number of bytes actually read or write

.code
; --=====================================================================================--
; CLASS CONSTRUCTOR
; --=====================================================================================--
CFile_Init  PROC lpTHIS:DWORD
	;SET_CLASS CFile
	;CFile_initsize equ sizeof CFile

	push    esi
	push    edi
	push	ecx
	cld 
	
	mov 	esi, offset CFile_initdata
	mov 	edi, lpTHIS
	mov 	ecx, CFile_initend
	shr 	ecx, 2
	rep 	movsd
	mov 	ecx, CFile_initend
	and 	ecx, 3
	rep 	movsb

	mov  edi, lpTHIS
	assume edi:PTR CFile
	;Initialization code
	assume edi:nothing

	pop		ecx
	pop		edi
	pop		esi

   ret
CFile_Init ENDP

; --=====================================================================================--
; destructor METHOD BEHAVIOR
; --=====================================================================================--
CFile_Destructor  PROC uses eax edi lpTHIS:DWORD 
	mov  edi, lpTHIS
	assume edi:PTR CFile

	mov eax, [edi].handle
	.IF eax
		invoke CloseHandle, [edi].handle
	.ENDIF
   
	mov eax, [edi].ptrHeapText
	.IF eax
		invoke GlobalFree, [edi].ptrHeapText
	.ENDIF
   
	assume edi:nothing
   ret
CFile_Destructor ENDP

;--------------------------------------------------------
CFile_OpenFile proc uses eax ebx edi lpTHIS:DWORD, lpszFileName:DWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	; https://stackoverflow.com/questions/56506869/how-to-initialize-a-local-struct-in-masm-assembly
	;LOCAL fileSize: LARGE_INTEGER <>
	;LOCAL hMemory: DWORD
	;LOCAL pMemory: DWORD
	LOCAL hHeap: DWORD
	LOCAL lpMem: DWORD

	;push ebp ; save base pointer
	;mov ebp,esp ; base of stack frame
	sub esp,8	; save space for 2 DWORD locals

	mov edi, [ebp+8]	; get the parameter lpszFileName passed on the stack to the function
	mov edi, lpTHIS		; get the parameter lpTHIS passed on the stack to the function
	ASSUME edi:PTR CFile

	invoke GetProcessHeap
	mov hHeap, eax

	invoke CreateFile, lpszFileName,\ 
		GENERIC_READ or GENERIC_WRITE ,\ 
		FILE_SHARE_READ or FILE_SHARE_WRITE,\ 
		NULL,OPEN_EXISTING,FILE_ATTRIBUTE_ARCHIVE,\ 
		NULL 
	;mov edx, eax
	mov [edi].handle, eax

	invoke GetFileSizeEx, [edi].handle, ADDR fileSize2
	mov eax, fileSize2.LowPart
	inc eax						; One bit for the NULL terminated
	mov ebx,eax
	mov [edi].bytesRead, ebx		; Save the size in the in-memory struct

	; Allocates memory space for the File
	invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY, ebx
	mov lpMem, eax

	invoke ReadFile, [edi].handle, eax, fileSize2.LowPart, ADDR SizeReadWrite2, NULL
	;mov DWORD PTR [ebp-8], eax
	invoke CloseHandle, [edi].handle
	.IF eax
		mov [edi].handle, 0
	.ENDIF

	; Allocates memory space for the converstion to Unicode
	mov eax, ebx
	shl eax, 1		;Multiply by 2 in order to convert from char to wchar
	invoke HeapAlloc, hHeap, HEAP_ZERO_MEMORY , eax
	mov [edi].ptrHeapText, eax
	mov [edi].ptrLine, eax

	; Convert byte string to word string
	invoke MultiByteToWideChar, CP_UTF8, 0, DWORD PTR [ebp-8], -1, [edi].ptrHeapText, 0
	;invoke MultiByteToWideChar, CP_UTF8, 0, DWORD PTR [ebp-8], -1, [edi].ptrHeapText, [edi].bytesRead
	invoke MultiByteToWideChar, CP_UTF8, 0, DWORD PTR [ebp-8], -1, [edi].ptrHeapText, eax

	;print [edi].ptrHeapText
	;invoke	MessageBox, NULL, [edi].ptrHeapText, NULL, MB_OK

	invoke HeapFree, hHeap, NULL, lpMem
	
	assume edi:nothing

	;mov esp, ebp ; Deallocate local variables
	;pop ebp ; restore base pointer

	ret
CFile_OpenFile endp
; https://stackoverflow.com/questions/51010672/table-with-addresses-or-registers-assembler-x86


;--------------------------------------------------------
CFile_Dispose proc uses edi lpTHIS:DWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	mov edi, lpTHIS
	ASSUME edi: PTR CFile
	.IF ( [edi].ptrHeapText != 0)
		invoke GetProcessHeap
		invoke HeapFree, eax, NULL, [edi].ptrHeapText
		;invoke GlobalFree, [edi].ptrHeapText
		mov [edi].ptrHeapText, 0
	.ENDIF
	ASSUME edi: nothing
	ret
CFile_Dispose endp

;--------------------------------------------------------
CFile_CloseFile proc lpTHIS:DWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	mov edi, lpTHIS
	ASSUME edi: PTR CFile
	ASSUME edi: nothing
	ret
CFile_CloseFile endp


;--------------------------------------------------------
CFile_ConvertToLine proc uses ax edi esi lpTHIS:DWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	mov edi, lpTHIS		; get the parameter passed on the stack to the function
	ASSUME edi:PTR CFile

	mov ecx, [edi].bytesRead
	mov esi, [edi].ptrHeapText
    ;shr ecx, 1

	loop_ConvertToLine:
		mov   ax, WORD PTR [esi]
		;movzx eax, al
        ;push    ecx
		.IF (ax==13)
			mov WORD PTR [esi], 0
		.ENDIF
		;.IF (ax==10)
		;	mov WORD PTR [esi], 0
		;.ENDIF
        ;print   ustr$(eax),32
		;print   eax
		;print   chr$(eax)
        ;pop     ecx
        add     esi, 2
        loop    loop_ConvertToLine

	;print [edi].ptrHeapText, 13, 10
    ;inkey

	ASSUME edi: nothing

	ret
CFile_ConvertToLine endp

CFile_GetLine proc uses ecx edi esi lpTHIS:DWORD
	mov edi, lpTHIS		; get the parameter passed on the stack to the function
	ASSUME edi:PTR CFile

	mov	esi, [edi].ptrLine
	;mov ecx, [edi].ptrHeapText
	;sub ecx, esi
	;shr ecx, 1
	;add ecx, [edi].bytesRead

	mov ecx, [edi].bytesRead
	shl ecx, 1	;multiply by 2 since we are using Words for each character
	add ecx, [edi].ptrHeapText
	sub ecx, esi
	shr ecx, 1	;divide by 2 to get the number of characters

	xor eax, eax

	; If we are at the beginning of the text, just return the address
	.IF esi == [edi].ptrHeapText
		mov eax, esi
		add esi, 2
		jmp exit_GetLine
	.ENDIF

	iterate:
	mov ax, WORD PTR [esi]
	.IF (eax==0)
		.IF (ecx==1)	;If we are at the end, return NULL
			xor eax, eax
		.ELSE
			add esi, 4	;Move 2+2 (Chr 13 + chr 10)
			mov eax, esi
		.ENDIF
		jmp exit_GetLine		
	.ELSE
		add esi, 2	;Move to the next character
	.ENDIF
	loop iterate

	exit_GetLine:
	.IF ecx== 1	;If we are at the end, just reset the Line pointer to the beginning of the text
		mov ecx, [edi].ptrHeapText 
		mov [edi].ptrLine, ecx
	.ELSE
		mov [edi].ptrLine, esi
	.ENDIF

	ASSUME edi: nothing
	ret
CFile_GetLine endp

ENDIF