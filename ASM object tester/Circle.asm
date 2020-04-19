IFNDEF _Circle_
_Circle_ equ 1

include Shape.asm  ; Inherited class info file
; --=====================================================================================--
; #CLASS:    Circle 
; #VERSION:  1.0
; --=====================================================================================--
; Built by NaN's Object Class Creator
; © Sept 19, 2001
;
; By NaN ( jaymeson@hotmail.com )
; http://nan32asm.cjb.net
;
; --=====================================================================================--
; #AUTHOR: NaN 
; #DATE:   Aug 5, 2001
;
; #DESCRIPTION:
;
;          Multi-Line Description, followed by double period to end.
;          (<b>HTML TAGS ALLOWED!</b>) ..
;
; --=====================================================================================--
; CLASS METHOD PROTOS
; --=====================================================================================--
   Circle_Init    PROTO  :DWORD

; --=====================================================================================--
; FUNCTION POINTER PROTOS
; --=====================================================================================--
   Circ_destructorPto    TYPEDEF  PROTO  :DWORD 
   Circ_setRadiusPto    TYPEDEF  PROTO  :DWORD, :DWORD

   Circ_getAreaPto  TYPEDEF PROTO :DWORD
   
; --=====================================================================================--
; CLASS STRUCTURE
; --=====================================================================================--
   CLASS Circle, Circ
      Shape     <>         ; Inherited Class
      CMETHOD setRadius
      Radius     dd    ?
   Circle ENDS

.data

   BEGIN_INIT 
      dd offset Circ_destructor_Funct
      dd offset Circ_setRadius_Funct
      dd NULL
   END_INIT

.code
; --=====================================================================================--
; #METHOD:      CONSTRUCTOR (NONE)
;
; #DESCRIPTION: MultiLine Description.  <b>HTML TAGS ALLOWED</b>.
;               End with double period..
;
; #PARAM:       ParamName  MultiLine Param.  <b>HTML TAGS ALLOWED</b>.
;                          First word is paramname, rest is description.
;                          End with double period..
;
; #RETURN:      MultiLine Description.  <b>HTML TAGS ALLOWED</b>.
;               End with double period..
; --=====================================================================================--
Circle_Init  PROC uses edi esi lpTHIS:DWORD
   SET_CLASS Circle INHERITS Shape
   SetObject edi, Circle
   
     OVERRIDE getArea, CirleAreaProc

     DPrint "Circle Created (Code in Circle.asm)"

   ReleaseObject edi
   ret
Circle_Init ENDP

; --=====================================================================================--
; #METHOD:      destructor (NONE)
;
; #DESCRIPTION: MultiLine Description.  <b>HTML TAGS ALLOWED</b>.
;               End with double period..
;
; #PARAM:       ParamName  MultiLine Param.  <b>HTML TAGS ALLOWED</b>.
;                          First word is paramname, rest is description.
;                          End with double period..
;
; #RETURN:      MultiLine Description.  <b>HTML TAGS ALLOWED</b>.
;               End with double period..
; --=====================================================================================--
Circ_destructor_Funct  PROC uses edi lpTHIS:DWORD 
   SetObject edi, Circle

     DPrint "Circle Destroyed (Code in Circle.asm)"
     
     SUPER destructor

   ReleaseObject edi
   ret
Circ_destructor_Funct  ENDP

; --=====================================================================================--
; #METHOD:      setRadius (ParamSize)
;
; #DESCRIPTION: MultiLine Description.  <b>HTML TAGS ALLOWED</b>.
;               End with double period..
;
; #PARAM:       ParamName  MultiLine Param.  <b>HTML TAGS ALLOWED</b>.
;                          First word is paramname, rest is description.
;                          End with double period..
;
; #RETURN:      MultiLine Description.  <b>HTML TAGS ALLOWED</b>.
;               End with double period..
; --=====================================================================================--
Circ_setRadius_Funct  PROC uses edi lpTHIS:DWORD, DATA:DWORD
   SetObject edi, Circle

   mov eax, DATA
   mov [edi].Radius, eax
   
     DPrint "Circle Radius Set (Code in Circle.asm)"

   ReleaseObject edi
   ret
Circ_setRadius_Funct  ENDP

; --=====================================================================================--
; #METHOD:      getArea (NONE) ~ Polymorphic... 
;
; #DESCRIPTION: MultiLine Description.  <b>HTML TAGS ALLOWED</b>.
;               End with double period..
;
; #PARAM:       ParamName  MultiLine Param.  <b>HTML TAGS ALLOWED</b>.
;                          First word is paramname, rest is description.
;                          End with double period..
;
; #RETURN:      MultiLine Description.  <b>HTML TAGS ALLOWED</b>.
;               End with double period..
; --=====================================================================================--
CirleAreaProc PROC uses edi lpTHIS:DWORD
  LOCAL TEMP
  SetObject edi, Circle
  
  ; This will show SUPER classing the getArea method, by calling the getArea method
  ; found in the inherited class 'Shape'.  Uncomment and compare how the program's
  ; behavior is changed.
  
  SUPER getArea
  
  
  mov eax, [edi].Radius
  mov TEMP, eax
  
  finit
  fild TEMP
  fimul TEMP
  fldpi
  fmul
  fistp TEMP
  
  mov eax, TEMP
  DPrint "Circle Area (integer Rounded) (Code in Circle.asm)"
  
  ReleaseObject edi 
  ret 
   
CirleAreaProc ENDP
ENDIF
