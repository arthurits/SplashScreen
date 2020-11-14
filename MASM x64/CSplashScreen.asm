ifndef _CSplashScreen_
_CSplashScreen_ equ 1

;include C:\masm32\include\windows.inc
;include C:\masm32\include\kernel32.inc
;include C:\masm32\include\Ole32.inc
;include C:\masm32\include\gdi32.inc
;include C:\masm32\include\gdiplus.inc
;include C:\masm32\include\user32.inc
;include C:\masm32\include\shlwapi.inc	; For PathRemoveFileSpec and PathCombine
;include C:\masm32\include\comdlg32.inc

;WindowProc      proto CALLBACK
; UOC: Intro to x64 ASM
; http://cv.uoc.edu/annotation/8255a8c320f60c2bfd6c9f2ce11b2e7f/619469/PID_00218273/PID_00218273.html#w31aac15c17b7c15
.data?
; --=====================================================================================--
; CLASS STRUCTURE
; --=====================================================================================--
	CSplashScreen STRUCT
		Destructor				QWORD	?
		Show					QWORD	?
		;RegisterWindowClass		QWORD	?
		;UnregisterWindowClass	QWORD	?
		;CreateBitmapImage		QWORD	?
		hModuleHandle			HMODULE	?
		lpszImagePath			QWORD	?
		lpszAppPath				QWORD	?
		intFadeOutTime			DWORD	?
		intFadeOutEnd			DWORD	?
		blend					BLENDFUNCTION	<>	; DWORD 4 bytes long
	CSplashScreen ENDS

.data

	CSplashScreen_initdata LABEL BYTE
		QWORD OFFSET CSplashScreen_Destructor
		QWORD OFFSET CSplashScreen_Show
		;QWORD OFFSET CSplashScreen_RegisterWindowClass
		;QWORD OFFSET CSplashScreen_UnregisterWindowClass
		;QWORD OFFSET CSplashScreen_CreateBitmapImage
		QWORD	0, 0, 0
		DWORD	0, 0, 0
	CSplashScreen_initend equ $-CSplashScreen_initdata

    gdiToken	QWORD	0
	gdipSI GdiplusStartupInput <1>  ; version must be 1
	;strEventName_1 BYTE "CloseSplashWindowEvent", 0
	;strEventName_2 BYTE "CloseSplashScreenWithoutFadeEvent", 0
	strEventName_1	WORD	"C", "l", "o", "s", "e", "S", "p", "l", "a", "s", "h", "S", "c", "r", "e", "e", "n", "E", "v", "e", "n", "t", 0
	strEventName_2	WORD	"C", "l", "o", "s", "e", "S", "p", "l", "a", "s", "h", "S", "c", "r", "e", "e", "n", "W", "i", "t", "h", "o", "u", "t", "F", "a", "d", "e", "E", "v", "e", "n", "t", 0
	strClassName	WORD	"S", "p", "l", "a", "s", "h", "S", "c", "r", "e", "e", "n", "C", "l", "a", "s", "s", 0
	;UCSTR strIm, "Dark night 02.jpg", 0

.const 
	MAX_PATH equ 260

	m_nSplashWidth equ 800
	m_nSplashHeight equ 500
	m_SplashBackgroundColor  equ 0FF000000h	; Color constants in gdipluscolor.h
	m_SplashColor  equ 0FF000000h

.code

; --=====================================================================================--
; CLASS CONSTRUCTOR
; --=====================================================================================--
CSplashScreen_Init PROC uses rcx rsi rdi lpTHIS:QWORD, hInstance:QWORD, strImage:QWORD, strApp:QWORD, intFadeOutTime:DWORD
	cld   
	; Asign the class methods to pointer lpTHIS
	mov 	rsi, OFFSET CSplashScreen_initdata
	mov 	rdi, lpTHIS
	mov 	rcx, CSplashScreen_initend
	shr 	rcx, 3
	rep 	movsq
	mov 	rcx, CSplashScreen_initend
	and 	rcx, 7
	rep 	movsb

	; Personalized initialization code
	mov  rdi, lpTHIS

		mov rax, hInstance
		mov (CSplashScreen PTR [rdi]).hModuleHandle, rax
		mov rax, strImage
		mov (CSplashScreen PTR [rdi]).lpszImagePath, rax
		mov rax, strApp
		mov (CSplashScreen PTR [rdi]).lpszAppPath, rax
		mov eax, intFadeOutTime
		mov (CSplashScreen PTR [rdi]).intFadeOutTime, eax
		mov (CSplashScreen PTR [rdi]).intFadeOutEnd, 0

		;Initialize blend member with zeroes
	    mov     rcx, sizeof BLENDFUNCTION
	    xor     rax, rax
	    lea     rdi, (CSplashScreen PTR [rdi]).blend
	    rep stosb

	ret
CSplashScreen_Init ENDP

; --=====================================================================================--
; destructor METHOD BEHAVIOR
; --=====================================================================================--
CSplashScreen_Destructor PROC uses rdi lpTHIS:QWORD 
	mov  rdi, lpTHIS

	ret
