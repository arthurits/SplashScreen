IFNDEF _Shape_
_Shape_ equ 1

; --=====================================================================================--
; #CLASS:    Shape 
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
   Shape_Init    PROTO  :DWORD

; --=====================================================================================--
; FUNCTION POINTER PROTOS
; --=====================================================================================--
   Shap_destructorPto    TYPEDEF  PROTO  :DWORD 
   Shap_getAreaPto    TYPEDEF  PROTO  :DWORD
   Shap_setColorPto    TYPEDEF  PROTO  :DWORD, :DWORD

; --=====================================================================================--
; CLASS STRUCTURE
; --=====================================================================================--
   CLASS Shape, Shap
      CMETHOD destructor
      CMETHOD getArea
      CMETHOD setColor
      Color     dd    ?
   Shape ENDS

.data

   BEGIN_INIT 
      dd offset Shap_destructor_Funct
      dd offset Shap_getArea_Funct
      dd offset Shap_setColor_Funct
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
Shape_Init  PROC uses edi esi lpTHIS:DWORD
   SET_CLASS Shape
   SetObject edi, Shape

     DPrint "Shape Created (Code in Shape.asm)"

   ReleaseObject edi
   ret
Shape_Init ENDP

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
Shap_destructor_Funct  PROC uses edi lpTHIS:DWORD 
   SetObject edi, Shape

     DPrint "Shape Destroyed (Code in Shape.asm)"
     
   ReleaseObject edi
   ret
Shap_destructor_Funct  ENDP

; --=====================================================================================--
; #METHOD:      setColor (ParamSize)
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
Shap_setColor_Funct  PROC uses edi lpTHIS:DWORD, DATA:DWORD
   SetObject edi, Shape

   mov eax, DATA
   mov [edi].Color, eax
     
     DPrint "Shape Color Set!! (Code in Shape.asm)"
     
   ReleaseObject edi
   ret
Shap_setColor_Funct  ENDP

; --=====================================================================================--
; #METHOD:      getArea ()
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
Shap_getArea_Funct  PROC uses edi lpTHIS:DWORD
   SetObject edi, Shape

     DPrint " "
     DPrint "   SuperClassing!!!!! This allows code re-use if you use this method!!"
     DPrint "   Shape's getArea Method! (Code in Shape.asm)"
     
     mov eax, [edi].Color
     DPrint "   Called from Shape.getArea, (Code in Shape.asm)"
     DPrintValH eax, "   This objects color val is"
     DPrint " "
     
    

   ReleaseObject edi
   ret
Shap_getArea_Funct  ENDP

ENDIF
