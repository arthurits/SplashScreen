ifndef __UNICODE__
__UNICODE__ equ 1
endif

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

.data?
; --=====================================================================================--
; CLASS STRUCTURE
; --=====================================================================================--
	CSplashScreen STRUCT
		Destructor				QWORD	?
		Show					QWORD	?
		RegisterWindowClass		QWORD	?
		UnregisterWindowClass	QWORD	?
		CreateBitmapImage		QWORD	?
		lpModuleName			LPCSTR	?
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
		QWORD OFFSET CSplashScreen_CreateBitmapImage
		QWORD OFFSET CSplashScreen_RegisterWindowClass
		QWORD OFFSET CSplashScreen_UnregisterWindowClass
		QWORD OFFSET CSplashScreen_CreateBitmapImage
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
	MAXPATH equ 260

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
	shr 	rcx, 2
	rep 	movsq
	mov 	rcx, CSplashScreen_initend
	and 	rcx, 7
	rep 	movsb

	; Personalized initialization code
	mov  rdi, lpTHIS

		mov rax, hInstance
		mov (CSplashScreen PTR [rdi]).lpModuleName, rax
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
CSplashScreen_Show PROC uses rdi lpTHIS:QWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	LOCAL hCloseSplashEvent :QWORD
	LOCAL hCloseSplashWithoutFadeEvent :QWORD
	LOCAL hBitmap :QWORD
	LOCAL aHandles[3] :QWORD	; http://masm32.com/board/index.php?topic=5620.0
	LOCAL hSplashWnd :HANDLE
	LOCAL hdcScreen	:HDC
	
	sub rsp, 8 * 4	; Shallow space for Win64 calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bitsdure

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
	mov r9, ADDR strEventName_1
	mov r8, FALSE
	mov rdx, TRUE
	mov rcx, NULL
	call CreateEvent	; invoke CreateEvent, NULL, TRUE, FALSE, ADDR strEventName_1
	mov hCloseSplashEvent, rax

	call GetLastError	; invoke GetLastError
	cmp rax, ERROR_ALREADY_EXISTS	; .IF (eax == ERROR_ALREADY_EXISTS)		ERROR_ALREADY_EXISTS = 183
	je exit_Show					; rax == ERROR_ALREADY_EXISTS, then exit function

	; Create the event CloseSplashScreenWithoutFadeEvent
	mov r9, ADDR strEventName_2
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
	mov QWORD [rsp], rdi
	call CSplashScreen_CreateBitmapImage
	mov hBitmap, rax

	cmp rax, NULL	; .IF (hBitmap!=NULL)
	je exit_Show		; if hBitmap==0 then exit
		; if hBitmap exists, then create the splash window and set the bitmap image
		call CSplashScreen_RegisterWindowClass
		call CSplashScreen_CreateSplashWindow
		mov hSplashWnd, rax
		
		mov QWORD [rsp + 16], hBitmap
		mov QWORD [rsp + 8], rax
		; mov QWORD [rsp], rdi		; Not necessary, it's already there
		call CSplashScreen_SetSplashImage	; returns rax=0 if unsuccessful

	cmp rax, NULL	; .IF (eax!=0)
	je exit_Show	; if rax==0 then exit
		; if file exists, then launch the application
		call CSplashScreen_LaunchApplication	; Returns the handle of the launched application in eax

		mov rbx, rax
		mov rcx, rax
		call GetProcessId	; invoke GetProcessId, eax
		mov rcx, rax
		call AllowSetForegroundWindow	; invoke AllowSetForegroundWindow, eax
		
		lea rax, aHandles 
		mov DWORD PTR [rax + 0], rbx
		mov rbx, hCloseSplashEvent
		mov DWORD PTR [rax + 8], rbx
		mov rbx, hCloseSplashWithoutFadeEvent
		mov DWORD PTR [rax + 16], rbx
		
		push INFINITE
		push rax
		push 3
		push hSplashWnd
		push rdi
		call CSplashScreen_PumpMsgWaitForMultipleObjects	; lpTHIS:QWORD, hwndSplash:HWND, nCount:DWORD, pHandles:LPHANDLE, dwMilliseconds:DWORD
		add rsp, 40

	exit_Show:
	mov rdx, hdcScreen
	mov rcx, NULL
	call ReleaseDC	; invoke ReleaseDC, NULL, hdcScreen

	; Deallocate the hbitmap
	mov rcx, hBitmap
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
	push rdi
	call CSplashScreen_UnregisterWindowClass

	; Close the COM library
	call CoUninitialize		; invoke CoUninitialize

	;add rsp, r15	; Restore the stack pointer to point to the return address
	ret