CSplashScreen_Destructor ENDP


;--------------------------------------------------------
CSplashScreen_Show PROC uses rdi r15 lpTHIS:QWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	LOCAL hCloseSplashEvent :QWORD
	LOCAL hCloseSplashWithoutFadeEvent :QWORD
	LOCAL hBmp :QWORD
	LOCAL aHandles[3] :QWORD	; http://masm32.com/board/index.php?topic=5620.0
	LOCAL hSplashWnd :HANDLE
	LOCAL hdcScreen	:HDC
	
	mov r15, rsp
	sub rsp, 8 * 6	; Shallow space for Win32 API x64-calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls

	mov  rdi, lpTHIS

	; Open the COM library
	mov rdx, COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE
	mov rcx, NULL
	call CoInitializeEx		; invoke CoInitializeEx, 0, COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE
	cmp rax, S_OK		; .IF (rax == S_OK) Operation successful 0x00000000h
	jl exit_Show		; rax < S_OK means that the COM library could not be opened
	
	; Create the named close splash screen event, making sure we're the first process to create it
	mov rcx, ERROR_SUCCESS
	call SetLastError	; invoke SetLastError, ERROR_SUCCESS

	; Create the event CloseSplashScreenEvent
	lea r9, strEventName_1
	mov r8, FALSE
	mov rdx, TRUE
	mov rcx, NULL
	call CreateEvent	; invoke CreateEvent, NULL, TRUE, FALSE, ADDR strEventName_1
	mov hCloseSplashEvent, rax

	call GetLastError	; invoke GetLastError
	cmp rax, ERROR_ALREADY_EXISTS	; .IF (eax == ERROR_ALREADY_EXISTS)		ERROR_ALREADY_EXISTS = 183
	je exit_Show					; rax == ERROR_ALREADY_EXISTS, then exit function

	; Create the event CloseSplashScreenWithoutFadeEvent
	mov r9, OFFSET strEventName_2
	mov r8, FALSE
	mov rdx, TRUE
	mov rcx, NULL
	call CreateEvent	; invoke CreateEvent, NULL, TRUE, FALSE, ADDR strEventName_2
	mov hCloseSplashWithoutFadeEvent, rax

	call GetLastError	; invoke GetLastError
	cmp rax, ERROR_ALREADY_EXISTS	; .IF (eax == ERROR_ALREADY_EXISTS)		ERROR_ALREADY_EXISTS = 183
	je exit_Show					; rax == ERROR_ALREADY_EXISTS, then exit function

	; Graphic display operations
	mov rcx, NULL
	call GetDC	; invoke GetDC, NULL
	mov hdcScreen, rax

	; Create the bitmap (from file or default) that will be shown in the splash window
	mov QWORD PTR [rsp], rdi
	call CSplashScreen_CreateBitmapImage
	mov hBmp, rax

	cmp rax, NULL	; .IF (hBitmap!=NULL)
	je exit_Show		; if hBitmap==0 then exit
		; if hBitmap exists, then create the splash window and set the bitmap image
		;mov QWORD PTR [rsp], rdi			; 1st argument. Not necessary, it's already there
		call CSplashScreen_RegisterWindowClass
		;mov QWORD PTR [rsp], rdi			; 1st argument. Not necessary, it's already there
		call CSplashScreen_CreateSplashWindow
		mov hSplashWnd, rax
		
		mov rcx, hBmp
		mov QWORD PTR [rsp + 16], rcx		; 3rd argument	
		mov QWORD PTR [rsp + 8], rax		; 2nd argument		
		; mov QWORD PTR [rsp], rdi			; 1st argument. Not necessary, it's already there
		call CSplashScreen_SetSplashImage	; returns rax=0 if unsuccessful

	cmp rax, NULL	; .IF (rax!=0)
	je exit_Show	; if rax==0 then exit
		; if file exists, then launch the application
		; mov QWORD [rsp], rdi					; Not necessary, it's already there
		call CSplashScreen_LaunchApplication	; Returns the handle of the launched application in rax
		cmp rax, NULL
		je exit_Show

		mov rbx, rax	; Handle of the launched application
		mov rcx, rax
		call GetProcessId	; invoke GetProcessId, eax
		mov rcx, rax
		call AllowSetForegroundWindow	; invoke AllowSetForegroundWindow, eax
		
		lea rax, aHandles 
		mov QWORD PTR [rax + 0], rbx
		mov rbx, hCloseSplashEvent
		mov QWORD PTR [rax + 8], rbx
		mov rbx, hCloseSplashWithoutFadeEvent
		mov QWORD PTR [rax + 16], rbx
		
		mov r8, hdcScreen
		mov QWORD PTR [rsp+40], r8
		mov DWORD PTR [rsp+32], INFINITE
		mov QWORD PTR [rsp+24], rax
		mov DWORD PTR [rsp+16], LENGTHOF aHandles
		mov r8, hSplashWnd
		mov QWORD PTR [rsp+8], r8
		mov QWORD PTR [rsp], rdi			; Necessary since Win32 API calls could have modified this shallow space
		call CSplashScreen_PumpMsgWaitForMultipleObjects	; lpTHIS:QWORD, hwndSplash:HWND, nCount:DWORD, pHandles:LPHANDLE, dwMilliseconds:DWORD, hdcScreen:HDC

	exit_Show:
	mov rdx, hdcScreen
	mov rcx, NULL
	call ReleaseDC	; invoke ReleaseDC, NULL, hdcScreen

	; Deallocate the hbitmap
	mov rcx, hBmp
	call DeleteObject	; invoke DeleteObject, hBitmap

	mov rcx, aHandles
	call CloseHandle	; invoke CloseHandle, aHandles
	;invoke CloseHandle, hProcess

	; Close the events
	mov rcx, hCloseSplashEvent
	call CloseHandle	; invoke CloseHandle, hCloseSplashEvent
	mov rcx, hCloseSplashWithoutFadeEvent
	call CloseHandle	; invoke CloseHandle, hCloseSplashWithoutFadeEvent
	
	; Destroy the window and unregister the class
	mov rcx, hSplashWnd
	call DestroyWindow	; invoke DestroyWindow, hSplashWnd
	mov QWORD PTR [rsp], rdi	; Necessary since Win32 API calls could have modified this shallow space
	call CSplashScreen_UnregisterWindowClass

	; Close the COM library
	call CoUninitialize		; invoke CoUninitialize

	add rsp, r15	; Restore the stack pointer to point below the shallow space
	ret
