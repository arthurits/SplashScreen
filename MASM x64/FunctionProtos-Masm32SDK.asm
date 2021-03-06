;
; Function protos to be used only with Masm32 SDK.
; Not intended to be used with Windows SDK libraries.
;

; user32.lib
externdef __imp_AllowSetForegroundWindow:PPROC
AllowSetForegroundWindow equ <__imp_AllowSetForegroundWindow>

externdef __imp_GetDC:PPROC
GetDC equ <__imp_GetDC>

externdef __imp_CreateWindowExA:PPROC
externdef __imp_CreateWindowExW:PPROC
  IFDEF __UNICODE__
    CreateWindowEx equ <__imp_CreateWindowExW>
  ELSE
    CreateWindowEx equ <__imp_CreateWindowExA>
  ENDIF

externdef __imp_DefWindowProcA:PPROC
DefWindowProcA equ <__imp_DefWindowProcA>
externdef __imp_DefWindowProcW:PPROC
DefWindowProcW equ <__imp_DefWindowProcW>
  IFDEF __UNICODE__
    DefWindowProc equ <__imp_DefWindowProcW>
  ELSE
    DefWindowProc equ <__imp_DefWindowProcA>
  ENDIF

externdef __imp_DestroyWindow:PPROC
DestroyWindow equ <__imp_DestroyWindow>

externdef __imp_DispatchMessageA:PPROC
DispatchMessageA equ <__imp_DispatchMessageA>
externdef __imp_DispatchMessageW:PPROC
DispatchMessageW equ <__imp_DispatchMessageW>
  IFDEF __UNICODE__
    DispatchMessage equ <__imp_DispatchMessageW>
  ELSE
    DispatchMessage equ <__imp_DispatchMessageA>
  ENDIF

externdef __imp_GetDesktopWindow:PPROC
GetDesktopWindow equ <__imp_GetDesktopWindow>

externdef __imp_GetWindowRect:PPROC
GetWindowRect equ <__imp_GetWindowRect>

externdef __imp_GetMessageA:PPROC
GetMessageA equ <__imp_GetMessageA>
externdef __imp_GetMessageW:PPROC
GetMessageW equ <__imp_GetMessageW>
  IFDEF __UNICODE__
    GetMessage equ <__imp_GetMessageW>
  ELSE
    GetMessage equ <__imp_GetMessageA>
  ENDIF

externdef __imp_MessageBoxA:PPROC
MessageBoxA equ <__imp_MessageBoxA>
externdef __imp_MessageBoxW:PPROC
MessageBoxW equ <__imp_MessageBoxW>
  IFDEF __UNICODE__
    MessageBox equ <__imp_MessageBoxW>
  ELSE
    MessageBox equ <__imp_MessageBoxA>
  ENDIF

externdef __imp_MonitorFromPoint:PPROC
MonitorFromPoint equ <__imp_MonitorFromPoint>

externdef __imp_MoveWindow:PPROC
MoveWindow equ <__imp_MoveWindow>

externdef __imp_MsgWaitForMultipleObjects:PPROC
MsgWaitForMultipleObjects equ <__imp_MsgWaitForMultipleObjects>

externdef __imp_MsgWaitForMultipleObjectsEx:PPROC
MsgWaitForMultipleObjectsEx equ <__imp_MsgWaitForMultipleObjectsEx>

externdef __imp_PeekMessageA:PPROC
PeekMessageA equ <__imp_PeekMessageA>
externdef __imp_PeekMessageW:PPROC
PeekMessageW equ <__imp_PeekMessageW>
  IFDEF __UNICODE__
    PeekMessage equ <__imp_PeekMessageW>
  ELSE
    PeekMessage equ <__imp_PeekMessageA>
  ENDIF

externdef __imp_PostQuitMessage:PPROC
PostQuitMessage equ <__imp_PostQuitMessage>

externdef __imp_RegisterClassExA:PPROC
RegisterClassExA equ <__imp_RegisterClassExA>
externdef __imp_RegisterClassExW:PPROC
RegisterClassExW equ <__imp_RegisterClassExW>
  IFDEF __UNICODE__
    RegisterClassEx equ <__imp_RegisterClassExW>
  ELSE
    RegisterClassEx equ <__imp_RegisterClassExA>
  ENDIF

externdef __imp_ReleaseDC:PPROC
ReleaseDC equ <__imp_ReleaseDC>

externdef __imp_SetTimer:PPROC
SetTimer equ <__imp_SetTimer>

externdef __imp_SetWindowPos:PPROC
SetWindowPos equ <__imp_SetWindowPos>

externdef __imp_TranslateMessage:PPROC
TranslateMessage equ <__imp_TranslateMessage>