CSplashScreen_Show ENDP

;--------------------------------------------------------
CSplashScreen_CreateBitmapImage PROC uses rdi lpTHIS:QWORD
;
; Opens a file, creates a handle and creates a w_char pointer
; Receives: EAX, EBX, ECX, the three integers. May be
; signed or unsigned.
; Returns: EAX = sum, and the status flags (Carry, ; Overflow, etc.) are changed.
; Requires: nothing
;---------------------------------------------------------
	;LOCAL hGdiImage :DWORD
	;LOCAL wbuffer :DWORD
	LOCAL hBitmap :QWORD
	LOCAL image :BITMAP
	LOCAL GpBitmap :QWORD		; Pointer to GpBitmap
	LOCAL GpGraphics :QWORD		; Pointer to GpGraphics
	LOCAL GpSolidFill :QWORD	; Pointer to GpSolidFill
	LOCAL lpImage	:QWORD

	;mov hGdiImage, 0
	mov hBitmap, 0
	mov GpBitmap, 0
	mov GpGraphics, 0
	mov GpSolidFill, 0
	
	sub rsp, 8 * 6	; Shallow space for Win64 calls
	and rsp, -10h	; Add 8 bits if needed to align to 16 bits

	mov  rdi, lpTHIS

	mov gdipSI.GdiplusVersion, 1
	mov gdipSI.SuppressBackgroundThread, 0
	invoke GdiplusStartup, ADDR gdiToken, ADDR gdipSI, NULL

	; If GDI could not be started, then exit
	.IF gdiToken == 0
		jmp exit_CreateBitmapImage
	.ENDIF
	
	;invoke GdipCreateBitmapFromFile, ADDR ImagePath, ADDR hGdiImage
	invoke GdipCreateBitmapFromFile, [edi].lpszImagePath, ADDR GpBitmap
	.IF (GpBitmap == NULL)
		jmp exit_DefaultBitmap
	.ENDIF
	invoke GdipCreateHBITMAPFromBitmap, GpBitmap, ADDR hBitmap, m_SplashBackgroundColor
	.IF (hBitmap == NULL)
		jmp exit_DefaultBitmap
	.ENDIF
	invoke GdipDisposeImage, GpBitmap
	;invoke GetObject, hBitmap, SIZEOF image, ADDR image
	jmp exit_CreateBitmapImage

	; Creates a default bitmap (colors and dimensions defined atop)
	; More information here: http://masm32.com/board/index.php?topic=5731.15
	exit_DefaultBitmap:

	invoke GdipCreateBitmapFromScan0, m_nSplashWidth, m_nSplashHeight, 0, PixelFormat32bppARGB, NULL, ADDR GpBitmap
	invoke GdipGetImageGraphicsContext, GpBitmap, ADDR GpGraphics
	invoke GdipCreateSolidFill, m_SplashColor, ADDR GpSolidFill
	invoke GdipFillRectangleI, GpGraphics, GpSolidFill, 0, 0, m_nSplashWidth, m_nSplashHeight
	invoke GdipCreateHBITMAPFromBitmap, GpBitmap, ADDR hBitmap, m_SplashBackgroundColor 

	invoke GdipFree, GpSolidFill
	invoke GdipFree, GpGraphics
	invoke GdipDisposeImage, GpBitmap
	


	exit_CreateBitmapImage:

	invoke GdiplusShutdown, ADDR gdiToken
	mov eax, hBitmap	; This has to be deallocated later by the user

	; add rsp, r15	; Restore the stack pointer to point to the return address
	ret
CSplashScreen_CreateBitmapImage ENDP