CSplashScreen_Show ENDP

;--------------------------------------------------------
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
CSplashScreen_CreateBitmapImage PROC uses rdi r15 lpTHIS:QWORD

	;LOCAL hGdiImage :DWORD
	;LOCAL wbuffer :DWORD
	LOCAL hBmp :QWORD
	;LOCAL image :BITMAP
	LOCAL GpBitmap :QWORD		; Pointer to GpBitmap
	LOCAL GpGraphics :QWORD		; Pointer to GpGraphics
	LOCAL GpSolidFill :QWORD	; Pointer to GpSolidFill
	;LOCAL lpImage	:QWORD

	;mov hGdiImage, 0
	mov hBmp, 0
	mov GpBitmap, 0
	mov GpGraphics, 0
	mov GpSolidFill, 0
	
	mov r15, rsp
	sub rsp, 8 * 6	; Shallow space for Win32 API x64 calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls

	mov rdi, lpTHIS

	mov gdipSI.GdiplusVersion, 1
	mov gdipSI.SuppressBackgroundThread, 0
	mov r8, NULL
	mov rdx, OFFSET gdipSI
	mov rcx, OFFSET gdiToken
	call GdiplusStartup		; invoke GdiplusStartup, ADDR gdiToken, ADDR gdipSI, NULL

	; If GDI could not be started, then exit
	cmp gdiToken, 0		; 	.IF gdiToken == 0
	je exit_CreateBitmapImage
	
	;invoke GdipCreateBitmapFromFile, ADDR ImagePath, ADDR hGdiImage
	lea rdx, GpBitmap
	mov rcx, (CSplashScreen PTR [rdi]).lpszImagePath
	call GdipCreateBitmapFromFile		; invoke GdipCreateBitmapFromFile, [rdi].lpszImagePath, ADDR GpBitmap
	cmp GpBitmap, NULL					; .IF (GpBitmap == NULL)
	je exit_DefaultBitmap

	mov r8, m_SplashBackgroundColor
	lea rdx, hBmp
	mov rcx, GpBitmap
	call GdipCreateHBITMAPFromBitmap	; invoke GdipCreateHBITMAPFromBitmap, GpBitmap, ADDR hBitmap, m_SplashBackgroundColor
	cmp hBmp, NULL					; .IF (hBitmap == NULL)
	je exit_DefaultBitmap
	
	mov rcx, GpBitmap
	call GdipDisposeImage				; invoke GdipDisposeImage, GpBitmap
	;invoke GetObject, hBitmap, SIZEOF image, ADDR image
	jmp exit_CreateBitmapImage

	; Creates a default bitmap (colors and dimensions defined atop)
	; More information here: http://masm32.com/board/index.php?topic=5731.15
	exit_DefaultBitmap:
		lea rax, GpBitmap
		mov QWORD PTR [rsp+40], rax
		mov QWORD PTR [rsp+32], NULL
		mov r9, PixelFormat32bppARGB
		mov r8, 0
		mov rdx, m_nSplashHeight
		mov rcx, m_nSplashWidth
		call GdipCreateBitmapFromScan0		; invoke GdipCreateBitmapFromScan0, m_nSplashWidth, m_nSplashHeight, 0, PixelFormat32bppARGB, NULL, ADDR GpBitmap
		lea rdx, GpGraphics
		mov rcx, GpBitmap
		call GdipGetImageGraphicsContext	; invoke GdipGetImageGraphicsContext, GpBitmap, ADDR GpGraphics
		lea rdx, GpSolidFill
		mov rcx, m_SplashColor
		call GdipCreateSolidFill			; invoke GdipCreateSolidFill, m_SplashColor, ADDR GpSolidFill
		mov QWORD PTR [rsp+40], m_nSplashHeight
		mov QWORD PTR [rsp+32], m_nSplashWidth
		mov r9, 0
		mov r8, 0
		mov rdx, GpSolidFill
		mov rcx, GpGraphics
		call GdipFillRectangleI				; invoke GdipFillRectangleI, GpGraphics, GpSolidFill, 0, 0, m_nSplashWidth, m_nSplashHeight
		mov r8, m_SplashBackgroundColor
		lea rdx, hBmp
		mov rcx, GpBitmap
		call GdipCreateHBITMAPFromBitmap	; invoke GdipCreateHBITMAPFromBitmap, GpBitmap, ADDR hBitmap, m_SplashBackgroundColor 

		mov rcx, GpSolidFill
		call GdipFree			; invoke GdipFree, GpSolidFill
		mov rcx, GpGraphics
		call GdipFree			; invoke GdipFree, GpGraphics
		mov rcx, GpBitmap
		call GdipDisposeImage	; invoke GdipDisposeImage, GpBitmap

	exit_CreateBitmapImage:
		lea rcx, gdiToken
		call GdiplusShutdown	; invoke GdiplusShutdown, ADDR gdiToken
		mov rax, hBmp		; This has to be deallocated later by the user

	add rsp, r15	; Restore the stack pointer to point below the shallow space
	ret