externdef __imp_TranslateMessageEx:PPROC
TranslateMessageEx equ <__imp_TranslateMessageEx>

externdef __imp_UnregisterClassA:PPROC
UnregisterClassA equ <__imp_UnregisterClassA>
externdef __imp_UnregisterClassW:PPROC
UnregisterClassW equ <__imp_UnregisterClassW>
  IFDEF __UNICODE__
    UnregisterClass equ <__imp_UnregisterClassW>
  ELSE
    UnregisterClass equ <__imp_UnregisterClassA>
  ENDIF

externdef __imp_UpdateLayeredWindow:PPROC
UpdateLayeredWindow equ <__imp_UpdateLayeredWindow>


; Kernel32.lib
externdef __imp_CreateEventA:PPROC
externdef __imp_CreateEventW:PPROC
CreateEventW equ <__imp_CreateEventW>
  IFDEF __UNICODE__
    CreateEvent equ <__imp_CreateEventW>
  ELSE
    CreateEvent equ <__imp_CreateEventA>
  ENDIF

externdef __imp_GetLastError:PPROC
GetLastError equ <__imp_GetLastError>

externdef __imp_GetProcessId:PPROC
GetProcessId equ <__imp_GetProcessId>

externdef __imp_SetLastError:PPROC
SetLastError equ <__imp_SetLastError>

externdef __imp_SetProcessId:PPROC
SetProcessId equ <__imp_SetProcessId>


; Ole32.lib
externdef __imp_CoInitializeEx:PPROC
CoInitializeEx equ <__imp_CoInitializeEx>

externdef __imp_CoUninitialize:PPROC
CoUninitialize equ <__imp_CoUninitialize>


; gdi32.lib
externdef __imp_CreateCompatibleDC:PPROC
CreateCompatibleDC equ <__imp_CreateCompatibleDC>

externdef __imp_DeleteDC:PPROC
DeleteDC equ <__imp_DeleteDC>

externdef __imp_DeleteObject:PPROC
DeleteObject equ <__imp_DeleteObject>

externdef __imp_GdiReleaseDC:PPROC
GdiReleaseDC equ <__imp_GdiReleaseDC>

externdef __imp_GetMonitorInfoA:PPROC
GetMonitorInfoA equ <__imp_GetMonitorInfoA>
externdef __imp_GetMonitorInfoW:PPROC
GetMonitorInfoW equ <__imp_GetMonitorInfoW>
  IFDEF __UNICODE__
    GetMonitorInfo equ <__imp_GetMonitorInfoW>
  ELSE
    GetMonitorInfo equ <__imp_GetMonitorInfoA>
  ENDIF

externdef __imp_GetObjectA:PPROC
GetObjectA equ <__imp_GetObjectA>
externdef __imp_GetObjectW:PPROC
GetObjectW equ <__imp_GetObjectW>
  IFDEF __UNICODE__
    GetObject equ <__imp_GetObjectW>
  ELSE
    GetObject equ <__imp_GetObjectA>
  ENDIF

externdef __imp_SelectObject:PPROC
SelectObject equ <__imp_SelectObject>

; gdiplus.lib

externdef __imp_GdipCreateBitmapFromFile:PPROC
GdipCreateBitmapFromFile equ <__imp_GdipCreateBitmapFromFile>

externdef __imp_GdipCreateBitmapFromScan0:PPROC
GdipCreateBitmapFromScan0 equ <__imp_GdipCreateBitmapFromScan0>

externdef __imp_GdipCreateHBITMAPFromBitmap:PPROC
GdipCreateHBITMAPFromBitmap equ <__imp_GdipCreateHBITMAPFromBitmap>

externdef __imp_GdipFillRectangleI:PPROC
GdipFillRectangleI equ <__imp_GdipFillRectangleI>

externdef __imp_GdipFree:PPROC
GdipFree equ <__imp_GdipFree>

externdef __imp_GdipCreateSolidFill:PPROC
GdipCreateSolidFill equ <__imp_GdipCreateSolidFill>

externdef __imp_GdipDisposeImage:PPROC
GdipDisposeImage equ <__imp_GdipDisposeImage>

externdef __imp_GdipGetImageGraphicsContext:PPROC
GdipGetImageGraphicsContext equ <__imp_GdipGetImageGraphicsContext>

externdef __imp_GdiplusShutdown:PPROC
GdiplusShutdown equ <__imp_GdiplusShutdown>

externdef __imp_GdiplusStartup:PPROC
GdiplusStartup equ <__imp_GdiplusStartup>

