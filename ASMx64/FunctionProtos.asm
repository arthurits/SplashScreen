

ExitProcess		proto
;GetModuleHandleW	proto
MessageBoxA		proto

externdef __imp_GetModuleHandleW:PPROC
GetModuleHandleW equ <__imp_GetModuleHandleW>