CSplashScreen_CreateBitmapImage ENDP

; --=====================================================================================--
; Registers a window class for the splash and splash owner windows.
; --=====================================================================================--
CSplashScreen_RegisterWindowClass PROC uses rdi r15 lpTHIS:QWORD
	; https://gist.github.com/DrFrankenstein/9810bbf5cad98b110281
	LOCAL   wc: WNDCLASSEX

	;Initialize wc with zeroes
    mov     rcx, sizeof WNDCLASSEX
    xor     rax, rax
    lea     rdi, wc
    rep stosb

	mov r15, rsp
	sub rsp, 8 * 12	; Shallow space for Win32 API x64-calls (minimum 32 bytes)
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls

	; Get this pointer
	mov  rdi, lpTHIS

    ;Register the window class
    ;mov	rcx, 0
	;call GetModuleHandle	; invoke GetModuleHandle, 0
	mov		wc.cbSize, sizeof WNDCLASSEX
	lea rcx, DefWindowProc
	mov     wc.lpfnWndProc, rcx	; http://masm32.com/board/index.php?topic=2469.0
    mov rcx, (CSplashScreen PTR [rdi]).hModuleHandle
	mov     wc.hInstance, rcx
	mov rcx, offset strClassName
    mov     wc.lpszClassName, rcx
	lea rcx, wc
    call RegisterClassEx	; invoke RegisterClassEx, ADDR wc

	add rsp, r15	; Restore the stack pointer to point below the shallow space
	ret
CSplashScreen_RegisterWindowClass ENDP

; --=====================================================================================--
; Registers a window class for the splash and splash owner windows.
; --=====================================================================================--
CSplashScreen_UnregisterWindowClass PROC uses rdi r15 lpTHIS:QWORD
	mov r15, rsp
	sub rsp, 8 * 4	; Shallow space for Win32 API x64-calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls
	mov rdi, lpTHIS

	;invoke GetModuleHandle, 0
	mov rdx, (CSplashScreen PTR [rdi]).hModuleHandle
	mov rcx, OFFSET strClassName
	call UnregisterClass		; invoke UnregisterClass, OFFSET strClassName, (CSplashScreen PTR [rdi]).lpModuleName

	add rsp, r15	; Restore the stack pointer to point below the shallow space
	ret
CSplashScreen_UnregisterWindowClass ENDP


CSplashScreen_CreateSplashWindow PROC uses rdi r15 lpTHIS:QWORD
	mov r15, rsp
	sub rsp, 8 * 12	; Shallow space for Win32 API x64-calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls
	mov  rdi, lpTHIS

	mov QWORD PTR [rsp+88], NULL
	mov r9, (CSplashScreen PTR [rdi]).hModuleHandle
	mov QWORD PTR [rsp+80], r9
	mov QWORD PTR [rsp+72], NULL
	mov QWORD PTR [rsp+64], NULL
	mov DWORD PTR [rsp+56], 0
	mov DWORD PTR [rsp+48], 0
	mov DWORD PTR [rsp+40], 0
	mov DWORD PTR [rsp+32], 0
	mov r9d, WS_POPUP or WS_VISIBLE
	mov r8, NULL
	mov rdx, OFFSET strClassName
	mov ecx, WS_EX_LAYERED or WS_EX_TOOLWINDOW or WS_EX_TOPMOST
	call CreateWindowEx
	;invoke CreateWindowEx, WS_EX_LAYERED or WS_EX_TOOLWINDOW or WS_EX_TOPMOST, OFFSET strClassName, NULL, WS_POPUP or WS_VISIBLE, 0, 0, 0, 0, NULL, NULL, [edi].lpModuleName, NULL
	; https://tuttlem.github.io/2015/09/14/windows-programs-with-masm32.html
	
	add rsp, r15	; Restore the stack pointer to point below the shallow space
	ret