; --=====================================================================================--
; Registers a window class for the splash and splash owner windows.
; --=====================================================================================--
CSplashScreen_RegisterWindowClass PROC uses rdi lpTHIS:QWORD
	; https://gist.github.com/DrFrankenstein/9810bbf5cad98b110281
	LOCAL   wc: WNDCLASS

	;Initialize wc with zeroes
    mov     ecx, sizeof WNDCLASS
    xor     eax, eax
    lea     rdi, wc
    rep stosb

	; Get this pointer
	mov  rdi, lpTHIS

    ;Register the window class
    ;mov     wc.lpfnWndProc, OFFSET WindowProc
	mov     wc.lpfnWndProc, DefWindowProc	; http://masm32.com/board/index.php?topic=2469.0
    invoke  GetModuleHandle, 0
    mov     wc.hInstance, eax
    mov     wc.lpszClassName, OFFSET strClassName
    invoke  RegisterClass, ADDR wc

	;Register the window class
	;wc.lpfnWndProc = DefWindowProc;
	;wc.hInstance = m_hInstance;
	;wc.hIcon = LoadIcon(m_hInstance, MAKEINTRESOURCE(IDI_SPLASHICON));
	;wc.hCursor = LoadCursor(NULL, IDC_ARROW); 
	;wc.lpszClassName = m_strSplashClass.c_str();

	ret
CSplashScreen_RegisterWindowClass ENDP

; --=====================================================================================--
; Registers a window class for the splash and splash owner windows.
; --=====================================================================================--
CSplashScreen_UnregisterWindowClass PROC uses rdi lpTHIS:QWORD
	mov  rdi, lpTHIS

	;invoke GetModuleHandle, 0
	invoke UnregisterClass, OFFSET strClassName, (CSplashScreen PTR [rdi]).lpModuleName

	assume rdi:nothing
	ret
CSplashScreen_UnregisterWindowClass ENDP


CSplashScreen_CreateSplashWindow PROC uses edi lpTHIS:DWORD
	mov  edi, lpTHIS
	assume edi:PTR CSplashScreen

	;push NULL
	;push [edi].lpModuleName
	;push NULL
	;push NULL
	;push 0
	;push 0
	;push 0
	;push 0
	;mov eax, WS_POPUP or WS_VISIBLE
	;push eax
	;push NULL
	;lea eax, strClassName
	;push eax
	;mov eax, WS_EX_LAYERED or WS_EX_TOOLWINDOW or WS_EX_TOPMOST
	;push eax
	;call CreateWindowEx

	invoke CreateWindowEx, WS_EX_LAYERED or WS_EX_TOOLWINDOW or WS_EX_TOPMOST, OFFSET strClassName, NULL, WS_POPUP or WS_VISIBLE, 0, 0, 0, 0, NULL, NULL, [edi].lpModuleName, NULL
	; https://tuttlem.github.io/2015/09/14/windows-programs-with-masm32.html
	
	assume edi:nothing
	ret
CSplashScreen_CreateSplashWindow ENDP

