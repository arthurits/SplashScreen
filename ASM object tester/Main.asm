DEBUGC equ 1
.586
.model flat,stdcall
option casemap:none

include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\masm32.lib

include Dmacros.inc
include Objects.inc
include Circle.asm

.data

.data?

hCircle dd ?

.code
start:

  ; Recuse all inherited constructors.. and do all inits
  DPrint " "
  DPrint " >>> main.asm <<< [ mov hCircle, $NEW( Circle ) ]"
  mov hCircle, $NEW( Circle )

  DPrint " "
  DPrint " >>> main.asm <<< [ METHOD hCircle, Circle, setColor, 7 ]"
  METHOD hCircle, Circle, setColor, 7
  
  DPrint " "
  DPrint " >>> main.asm <<< [ METHOD hCircle, Circle, setRadius, 2 ]"
  METHOD hCircle, Circle, setRadius, 2  
  
  DPrint " "
  DPrint " ------------ TEST POLYMORPHIC METHOD hCircle.getArea ------------- "
  DPrint " "
  DPrint " >>> main.asm <<< [ DPrintValD $EAX( hCircle, Circle, getArea ) , 'Area of hCircle' ]"
  DPrintValD $EAX( hCircle, Circle, getArea ) , "Area of hCircle"
  DPrint " "

  DPrint " ------------ TEST POLYMORPHIC METHOD hCircle.getArea ------------- "
  DPrint " "
  DPrint " >>> main.asm <<< [   DPrintValD $EAX( hCircle, Shape, getArea ) , 'Area of hCircle' ]"
  DPrint " Typing calling this Ojbect Instance as a SHAPE type only! This is the true value"
  DPrint " of Polymorphism.  We dont need to know its a Circle object in order to get the"
  DPrint " proper area of this instance object, that is inherited from Shape."
  DPrint " "
  DPrintValD $EAX( hCircle, Shape, getArea ) , "Area of hCircle"
  DPrint " "
  
  
  DPrint " "
  DPrint " >>> main.asm <<< [ DESTROY hCircle ]"
  DESTROY hCircle
  DPrint " "
  DPrint " " 
  DPrint " NOTE: superclassing here, as each destructor call's the SUPER destructor"
  DPrint "       To properly clean up after each class.  To see SUPER classing in"
  DPrint "       in the Polymorphic getArea Function.  Uncomment the SUPER code in"
  DPrint "       CircleAreaProc, and re-compile"


     call ExitProcess
end start