CSplashScreen_CreateSplashWindow ENDP

CSplashScreen_SetSplashImage PROC uses rdi r15 lpTHIS:QWORD, hwndSplash:HWND, hbmpSplash:HBITMAP
	LOCAL bm :BITMAP			; defined in wingdi.h
	LOCAL ptZero :POINT			; defined in windef.h
	LOCAL ptOrigin :POINT		; defined in windef.h
	LOCAL sizeSplash :_SIZE		; defined in windef.h
	LOCAL hmonPrimary :HMONITOR	; defined in windef.h
	LOCAL monitorInfo :MONITORINFO	;defined in WinUser.h
	;LOCAL rcWork :RECT		; defined in
	LOCAL hdcScreen :HDC	; defined in
	LOCAL hdcMem :HDC		; defined in
	LOCAL hbmpOld :HBITMAP	; defined in
	;LOCAL blend :BLENDFUNCTION	; defined in wingdi.h

	; Initialize structs
	mov ptZero.x, 0
	mov ptZero.y, 0

    mov     rcx, SIZEOF monitorInfo
    xor     rax, rax
    lea     rdi, monitorInfo
    rep stosb

	mov r15, rsp
	sub rsp, 8 * 9	; Shallow space for Win32 API x64-calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls
	mov rdi, lpTHIS	; Get this pointer

	; Get the dimensions of the bitmap used as the splash screen
	lea r8, bm
	mov rdx, sizeof bm
	mov rcx, hbmpSplash
	call GetObject		; invoke GetObject, hbmpSplash, SIZEOF bm, ADDR bm
	mov eax, bm.bmWidth
	mov sizeSplash.x, eax
	mov eax, bm.bmHeight
	mov sizeSplash.y, eax
	
	; Get the primary monitor's info
	mov r8, MONITOR_DEFAULTTOPRIMARY	; 0x00000001
	mov edx, ptZero.y	; https://stackoverflow.com/questions/22621340/why-cant-i-move-directly-a-byte-to-a-64-bit-register
	mov ecx, ptZero.x
	call MonitorFromPoint	; invoke MonitorFromPoint, ptZero.x, ptZero.y, MONITOR_DEFAULTTOPRIMARY	; 0x00000001
	mov hmonPrimary, rax
	mov rax, SIZEOF monitorInfo
	mov monitorInfo.cbSize, eax
	
	lea rdx, monitorInfo
	mov rcx, hmonPrimary
	call GetMonitorInfo		; invoke GetMonitorInfo, hmonPrimary, ADDR monitorinfo

	; Center the bitmap into the primary monitor
	mov eax, monitorInfo.rcMonitor.right	; rcWork plus the windows taskbar
	sub eax, monitorInfo.rcMonitor.left
	sub eax, sizeSplash.x
	shr eax, 1
	add eax, monitorInfo.rcMonitor.left
	mov ptOrigin.x, eax

	mov eax, monitorInfo.rcMonitor.bottom
	sub eax, monitorInfo.rcMonitor.top
	sub eax, sizeSplash.y
	shr eax, 1
	add eax, monitorInfo.rcMonitor.top
	mov ptOrigin.y, eax

	; Create a memory DC holding the splash bitmap
	mov rcx, 0
	call GetDC	; invoke GetDC, 0
	mov hdcScreen, rax
	mov rcx, rax
	call CreateCompatibleDC		; invoke CreateCompatibleDC, hdcScreen
	mov hdcMem, rax
	mov rdx, hbmpSplash
	mov rcx, rax
	call SelectObject			; invoke SelectObject, hdcMem, hbmpSplash
	mov hbmpOld, rax
	
	; Use the source image's alpha channel for blending
	;lea r9, (CSplashScreen PTR [rdi]).blend
	mov (CSplashScreen PTR [rdi]).blend.BlendOp, AC_SRC_OVER		; 0x00
	mov (CSplashScreen PTR [rdi]).blend.BlendFlags, 0				; 0x00
	mov (CSplashScreen PTR [rdi]).blend.SourceConstantAlpha, 255	; 0xFF
	mov (CSplashScreen PTR [rdi]).blend.AlphaFormat, AC_SRC_ALPHA	; 0x01

	; Paint the window (in the right location) with the alpha-blended bitmap
	mov DWORD PTR [rsp+64], ULW_ALPHA
	lea r9, (CSplashScreen PTR [rdi]).blend
	mov QWORD PTR [rsp+56], r9
	mov DWORD PTR [rsp+48], 000000000h
	lea r9, ptZero
	mov QWORD PTR [rsp+40], r9
	mov r9, hdcMem
	mov QWORD PTR [rsp+32], r9
	lea r9, sizeSplash
	lea r8, ptOrigin
	mov rdx, hdcScreen
	mov rcx, hwndSplash
	call UpdateLayeredWindow	; invoke UpdateLayeredWindow, hwndSplash, hdcScreen, ADDR ptOrigin, ADDR sizeSplash, hdcMem, ADDR ptZero, 000000000h, ADDR blend, ULW_ALPHA

	; Delete temporary objects
		mov rdx, hbmpOld
		mov rcx, hdcMem
		call SelectObject		; invoke SelectObject, hdcMem, hbmpOld
		mov rcx, hdcMem
		call DeleteDC			; invoke DeleteDC, hdcMem
		mov rdx, hdcScreen
		mov rcx, NULL
		call ReleaseDC			; invoke ReleaseDC, NULL, hdcScreen

	; Set the splash window in TOPMOST position
	mov QWORD PTR [rsp+48], SWP_SHOWWINDOW	; window-positioning options (0x0040);
	mov r9d, sizeSplash.y
	mov DWORD PTR [rsp+40], r9d				; height
	mov r9d, sizeSplash.x
	mov DWORD PTR [rsp+32], r9d				; width
	mov r9d, ptOrigin.y						; vertical position
	mov r8d, ptOrigin.x						; horizontal position
	mov rdx, HWND_TOPMOST					; placement-order handle ((HWND)-1)
	mov rcx, hwndSplash						; handle to window
	call SetWindowPos		; invoke SetWindowPos, hwndSplash, HWND_TOPMOST, ptOrigin.x, ptOrigin.y, sizeSplash.x, sizeSplash.y, SWP_SHOWWINDOW

	add rsp, r15	; Restore the stack pointer to point below the shallow space
	ret