CSplashScreen_SetSplashImage PROC uses edi lpTHIS:DWORD, hwndSplash:HWND, hbmpSplash:HBITMAP
	LOCAL bm :BITMAP			; defined in wingdi.h
	LOCAL ptZero :POINT			; defined in windef.h
	LOCAL ptOrigin :POINT		; defined in windef.h
	LOCAL sizeSplash :_SIZE		; defined in windef.h
	LOCAL hmonPrimary :HMONITOR	; defined in windef.h
	LOCAL monitorinfo :MONITORINFO	;defined in WinUser.h
	;LOCAL rcWork :RECT		; defined in
	LOCAL hdcScreen :HDC	; defined in
	LOCAL hdcMem :HDC		; defined in
	LOCAL hbmpOld :HBITMAP	; defined in
	LOCAL blend :BLENDFUNCTION	; defined in wingdi.h

	; Initialize structs
	mov ptZero.x, 0
	mov ptZero.y, 0

    mov     ecx, SIZEOF monitorinfo
    xor     eax, eax
    lea     edi, monitorinfo
    rep stosb

	; Get this pointer
	mov  edi, lpTHIS
	assume edi:PTR CSplashScreen

	; Get the dimensions of the bitmap used as the splash screen
	invoke GetObject, hbmpSplash, SIZEOF bm, ADDR bm
	mov eax, bm.bmWidth
	mov sizeSplash.x, eax
	mov eax, bm.bmHeight
	mov sizeSplash.y, eax
	
	; Get the primary monitor's info
	invoke MonitorFromPoint, ptZero.x, ptZero.y, MONITOR_DEFAULTTOPRIMARY	; 0x00000001
	mov hmonPrimary, eax
	mov eax, SIZEOF monitorinfo
	mov monitorinfo.cbSize, eax
	invoke GetMonitorInfo, hmonPrimary, ADDR monitorinfo

	; Center the bitmap into the primary monitor
	mov eax, monitorinfo.rcMonitor.right	; rcWork plus the windows taskbar
	sub eax, monitorinfo.rcMonitor.left
	sub eax, sizeSplash.x
	shr eax, 1
	add eax, monitorinfo.rcMonitor.left
	mov ptOrigin.x, eax

	mov eax, monitorinfo.rcMonitor.bottom
	sub eax, monitorinfo.rcMonitor.top
	sub eax, sizeSplash.y
	shr eax, 1
	add eax, monitorinfo.rcMonitor.top
	mov ptOrigin.y, eax

	; Create a memory DC holding the splash bitmap
	invoke GetDC, 0
	mov hdcScreen, eax
	invoke CreateCompatibleDC, hdcScreen
	mov hdcMem, eax
	invoke SelectObject, hdcMem, hbmpSplash
	mov hbmpOld, eax
	
	; Use the source image's alpha channel for blending
	mov blend.BlendOp, AC_SRC_OVER		; 0x00
	mov blend.BlendFlags, 0				; 0x00
	mov blend.SourceConstantAlpha, 255	; 0xFF
	mov blend.AlphaFormat, AC_SRC_ALPHA	; 0x01
	; delete comment
	; Paint the window (in the right location) with the alpha-blended bitmap
	invoke UpdateLayeredWindow, hwndSplash, hdcScreen, ADDR ptOrigin, ADDR sizeSplash, hdcMem, ADDR ptZero, 000000000h, ADDR blend, ULW_ALPHA

	; Delete temporary objects
	invoke SelectObject, hdcMem, hbmpOld
	invoke DeleteDC, hdcMem
	invoke ReleaseDC, NULL, hdcScreen

	invoke SetWindowPos, hwndSplash,	; handle to window
				HWND_TOPMOST,			; placement-order handle ((HWND)-1)
				ptOrigin.x,				; horizontal position
				ptOrigin.y,				; vertical position
				sizeSplash.x,			; width
				sizeSplash.y,			; height
				SWP_SHOWWINDOW			; window-positioning options (0x0040);


	assume edi:nothing
	ret
CSplashScreen_SetSplashImage ENDP

CSplashScreen_LaunchApplication PROC uses edi lpTHIS:DWORD
	LOCAL szCurrentFolder[MAX_PATH]:WORD
	LOCAL szApplicationPath[MAX_PATH]:WORD
	LOCAL startupinfo:STARTUPINFO
	LOCAL processinfo:PROCESS_INFORMATION
	
	; Initialize structs to 0
	mov ecx, SIZEOF startupinfo
	xor eax, eax
	lea edi, startupinfo
	rep stosb
	
	mov ecx, SIZEOF processinfo
	xor eax, eax
	lea edi, processinfo
	rep stosb

	; Set this pointer
	mov  edi, lpTHIS
	assume edi:PTR CSplashScreen
	 
	; Get folder of the current process
	invoke GetModuleFileName, NULL, ADDR szCurrentFolder, MAX_PATH
	invoke PathRemoveFileSpec, ADDR szCurrentFolder	; http://masm32.com/board/index.php?topic=3646.0

	mov ebx, [edi].lpszAppPath
	
	; Add the application name to the path
	.IF (WORD PTR[ebx+2]==58 && WORD PTR[ebx+4]==92) ; ":" && "\\"
		;mov lpszApplicationPath, eax
	.ELSE
		lea ebx, szApplicationPath
		invoke PathCombine, ebx, ADDR szCurrentFolder, [edi].lpszAppPath
		;invoke PathCombine, ADDR szApplicationPath, ADDR szCurrentFolder, [edi].lpszAppPath
	.ENDIF

	; Start the application
	mov startupinfo.cb, SIZEOF startupinfo
	invoke GetCommandLine
	mov ecx, eax
	invoke CreateProcess, ebx, ecx, NULL, NULL, FALSE, 0, NULL, ADDR szCurrentFolder, ADDR startupinfo, ADDR processinfo
	;mov ebx, eax
	;invoke CreateProcess, ADDR szApplicationPath, ebx, NULL, NULL, FALSE, 0, NULL, ADDR szCurrentFolder, ADDR startupinfo, ADDR processinfo

	; Release in order to avoid memory leaks
	invoke CloseHandle, processinfo.hThread

	; Return the handle of the launched application. The caller should release this using CloseHandle
	mov eax, processinfo.hProcess
	
	assume edi:nothing
	ret