; Kernel32.lib
externdef __imp_CreateProcessA:PPROC
CreateProcessA equ <__imp_CreateProcessA>
externdef __imp_CreateProcessW:PPROC
CreateProcessW equ <__imp_CreateProcessW>
  IFDEF __UNICODE__
    CreateProcess equ <__imp_CreateProcessW>
  ELSE
    CreateProcess equ <__imp_CreateProcessA>
  ENDIF

externdef __imp_GetCommandLineA:PPROC
GetCommandLineA equ <__imp_GetCommandLineA>
externdef __imp_GetCommandLineW:PPROC
GetCommandLineW equ <__imp_GetCommandLineW>
  IFDEF __UNICODE__
    GetCommandLine equ <__imp_GetCommandLineW>
  ELSE
    GetCommandLine equ <__imp_GetCommandLineA>
  ENDIF

externdef __imp_GetModuleHandleA:PPROC
GetModuleHandleA equ <__imp_GetModuleHandleA>
externdef __imp_GetModuleHandleW:PPROC
GetModuleHandleW equ <__imp_GetModuleHandleW>
  IFDEF __UNICODE__
    GetModuleHandle equ <__imp_GetModuleHandleW>
  ELSE
    GetModuleHandle equ <__imp_GetModuleHandleA>
  ENDIF

externdef __imp_GetModuleFileNameA:PPROC
GetModuleFileNameA equ <__imp_GetModuleFileNameA>
externdef __imp_GetModuleFileNameW:PPROC
GetModuleFileNameW equ <__imp_GetModuleFileNameW>
  IFDEF __UNICODE__
    GetModuleFileName equ <__imp_GetModuleFileNameW>
  ELSE
    GetModuleFileName equ <__imp_GetModuleFileNameA>
  ENDIF

externdef __imp_GetTickCount:PPROC
GetTickCount equ <__imp_GetTickCount>

externdef __imp_ExitProcess:PPROC
ExitProcess equ <__imp_ExitProcess>

externdef __imp_GetFileAttributesA:PPROC
GetFileAttributesA equ <__imp_GetFileAttributesA>
externdef __imp_GetFileAttributesW:PPROC
GetFileAttributesW equ <__imp_GetFileAttributesW>
  IFDEF __UNICODE__
    GetFileAttributes equ <__imp_GetFileAttributesW>
  ELSE
    GetFileAttributes equ <__imp_GetFileAttributesA>
  ENDIF


externdef __imp_GetProcessHeap:PPROC
GetProcessHeap equ <__imp_GetProcessHeap>

externdef __imp_HeapAlloc:PPROC
HeapAlloc equ <__imp_HeapAlloc>

externdef __imp_HeapFree:PPROC
HeapFree equ <__imp_HeapFree>

externdef __imp_CloseHandle:PPROC
CloseHandle equ <__imp_CloseHandle>

externdef __imp_GlobalFree:PPROC
GlobalFree equ <__imp_GlobalFree>

externdef __imp_CreateFileA:PPROC
externdef __imp_CreateFileW:PPROC
CreateFileW equ <__imp_CreateFileW>
  IFDEF __UNICODE__
    CreateFile equ <__imp_CreateFileW>
  ELSE
    CreateFile equ <__imp_CreateFileA>
  ENDIF

externdef __imp_GetFileSizeEx:PPROC
GetFileSizeEx equ <__imp_GetFileSizeEx>

externdef __imp_GlobalAlloc:PPROC
GlobalAlloc equ <__imp_GlobalAlloc>

externdef __imp_GlobalLock:PPROC
GlobalLock equ <__imp_GlobalLock>

externdef __imp_ReadFile:PPROC
ReadFile equ <__imp_ReadFile>

externdef __imp_GlobalUnlock:PPROC
GlobalUnlock equ <__imp_GlobalUnlock>

externdef __imp_MultiByteToWideChar:PPROC
MultiByteToWideChar equ <__imp_MultiByteToWideChar>

; shlwapi.lib
externdef __imp_PathRemoveFileSpecA:PPROC
PathRemoveFileSpecA equ <__imp_PathRemoveFileSpecA>
externdef __imp_PathRemoveFileSpecW:PPROC
PathRemoveFileSpecW equ <__imp_PathRemoveFileSpecW>
  IFDEF __UNICODE__
    PathRemoveFileSpec equ <__imp_PathRemoveFileSpecW>
  ELSE
    PathRemoveFileSpec equ <__imp_PathRemoveFileSpecA>
  ENDIF

externdef __imp_PathCombineA:PPROC
PathCombineA equ <__imp_PathCombineA>
externdef __imp_PathCombineW:PPROC
PathCombineW equ <__imp_PathCombineW>
  IFDEF __UNICODE__
    PathCombine equ <__imp_PathCombineW>
  ELSE
    PathCombine equ <__imp_PathCombineA>
  ENDIF