CSplashScreen_SetSplashImage ENDP

CSplashScreen_LaunchApplication PROC uses rbx rdi r15 lpTHIS:QWORD
	LOCAL szCurrentFolder[MAX_PATH]:WORD
	LOCAL szApplicationPath[MAX_PATH]:WORD
	LOCAL startupinfo:STARTUPINFO
	LOCAL processinfo:PROCESS_INFORMATION
	
	; Initialize structs to 0
	mov rcx, SIZEOF startupinfo
	xor rax, rax
	lea rdi, startupinfo
	rep stosb
	
	mov rcx, SIZEOF processinfo
	xor rax, rax
	lea rdi, processinfo
	rep stosb

	mov r15, rsp
	sub rsp, 8 * 10	; Shallow space for Win32 API x64-calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls
	mov rdi, lpTHIS	; Get this pointer
	 
	; Get folder of the current process
	mov r8, MAX_PATH
	lea rdx, szCurrentFolder
	mov rcx, NULL
	call GetModuleFileName		; invoke GetModuleFileName, NULL, ADDR szCurrentFolder, MAX_PATH
	lea rcx, szCurrentFolder
	call PathRemoveFileSpec		; invoke PathRemoveFileSpec, ADDR szCurrentFolder	; http://masm32.com/board/index.php?topic=3646.0

	mov rbx, (CSplashScreen PTR [rdi]).lpszAppPath
	
	; Add the application name to the path
	cmp WORD PTR[rbx+2], 58		; .IF (WORD PTR[rax+2]==58 && WORD PTR[rax+4]==92) ; ":" && "\\"
	jne CSplashScreen_LaunchApplication_False_01
	cmp WORD PTR[rbx+4], 92
	jne CSplashScreen_LaunchApplication_False_01
	jmp CSplashScreen_LaunchApplication_EndIf_01
	CSplashScreen_LaunchApplication_False_01:
		mov r8, (CSplashScreen PTR [rdi]).lpszAppPath
		lea rdx, szCurrentFolder
		lea rbx, szApplicationPath
		mov rcx, rbx
		call PathCombine		; invoke PathCombine, ebx, ADDR szCurrentFolder, [rdi].lpszAppPath
	CSplashScreen_LaunchApplication_EndIf_01:

	; Start the application
	mov startupinfo.cb, SIZEOF startupinfo
	call GetCommandLine			; invoke GetCommandLine
	lea r9, processinfo
	mov QWORD PTR [rsp+72], r9
	lea r9, startupinfo
	mov QWORD PTR [rsp+64], r9
	lea r9, szCurrentFolder
	mov QWORD PTR [rsp+56], r9
	mov QWORD PTR [rsp+48], NULL
	mov QWORD PTR [rsp+40], 0
	mov QWORD PTR [rsp+32], FALSE
	mov r9, NULL
	mov r8, NULL
	mov rdx, rax
	mov rcx, rbx
	call CreateProcess			; invoke CreateProcess, ADDR szApplicationPath, CommandLine, NULL, NULL, FALSE, 0, NULL, ADDR szCurrentFolder, ADDR startupinfo, ADDR processinfo

	; Release in order to avoid memory leaks
	mov rcx, processinfo.hThread
	call CloseHandle			; invoke CloseHandle, processinfo.hThread

	; Return the handle of the launched application. The caller should release this using CloseHandle
	mov rax, processinfo.hProcess
	
	add rsp, r15	; Restore the stack pointer to point below the shallow space
	ret
