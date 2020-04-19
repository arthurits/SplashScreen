;---------------------------------------------------------------------
;  Routines for debugging under assmembly language
;
; Written by E Murphy
;
;  Copyright © March 24, 2000 by the author
;  Complete re-write August 9, 2000
;  Added DLog series September 7, 2000
;
;  Contact author at ernie@surfree.com
;                 or 10206.2341@compuserve.com
;
;---------------------------------------------------------------------
;  USEAGE:
;             The DPrint macros will direct debug information to either
;             a message box (only good for a few messages) or to a console
;             output (even better: show you the program's dynamic action 
;             as it happens.
;             
;             Define one of the following BEFORE the include files area:
;
;               DEBUGC  EQU 1       ; console debug print
;
;               DEBUGW  EQU 1       ; windows debug print
;
;
;             DPrint Debug statements may be added as follows:
;
;
;               DPrint "Message here"       ; print a comment
;
;               DPrintValD eax, "EAX"       ; print a comment followed by 
;                                           ;  a register value (in decimal)
;
;               DPrintValH eax, "EAX"       ; print a comment followed by 
;                                           ;  a register value (in hex)
;
;               DPrintSZ OFFSET szString , "The string is"
;                                           ; print a zero terminated string
;                                           ;  note uses a pointer
;                                           ;  also note also prints a comment string
;
;             To use console output, use the Console build options of Quick Editor
;           This is completely compatable with a windows app, as you will get both
;           the application window, and a console.
;
;             If the console app is started from a dos box, the console output 
;           goes there. This output may then be piped to a file.
;
;           IE,
;               c:\somepath>MyApp.exe  >MyApp.txt
;
;             This command dumps the console output to the file MyApp.txt
;
;             When using the windows app option, message boxes will appear. This
;           is only desirable for a very few messages. NOT SUITABLE for  
;           monitoring the message loop for sure.
;         
;             Also note, these functions will work quite happily on displaying 
;           value in memory, so that this is quite legal:
;           
;               DPrintValH SomeVar, "SomeVar is" ; print a comment followed by 
;                                                ;  a memory variable value (in hex)
;           
;
;
; LOGGING TO FILES:
;           
;           The Dlog series of macros perform the same actions as the DPrint series,
;           but send their output to a text file.  
;           
;           Dlog differs in that the file must be opened and closed, and appropiate
;           macros for this are included
;           
;           
;           DLog Debug statements may be added as follows:
;
;
;             Define the following BEFORE the include files area:
;
;               DEBUGL  EQU 1       ; console debug print
;
;
;               DLogStart "MyApp.txt"     ; opens the file for information
;                                         ;  this exampl names the file 
;                                         ;  "MyApp.txt"
;                                         ;  MUST be performed before any 
;                                         ;  other DLog statement
;
;               DLogEnd                   ; Closes the file, place just before your 
;                                         ;  your app terminates. The file will
;                                         ;  be closed by the OS if your program
;                                         ;  crashes before normal termination.
;
;               DLog "Message here"       ; print a comment
;
;               DLogValD eax, "EAX"       ; print a comment followed by 
;                                         ;  a register value (in decimal)
;
;               DLogValH eax, "EAX"       ; print a comment followed by 
;                                         ;  a register value (in hex)
;
;               DLogSZ OFFSET szString , "The string is"
;                                         ; print a zero terminated string
;                                         ;  note uses a pointer
;                                         ;  also note also prints a comment string
;
;
;
;---------------------------------------------------------------------

DLogStart MACRO string:REQ
    IFDEF DEBUGL
        .data
        DMacros_szFileName      BYTE    string, 0
        DMacros_hFile           DWORD   ?
        DMacros_bc              DWORD   ?
        .code
        invoke CreateFile, ADDR DMacros_szFileName, GENERIC_WRITE, 
                           FILE_SHARE_READ or FILE_SHARE_WRITE, 
                           NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL 
        mov DMacros_hFile, eax
    ENDIF
ENDM

DLogEnd MACRO
    IFDEF DEBUGL
        invoke SetEndOfFile, DMacros_hFile
        invoke CloseHandle, DMacros_hFile
    ENDIF
ENDM

DLog MACRO string:req
    LOCAL DMacros_szMessage
    IFDEF DEBUGL
        ; do a console version Print Message
        .data
        DMacros_szMessage   BYTE    string, 13, 10, 0
        .code
        pushad 
        invoke lstrlen, ADDR DMacros_szMessage
        invoke WriteFile, DMacros_hFile, ADDR DMacros_szMessage, eax, ADDR DMacros_bc, NULL
        popad
    ENDIF
ENDM

DLogValH MACRO value:req, string:req
    LOCAL DMacros_szNumBuffer, DMacros_szMessage, DMacros_crlf
    IFDEF DEBUGL
        .data
        DMacros_szNumBuffer     BYTE 15 DUP(?)
        DMacros_crlf            BYTE 13,10,0
        DMacros_szMessage       BYTE string, ":  ",0
        .code
        pushad
        invoke dw2ah, value, ADDR DMacros_szNumBuffer  
        invoke lstrlen, ADDR DMacros_szMessage
        invoke WriteFile, DMacros_hFile, ADDR DMacros_szMessage, eax, ADDR DMacros_bc, NULL
        invoke lstrlen, ADDR DMacros_szNumBuffer
        invoke WriteFile, DMacros_hFile, ADDR DMacros_szNumBuffer, eax, ADDR DMacros_bc, NULL
        invoke lstrlen, ADDR DMacros_crlf
        invoke WriteFile, DMacros_hFile, ADDR DMacros_crlf, eax, ADDR DMacros_bc, NULL
        popad
    ENDIF
ENDM

DLogValD MACRO value:req, string:req
    LOCAL DMacros_szNumBuffer, DMacros_szMessage, DMacros_crlf
    IFDEF DEBUGL
        .data
        DMacros_szNumBuffer     BYTE 15 DUP(?)
        DMacros_crlf            BYTE 13,10,0
        DMacros_szMessage       BYTE string, ":  ",0
        .code
        pushad
        invoke dwtoa, value, ADDR DMacros_szNumBuffer  
        invoke lstrlen, ADDR DMacros_szMessage
        invoke WriteFile, DMacros_hFile, ADDR DMacros_szMessage, eax, ADDR DMacros_bc, NULL
        invoke lstrlen, ADDR DMacros_szNumBuffer
        invoke WriteFile, DMacros_hFile, ADDR DMacros_szNumBuffer, eax, ADDR DMacros_bc, NULL
        invoke lstrlen, ADDR DMacros_crlf
        invoke WriteFile, DMacros_hFile, ADDR DMacros_crlf, eax, ADDR DMacros_bc, NULL
        popad
    ENDIF
ENDM

DLogSZ  MACRO  pstring:req, string
    LOCAL DMacros_szMessage, DMacros_crlf, DMacros_spaces
    IFDEF DEBUGL
        ; do a console version Print Message
        .data
        DMacros_crlf            BYTE 13,10,0
        IFNB <string>
            DMacros_szMessage   BYTE  string, 0
            DMacros_spaces      BYTE  ":  ", 0
        ENDIF
        .code
        pushad 
        IFNB <string>
            invoke lstrlen, ADDR DMacros_szMessage
            invoke WriteFile, DMacros_hFile, ADDR DMacros_szMessage, eax, ADDR DMacros_bc, NULL
            invoke lstrlen, ADDR DMacros_spaces
            invoke WriteFile, DMacros_hFile, ADDR DMacros_spaces, eax, ADDR DMacros_bc, NULL
        ENDIF
        invoke lstrlen, pstring
        invoke WriteFile, DMacros_hFile, pstring, eax, ADDR DMacros_bc, NULL
        invoke lstrlen, ADDR DMacros_crlf
        invoke WriteFile, DMacros_hFile, ADDR DMacros_crlf, eax, ADDR DMacros_bc, NULL
        popad
    ENDIF
ENDM


DPrint MACRO string:req
    LOCAL szMessage
    IFDEF DEBUGW
        ; do a windows version Print Message
        IFNDEF szAppName
            .data
            szAppName   BYTE    "Debug Message", 0
        ENDIF
        .data
        szMessage   BYTE    string,0
        .code 
        pushad
        invoke MessageBox, NULL, ADDR szMessage, ADDR szAppName, MB_OK
        popad
    ENDIF
    IFDEF DEBUGC
        ; do a console version Print Message
        .data
        szMessage   BYTE    string, 13, 10, 0
        .code
        pushad 
        invoke StdOut, ADDR szMessage
        popad
    ENDIF
ENDM

DPrintValD MACRO value:req, string:req
    LOCAL szNumBuffer, szMessage, crlf
    IFDEF DEBUGW
        ; do a windows version Print Message
        .data
        szNumBuffer     BYTE 15 DUP(?)
        szMessage   BYTE string, ":  ",0
        .code 
        pushad
        mov eax, value
        invoke dwtoa, eax, ADDR szNumBuffer
        invoke MessageBox, NULL, ADDR szNumBuffer, ADDR szMessage, MB_OK
        popad
    ENDIF
    IFDEF DEBUGC
        ; do a console version Print Message
        .data
        szNumBuffer     BYTE 15 DUP(?)
        crlf            BYTE 13,10,0
        szMessage       BYTE string, ":  ",0
        .code
        pushad
        invoke dwtoa, value, ADDR szNumBuffer  
        invoke StdOut, ADDR szMessage
        invoke StdOut, ADDR szNumBuffer     
        invoke StdOut, ADDR crlf    
        popad
    ENDIF
ENDM


DPrintValH MACRO value:req, string:req
    LOCAL szNumBuffer, szMessage, crlf
    IFDEF DEBUGW
        ; do a windows version Print Message
        .data
        szNumBuffer     BYTE 15 DUP(?)
        szMessage   BYTE string, ":  ",0
        .code 
        pushad
        mov eax, value
        invoke dw2ah, eax, ADDR szNumBuffer
        invoke MessageBox, NULL, ADDR szNumBuffer, ADDR szMessage, MB_OK
        popad
    ENDIF
    IFDEF DEBUGC
        ; do a console version Print Message
        .data
        szNumBuffer     BYTE 15 DUP(?)
        crlf            BYTE 13,10,0
        szMessage       BYTE string, ":  ",0
        .code
        pushad
        invoke dw2ah, value, ADDR szNumBuffer  
        invoke StdOut, ADDR szMessage
        invoke StdOut, ADDR szNumBuffer     
        invoke StdOut, ADDR crlf    
        popad
    ENDIF
ENDM


DPrintSZ  MACRO  pstring:req, string
    LOCAL szMessage, crlf, spaces
    IFDEF DEBUGW
        ; do a windows version Print Message
        IFNDEF szAppName
            .data
            szAppName   BYTE    "Debug Message", 0
        ENDIF
        IFNB <string>
            .data
            szMessage   BYTE    string,0
        ENDIF
        .code 
        pushad
        IFNB  <string>
            invoke MessageBox, NULL, pstring, ADDR szMessage, MB_OK
        ELSE
            invoke MessageBox, NULL, pstring, ADDR szAppName, MB_OK
        ENDIF
        popad
    ENDIF
    IFDEF DEBUGC
        ; do a console version Print Message
        .data
        crlf            BYTE 13,10,0
        IFNB <string>
            szMessage   BYTE  string, 0
            spaces      BYTE  ":  ", 0
        ENDIF
        .code
        pushad 
        IFNB <string>
            invoke StdOut, ADDR szMessage
            invoke StdOut, ADDR spaces
        ENDIF
        invoke StdOut, pstring
        invoke StdOut, ADDR crlf    
        popad
    ENDIF
ENDM



