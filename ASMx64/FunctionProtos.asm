

; user32.lib
externdef __imp_MessageBoxA:PPROC
MessageBoxA equ <__imp_MessageBoxA>

externdef __imp_MessageBoxW:PPROC
MessageBoxW equ <__imp_MessageBoxW>

  IFDEF __UNICODE__
    MessageBox equ <__imp_MessageBoxW>
  ELSEIF
    MessageBox equ <__imp_MessageBoxA>
  ENDIF

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