CSplashScreen_LaunchApplication ENDP

CSplashScreen_PumpMsgWaitForMultipleObjects PROC uses rbx rdi r13 r14 r15 lpTHIS:QWORD, hwndSplash:HWND, nCount:DWORD, pHandles:LPHANDLE, dwMilliseconds:DWORD, hdcScreen:HDC

	LOCAL msg		:MSG

	mov r15, rsp
	sub rsp, 8 * 4	; Shallow space for Win32 API x64-calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls
	mov rdi, lpTHIS	; Get this pointer

	; Wait for a handle to be signaled
	mov r9d, dwMilliseconds
	mov r8, FALSE
	mov rdx, pHandles
	mov ecx, nCount
	call WaitForMultipleObjects
	mov r14d, eax

	cmp r14d, 1
	jne CSplashScreen_End_If_01
		; Timeout on actual wait or any other object
		mov r9, NULL
		mov r8, 30
		mov rdx, 1
		mov rcx, hwndSplash
		call SetTimer		; invoke SetTimer, hwndSplash, 1, 30, NULL
		call GetTickCount	; invoke GetTickCount
		add eax, (CSplashScreen PTR [rdi]).intFadeOutTime
		mov (CSplashScreen PTR [rdi]).intFadeOutEnd, eax
		
		; Loop through the messages
		mov r13, 1			; bGetMsg = TRUE
		While_GetMsg_Start:	; loop while r13 != FALSE
			cmp r13, FALSE
			je While_GetMsg_End

			mov r9, 0
			mov r8, 0
			mov rdx, hwndSplash
			lea rcx, msg
			call GetMessage	; invoke GetMessage, ADDR msg, hwndSplash, 0, 0
			mov rbx, rax	; this can be equal to -1 (error), 0 (WM_QUIT), or else (TRUE)
			
			mov rdx, 0
			mov rcx, pHandles
			call WaitForSingleObject
			cmp rax, WAIT_OBJECT_0
			jne CSplashScreen_End_If_02
				mov rbx, 0	; If the launched application is no longer running, assimilate it to a WM_QUIT
			CSplashScreen_End_If_02:

			; Switch case WaitForSingleObject: -1, 0 and else
			cmp rbx, -1
			jne CSplashScreen_Switch_Case_02
				; Hanlde the error
			CSplashScreen_Switch_Case_02:
				cmp rbx, 0
				jne CSplashScreen_Switch_Case_Def
				mov r13, FALSE
				jmp CSplashScreen_Switch_End_01
			CSplashScreen_Switch_Case_Def:
				cmp msg.message, WM_TIMER
				jne CSplashScreen_End_If_03
					mov rax, hdcScreen
					mov QWORD PTR [rsp + 16], rax			; hdcScreen
					mov rax, hwndSplash
					mov QWORD PTR [rsp + 8], rax
					mov QWORD PTR [rsp], rdi
					call CSplashScreen_FadeWindowOut	; FadeWindowOut(hWnd, hdcScreen)
					cmp rax, 1
					jne CSplashScreen_Switch_End_01
						mov r13, FALSE
				CSplashScreen_End_If_03:
			CSplashScreen_Switch_End_01:

			; Dispatch thread message
			lea rcx, msg
			call TranslateMessage	; invoke TranslateMessage, ADDR msg
			lea rcx, msg
			call DispatchMessage	; invoke DispatchMessage, ADDR msg

			jmp While_GetMsg_Start

		While_GetMsg_End:

	CSplashScreen_End_If_01:
	
	mov rax, r14	; Return WaitForMultipleObjects value
	add rsp, r15	; Restore the stack pointer to point below the shallow space
	ret
CSplashScreen_PumpMsgWaitForMultipleObjects ENDP