CSplashScreen_LaunchApplication ENDP

CSplashScreen_PumpMsgWaitForMultipleObjects PROC uses edi lpTHIS:DWORD, hwndSplash:HWND, nCount:DWORD, pHandles:LPHANDLE, dwMilliseconds:DWORD, hdcScreen:HDC
	LOCAL dwStartTickCount	:DWORD
	LOCAL dwElapsed			:DWORD
	LOCAL dwTimeOut			:DWORD
	LOCAL dwWaitResult		:DWORD
	;LOCAL hdcScreen			:HDC
	LOCAL msg				:MSG

	mov edi, lpTHIS
	assume edi: PTR CSplashScreen

	invoke GetTickCount
	mov dwStartTickCount, eax

	Wait_Loop:
		; Calculate timeout
		invoke GetTickCount
		sub eax, dwStartTickCount
		mov dwElapsed, eax

		.IF (dwMilliseconds == INFINITE)
			mov dwTimeOut, INFINITE
		.ELSE
			.IF (eax < dwMilliseconds)		; dwElapsed < dwMilliseconds
				mov eax, dwMilliseconds
				sub eax, dwElapsed
				mov dwTimeOut, eax
				;sub dwTimeOut, dwElapsed
			.ELSE
				mov dwTimeOut, 0
			.ENDIF
		.ENDIF

		; Wait for a handle to be signaled or a message
		invoke MsgWaitForMultipleObjects, nCount, pHandles, FALSE, dwTimeOut, QS_ALLINPUT
		mov dwWaitResult, eax
		mov eax, WAIT_OBJECT_0
		add eax, nCount
		.IF ( dwWaitResult == eax )		; dwWaitResult == WAIT_OBJECT_0 + nCount

			jmp While_Peek_Condition	; While PeekMessage != FALSE

			While_Peek_Start:
				.IF (msg.message == WM_QUIT)
					; Repost quit message and return
					invoke PostQuitMessage, msg.wParam
					;return WAIT_OBJECT_0 + nCount;
					jmp exit_PumpMsgWaitForMultipleObjects
				.ENDIF
				; Dispatch thread message
				invoke TranslateMessage, ADDR msg
				invoke DispatchMessage, ADDR msg

			While_Peek_Condition:
				invoke PeekMessage, ADDR msg, NULL, 0, 0, PM_REMOVE
				cmp eax, FALSE
				jne While_Peek_Start	; execute while eax != FALSE

		.ELSE
			; Check fade event (pHandles[1]).  If the fade event is not set then we simply need to exit.  
			; if the fade event is set then we need to fade out
			mov ebx, pHandles	; Pointer to the beginning of the array
			add ebx, 4			; Point to the second element: pHandles[1]
			invoke MsgWaitForMultipleObjects, 1, ebx, FALSE, 0, QS_ALLINPUT
			.IF (eax == WAIT_OBJECT_0)

				; Timeout on actual wait or any other object
				invoke SetTimer, hwndSplash, 1, 30, NULL
				invoke GetTickCount
				add eax, [edi].intFadeOutTime
				mov [edi].intFadeOutEnd, eax

				jmp FadeWindow_Condition

				FadeWindow_Start:
					.IF (eax == -1)
						; Handle the error and possibly exit
					.ELSE
						.IF (msg.message == WM_TIMER)
							push hdcScreen
							push hwndSplash
							push edi
							call CSplashScreen_FadeWindowOut
							cmp eax, 1
							je exit_PumpMsgWaitForMultipleObjects
						.ENDIF
						; Dispatch thread message
						invoke TranslateMessage, ADDR msg
						invoke DispatchMessage, ADDR msg
					.ENDIF
				FadeWindow_Condition:
					invoke GetMessage, ADDR msg, hwndSplash, 0, 0
					cmp eax, FALSE
					jne FadeWindow_Start
			.ENDIF

			jmp exit_PumpMsgWaitForMultipleObjects

		.ENDIF
	jmp Wait_Loop

	exit_PumpMsgWaitForMultipleObjects:

	assume edi:nothing
	ret
