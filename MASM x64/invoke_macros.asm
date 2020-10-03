;***********************
; INVOKE MACROS for ML64 and JWasm (if you want to use it there), by rrr314159 2015/1/29
;***********************
IFNDEF __JWASM__                                    ;; actually I prefer nvk in JWasm as well
    invoke equ nvk
ENDIF
;***********************
;***********************
nvk MACRO thefun:REQ, args:VARARG  ; "invoke"
;;***********************
;; ALIGN stack to 16 bits, call nvk_noalign, then restore rsp

    push rbp            
    lea  rbp, [rsp][8]                              ;; save entering rsp first into rbp then onto stack
    sub rsp, 8                                      ;; make room for entering rsp that was saved in rbp
    and rsp, -10h                                   ;; align 16
    mov [rsp], rbp                                  ;; put entering rsp onto stack
    mov rbp, [rbp-8]                                ;; restore rbp

    nvk_noalign thefun, args
    
    pop rsp                                         ;; right back where we started from
ENDM

;***********************
nvk_noalign MACRO thefun:REQ, args:VARARG           ;; "invoke" without aligning
;;***********************
LOCAL txt, cnt, stackadjust, cnttopass
;; Prepare stack for arguments, load stack, call function, restore rsp
;; called from nvk; also can call directly if u know stack is aligned

;; Count the arguments, prepare reversed arg list

    cnt = 0
    IFNB <args>                                     ;; if args blank skip most of the work
        txt equ <> 
%       FOR arg, <args>
            txt CATSTR <arg> , <,>, txt
            cnt = cnt + 1
        ENDM
        txt SUBSTR txt, 1                           ;; force expression evaluation
        txt SUBSTR txt, 1, @SizeStr( %txt ) - 1

;; Adjust stack for args, rounded up to 16 bits (necessary for some funs)

        IF cnt GT 4
            stackadjust = cnt
        ELSE
            stackadjust = 4
        ENDIF
        stackadjust = ((stackadjust+1)/2)*2 ; round up to 16
        sub rsp, stackadjust * 8

;; Load stack, saving rdx in home space to be restored after each arg

        mov [rsp], rdx                              ;; cld also spill rcx,r8,9 if needed, or whatever
        cnttopass = cnt                             ;; pass by ref, so don't send cnt (gets clobbered)
        nvk_loadstack txt, cnttopass 
        
;; Load four regs from prepared args loaded on stack

        mov rcx, [rsp]
        mov rdx, [rsp+8]
        mov r8, [rsp+10h]
        mov r9, [rsp+18h]

;; Adjust by 20h, no other work needed, if arglist was blank

    ELSE
        sub rsp, 20h
    ENDIF

;; Call the function (finally), afterwards restore stack

    call thefun             
    IF cnt GT 0
        add rsp, stackadjust * 8
    ELSE
        add rsp, 20h
    ENDIF
ENDM

;***********************
nvk_loadstack MACRO args, posonstack
;;***********************
local leacmd
;; Load args on stack in reverse, restore rdx after each (it may in the arg list)

%   FOR arg, <args>
        posonstack = posonstack - 1
        mov rdx, [rsp]                                  ;; rdx gets orig value each time

;; Check for "aDdR", if present prepare lea instruction and execute it

        leacmd equ <@afteraddr(arg)>                    ;; if addr, returns after-addr text
        IFNB leacmd
            leacmd CATSTR <lea rdx, >, leacmd
            &leacmd                                     ;; execute lea instruction
            mov [rsp + posonstack*8], rdx
        ELSE

;; Convert types as necessary; if real/integer not 8 bytes, convert to real8/qword

            IF TYPE(arg) EQ REAL4 OR TYPE(arg) EQ REAL10
                fld arg
                fstp REAL8 PTR [rsp + posonstack*8]
            ELSE
                IF TYPE(arg) EQ 1 OR TYPE(arg) EQ 2
                    movsx edx, arg
                ELSEIF TYPE(arg) EQ 4
                    mov edx, arg
                ELSE
                    mov rdx, arg
                ENDIF
                mov [rsp + posonstack*8], rdx
            ENDIF
        ENDIF
    ENDM
ENDM

;***********************
@afteraddr MACRO thetxt:=<>
;;***********************
LOCAL char, answer, iswhite, numchars

;; If argument starts with addr return rest of string, else blank

    answer equ <>
    numchars = 0
    FORC char, <&thetxt>
        IF numchars EQ 0
            iswhite INSTR 1,< 	>,<&char>       ;; trim leading spaces or tabs
            IFE iswhite
                answer CATSTR answer,<&char>
                numchars = 1
            ENDIF
        ELSEIF numchars LT 4
                answer CATSTR answer,<&char>
                numchars = numchars + 1
        ELSEIF numchars EQ 4
        
;; "answer" now holds first 4 chars after whitespace, is it "aDdR"?

            IFIDNI <addr>, answer
                answer equ <>                       ;; says addr; now get the latter part of arg
                numchars = 5                        ;; anything > 4 will do; no longer counting
            ELSE
                EXITM <>                            ;; not addr, return blank
            ENDIF
        ELSE                                        ;; numchars > 4 means get rest of string
            answer CATSTR answer,<&char>
        ENDIF
    ENDM

;; If, after trimming, arg was too short, it couldn't be addr

    IF numchars LT 5                            
        answer equ <>
    ENDIF        
EXITM answer
ENDM

;***********************