CSplashScreen_FadeWindowOut PROC uses rdi r15 lpTHIS:QWORD, hWindow:HWND, hdcScreen:HDC
	LOCAL dtNow:DWORD
	;LOCAL cte:DWORD
	;LOCAL result:DWORD
	
	mov r15, rsp
	sub rsp, 8 * 9	; Shallow space for Win32 API x64-calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	sub r15, rsp	; r15 stores the shallow space needed for Win32 API x64 calls
	mov rdi, lpTHIS	; Get this pointer

	call GetTickCount		; invoke GetTickCount
	mov dtNow, eax

	cmp eax, (CSplashScreen PTR [rdi]).intFadeOutEnd	; .IF (eax >= [edi].intFadeOutEnd)
	jl CSplashScreen_FadeWindowOut_False_01
		mov rax, 1		; Return true (we are done with the fade out)
		jmp CSplashScreen_FadeWindowOut_EndIf_01
	CSplashScreen_FadeWindowOut_False_01:
		; Floating point computation of the blend parameter
		;mov cte, 255
		;fild [edi].intFadeOutEnd
		;fild dtNow
		;fsubp st(1), st(0)
		;fild [edi].intFadeOutTime
		;fdivp st(1), st(0)
		;fild cte
		;fmulp st(1), st(0)
		;fistp result
		;mov eax, result
		
		; Same computation using SSE
		; double fade = ((double)m_nFadeoutEnd - (double)dtNow) / (double)m_nFadeoutTime;
		xorps xmm0, xmm0	; 128-bit wide registers
		xorps xmm1, xmm1
		mov eax, (CSplashScreen PTR [rdi]).intFadeOutEnd
		cvtsi2sd xmm0, eax
		mov eax, dtNow
		cvtsi2sd xmm1, eax
		subsd xmm0, xmm1
		mov eax, (CSplashScreen PTR [rdi]).intFadeOutTime  
		cvtsi2sd xmm1, eax  
		divsd xmm0, xmm1
		
		mov eax, 255d
		cvtsi2sd xmm1, eax
		;movsd xmm1, mmword ptr[255]
		mulsd xmm0, xmm1  
		cvttsd2si rax, xmm0  

		mov (CSplashScreen PTR [rdi]).blend.SourceConstantAlpha, al	; BYTE PTR [eax]

		mov QWORD PTR [rsp+64], ULW_ALPHA
		;lea r9, (CSplashScreen PTR [rdi]).blend
		lea r9, (CSplashScreen PTR [rdi]).blend
		mov QWORD PTR [rsp+56], r9
		mov DWORD PTR [rsp+48], 000000000h
		mov QWORD PTR [rsp+40], NULL
		mov QWORD PTR [rsp+32], NULL
		mov r9, NULL
		mov r8, NULL
		mov rdx, hdcScreen
		mov rcx, hWindow
		call UpdateLayeredWindow		; invoke UpdateLayeredWindow, hWindow, hdcScreen, NULL, NULL, NULL, NULL, 000000000h, eax, ULW_ALPHA
		mov rax, 0		; Return false (we are still fading out the window)
	CSplashScreen_FadeWindowOut_EndIf_01:

	add rsp, r15	; Restore the stack pointer to point below the shallow space
	ret
CSplashScreen_FadeWindowOut ENDP





CenterWindow PROC hWindow:QWORD
	LOCAL DlgHeight:DWORD 
	LOCAL DlgWidth:DWORD
	LOCAL DlgRect:RECT
	LOCAL DesktopRect:RECT
	
	sub rsp, 8 * 6	; Shallow space for Win32 API x64-calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits boundary
	;mov rdi, lpTHIS	; Get this pointer

	lea rdx, DlgRect
	mov rcx, hWindow
	call GetWindowRect		; invoke GetWindowRect,hWindow,addr DlgRect 
	call GetDesktopWindow	; invoke GetDesktopWindow 
	lea rdx, DesktopRect
	mov rcx, rax 
	call GetWindowRect	; invoke GetWindowRect,ecx,addr DesktopRect 
	
	mov QWORD PTR [rsp+40], 0		; 6th parameter
	mov  eax, DlgRect.bottom 
	sub  eax, DlgRect.top 
	mov  DlgHeight,eax 
	mov QWORD PTR [rsp+32], rax		; 5th parameter
	mov  eax, DlgRect.right 
	sub  eax, DlgRect.left 
	mov  DlgWidth,eax 
	mov r9, rax						; 4th parameter
	mov  eax, DesktopRect.bottom 
	sub  eax, DlgHeight 
	shr  eax, 1 
	mov r8, rax						; 3rd parameter
	mov  eax, DesktopRect.right 
	sub  eax, DlgWidth 
	shr  eax, 1 
	mov rdx, rax					; 2nd parameter
	mov rcx, hWindow				; 1st parameter
	call MoveWindow
	ret
CenterWindow ENDP


WindowProc  PROC ;, hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM   ; must be naked
uMsg    textequ < QWORD PTR [rsp + 8] >
    cmp     uMsg, WM_DESTROY
    je      OnDestroy
    cmp     uMsg, WM_PAINT
    je      OnPaint
    jmp     DefWindowProc
    int     3

WindowProc  ENDP

OnDestroy   PROC ;, hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    mov rcx, 0
	call PostQuitMessage	; invoke  PostQuitMessage, 0
    xor     rax, rax
    ret
OnDestroy   ENDP

OnPaint     PROC ;, hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	;local   ps:PAINTSTRUCT
	;invoke  BeginPaint, hwnd, addr ps
    ;invoke  FillRect, ps.hdc, addr ps.rcPaint, COLOR_WINDOW + 1
    ;invoke  EndPaint, hwnd, addr ps

    xor     rax, rax
    ret
OnPaint	ENDP



ENDIF