; user32.lib
externdef __imp_GetDC:PPROC
GetDC equ <__imp_GetDC>

externdef __imp_CreateWindowExA:PPROC
CreateWindowExA equ <__imp_CreateWindowExA>
externdef __imp_CreateWindowExW:PPROC
CreateWindowExW equ <__imp_CreateWindowExW>
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

externdef __imp_MessageBoxA:PPROC
MessageBoxA equ <__imp_MessageBoxA>
externdef __imp_MessageBoxW:PPROC
MessageBoxW equ <__imp_MessageBoxW>
  IFDEF __UNICODE__
    MessageBox equ <__imp_MessageBoxW>
  ELSE
    MessageBox equ <__imp_MessageBoxA>
  ENDIF

externdef __imp_RegisterClassExA:PPROC
RegisterClassExA equ <__imp_RegisterClassExA>
externdef __imp_RegisterClassExW:PPROC
RegisterClassExW equ <__imp_RegisterClassExW>
  IFDEF __UNICODE__
    RegisterClassEx equ <__imp_RegisterClassExW>
  ELSE
    RegisterClassEx equ <__imp_RegisterClassExA>
  ENDIF

externdef __imp_SetWindowPos:PPROC
SetWindowPos equ <__imp_SetWindowPos>

externdef __imp_UnregisterClassA:PPROC
UnregisterClassA equ <__imp_UnregisterClassA>
externdef __imp_UnregisterClassW:PPROC
UnregisterClassW equ <__imp_UnregisterClassW>
  IFDEF __UNICODE__
    UnregisterClass equ <__imp_UnregisterClassW>
  ELSE
    UnregisterClass equ <__imp_UnregisterClassA>
  ENDIF

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

externdef __imp_SetLastError:PPROC
SetLastError equ <__imp_SetLastError>


; Ole32.lib
externdef __imp_CoInitializeEx:PPROC
CoInitializeEx equ <__imp_CoInitializeEx>

externdef __imp_CoUninitialize:PPROC
CoUninitialize equ <__imp_CoUninitialize>


; gdi32.lib
externdef __imp_DeleteObject:PPROC
DeleteObject equ <__imp_DeleteObject>

externdef __imp_GdiReleaseDC:PPROC
GdiReleaseDC equ <__imp_GdiReleaseDC>


; Kernel32.lib
externdef __imp_GetModuleHandleW:PPROC
GetModuleHandleW equ <__imp_GetModuleHandleW>

externdef __imp_ExitProcess:PPROC
ExitProcess equ <__imp_ExitProcess>

externdef __imp_GetFileAttributesW:PPROC
GetFileAttributesW equ <__imp_GetFileAttributesW>

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
