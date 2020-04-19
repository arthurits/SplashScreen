
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


Pieces PROC

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

Pieces ENDP