CSplashScreen_PumpMsgWaitForMultipleObjects ENDP

CSplashScreen_FadeWindowOut PROC uses edi lpTHIS:DWORD, hWindow:HWND, hdcScreen:HDC
	LOCAL dtNow:DWORD
	LOCAL cte:DWORD
	LOCAL result:DWORD
	
	mov  edi, lpTHIS
	assume edi:PTR CSplashScreen

	invoke GetTickCount
	mov dtNow, eax

	.IF (eax >= [edi].intFadeOutEnd)
		mov eax, 1		; Return true (we are done with the fade out)
	.ELSE
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
		mov eax, [edi].intFadeOutEnd
		cvtsi2sd xmm0, eax
		mov eax, dtNow
		cvtsi2sd xmm1, eax
		subsd xmm0, xmm1
		mov eax, [edi].intFadeOutTime  
		cvtsi2sd xmm1, eax  
		divsd xmm0, xmm1
		
		mov eax, 255d
		cvtsi2sd xmm1, eax
		;movsd xmm1, mmword ptr[255]
		mulsd xmm0, xmm1  
		cvttsd2si eax, xmm0  

		mov [edi].blend.SourceConstantAlpha, al	; BYTE PTR [eax]
		lea eax, [edi].blend
		invoke UpdateLayeredWindow, hWindow, hdcScreen, NULL, NULL, NULL, NULL, 000000000h, eax, ULW_ALPHA
		mov eax, 0		; Return false (we are still fading out the window)
	.ENDIF

	assume edi:nothing
	ret
CSplashScreen_FadeWindowOut ENDP





CenterWindow proc hWindow:DWORD
	LOCAL DlgHeight:DWORD 
	LOCAL DlgWidth:DWORD
	LOCAL DlgRect:RECT
	LOCAL DesktopRect:RECT
	
	invoke GetWindowRect,hWindow,addr DlgRect 
	invoke GetDesktopWindow 
	mov ecx,eax 
	invoke GetWindowRect,ecx,addr DesktopRect 
	push  0 
	mov  eax,DlgRect.bottom 
	sub  eax,DlgRect.top 
	mov  DlgHeight,eax 
	push eax 
	mov  eax,DlgRect.right 
	sub  eax,DlgRect.left 
	mov  DlgWidth,eax 
	push eax 
	mov  eax,DesktopRect.bottom 
	sub  eax,DlgHeight 
	shr  eax,1 
	push eax 
	mov  eax,DesktopRect.right 
	sub  eax,DlgWidth 
	shr  eax,1 
	push eax 
	push hWindow 
	call MoveWindow
	ret
CenterWindow endp


WindowProc  PROC ;, hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM   ; must be naked
uMsg    textequ < DWORD PTR [esp + 8] >
    cmp     uMsg, WM_DESTROY
    je      OnDestroy
    cmp     uMsg, WM_PAINT
    je      OnPaint
    jmp     DefWindowProc
    int     3

WindowProc  ENDP

OnDestroy   PROC ;, hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    invoke  PostQuitMessage, 0
    xor     eax, eax
    ret
OnDestroy   ENDP

OnPaint     PROC ;, hwnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
	;local   ps:PAINTSTRUCT
	;invoke  BeginPaint, hwnd, addr ps
    ;invoke  FillRect, ps.hdc, addr ps.rcPaint, COLOR_WINDOW + 1
    ;invoke  EndPaint, hwnd, addr ps

    xor     eax, eax
    ret
OnPaint	ENDP



endif