;
; Function protos to be used only with Windows SDK libraries.
; Not intended to be used with Masm32 SDK.
;

; user32.lib
externdef AllowSetForegroundWindow:PROC

externdef GetDC:PROC

externdef CreateWindowExA:PROC
externdef CreateWindowExW:PROC
  IFDEF __UNICODE__
    CreateWindowEx equ CreateWindowExW
  ELSE
    CreateWindowEx equ CreateWindowExA
  ENDIF

externdef DefWindowProcA:PROC
externdef DefWindowProcW:PROC
  IFDEF __UNICODE__
    DefWindowProc equ DefWindowProcW
  ELSE
    DefWindowProc equ DefWindowProcA
  ENDIF

externdef DestroyWindow:PROC

externdef DispatchMessageA:PROC
externdef DispatchMessageW:PROC
  IFDEF __UNICODE__
    DispatchMessage equ DispatchMessageW
  ELSE
    DispatchMessage equ DispatchMessageA
  ENDIF

externdef GetDesktopWindow:PROC

externdef GetWindowRect:PROC

externdef GetMessageA:PROC
externdef GetMessageW:PROC
  IFDEF __UNICODE__
    GetMessage equ GetMessageW
  ELSE
    GetMessage equ GetMessageA
  ENDIF

externdef MessageBoxA:PROTO
externdef MessageBoxW:PROTO
  IFDEF __UNICODE__
    MessageBox equ MessageBoxW
  ELSE
    MessageBox equ MessageBoxA
  ENDIF

externdef MonitorFromPoint:PROC

externdef MoveWindow:PROC

externdef MsgWaitForMultipleObjects:PROC

externdef MsgWaitForMultipleObjectsEx:PROC

externdef PeekMessageA:PROC
externdef PeekMessageW:PROC
  IFDEF __UNICODE__
    PeekMessage equ PeekMessageW
  ELSE
    PeekMessage equ PeekMessageA
  ENDIF

externdef PostQuitMessage:PROC

externdef RegisterClassExA:PROC
externdef RegisterClassExW:PROC
  IFDEF __UNICODE__
    RegisterClassEx equ RegisterClassExW
  ELSE
    RegisterClassEx equ RegisterClassExA
  ENDIF

externdef ReleaseDC:PROC

externdef SetTimer:PROC

externdef SetWindowPos:PROC

externdef TranslateMessage:PROC

externdef TranslateMessageEx:PROC

externdef UnregisterClassA:PROC
externdef UnregisterClassW:PROC
  IFDEF __UNICODE__
    UnregisterClass equ UnregisterClassW
  ELSE
    UnregisterClass equ UnregisterClassA
  ENDIF

externdef UpdateLayeredWindow:PROC


; Kernel32.lib
externdef CreateEventA:PROC
externdef CreateEventW:PROC
  IFDEF __UNICODE__
    CreateEvent equ CreateEventW
  ELSE
    CreateEvent equ CreateEventA
  ENDIF

externdef GetLastError:PROC

externdef GetProcessId:PROC

externdef SetLastError:PROC

externdef SetProcessId:PROC


; Ole32.lib
externdef CoInitializeEx:PROC

externdef CoUninitialize:PROC


; gdi32.lib
externdef CreateCompatibleDC:PROC

externdef DeleteDC:PROC

externdef DeleteObject:PROC

externdef GdiReleaseDC:PROC

externdef GetMonitorInfoA:PROC
externdef GetMonitorInfoW:PROC
  IFDEF __UNICODE__
    GetMonitorInfo equ GetMonitorInfoW
  ELSE
    GetMonitorInfo equ GetMonitorInfoA
  ENDIF

externdef GetObjectA:PROC
externdef GetObjectW:PROC
  IFDEF __UNICODE__
    GetObject equ GetObjectW
  ELSE
    GetObject equ GetObjectA
  ENDIF

externdef SelectObject:PROC


; gdiplus.lib
externdef GdipCreateBitmapFromFile:PROC

externdef GdipCreateBitmapFromScan0:PROC

externdef GdipCreateHBITMAPFromBitmap:PROC

externdef GdipFillRectangleI:PROC

externdef GdipFree:PROC

externdef GdipCreateSolidFill:PROC

externdef GdipDisposeImage:PROC

externdef GdipGetImageGraphicsContext:PROC

externdef GdiplusShutdown:PROC

externdef GdiplusStartup:PROC


; Kernel32.lib
externdef CreateProcessA:PROC
externdef CreateProcessW:PROC
  IFDEF __UNICODE__
    CreateProcess equ CreateProcessW
  ELSE
    CreateProcess equ CreateProcessA
  ENDIF

externdef GetCommandLineA:PROC
externdef GetCommandLineW:PROC
  IFDEF __UNICODE__
    GetCommandLine equ GetCommandLineW
  ELSE
    GetCommandLine equ GetCommandLineA
  ENDIF

externdef GetModuleHandleA:PROC
externdef GetModuleHandleW:PROC
  IFDEF __UNICODE__
    GetModuleHandle equ GetModuleHandleW
  ELSE
    GetModuleHandle equ GetModuleHandleA
  ENDIF

externdef GetModuleFileNameA:PROC
externdef GetModuleFileNameW:PROC
  IFDEF __UNICODE__
    GetModuleFileName equ GetModuleFileNameW
  ELSE
    GetModuleFileName equ GetModuleFileNameA
  ENDIF

externdef GetTickCount:PROC

externdef ExitProcess:PROC

externdef GetFileAttributesA:PROC
externdef GetFileAttributesW:PROC
  IFDEF __UNICODE__
    GetFileAttributes equ GetFileAttributesW
  ELSE
    GetFileAttributes equ GetFileAttributesA
  ENDIF

externdef GetProcessHeap:PROC

externdef HeapAlloc:PROC

externdef HeapFree:PROC

externdef CloseHandle:PROC

externdef GlobalFree:PROC

externdef CreateFileA:PROC
externdef CreateFileW:PROC
  IFDEF __UNICODE__
    CreateFile equ CreateFileW
  ELSE
    CreateFile equ CreateFileA
  ENDIF

externdef GetFileSizeEx:PROC

externdef GlobalAlloc:PROC

externdef GlobalLock:PROC

externdef ReadFile:PROC

externdef GlobalUnlock:PROC

externdef MultiByteToWideChar:PROC


; shlwapi.lib
externdef PathRemoveFileSpecA:PROC
externdef PathRemoveFileSpecW:PROC
  IFDEF __UNICODE__
    PathRemoveFileSpec equ PathRemoveFileSpecW
  ELSE
    PathRemoveFileSpec equ PathRemoveFileSpecA
  ENDIF

externdef PathCombineA:PROC
externdef PathCombineW:PROC
  IFDEF __UNICODE__
    PathCombine equ PathCombineW
  ELSE
    PathCombine equ PathCombineA
  ENDIF