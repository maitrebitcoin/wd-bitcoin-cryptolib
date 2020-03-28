; multiplication de 1 entier 256 bits par un entire 64 bits modulo 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; Proto C :
; EXPORT void mult256x64_Modulo_CoordCourbeSepc256k(byte* pNombreA, UINT64 nombreB, OUT byte* pResultat)
; calling convention : RCX, RDX, R8, R9 pours les 4 premiers param�tres. soit :
; byte* pNombreA  : rcx
; UIN64 nombreB   : rdx
; byte* pResultat : r8

; defines des param�tres
param1 equ rcx
param2 equ rdx
param3 equ r8 ; rdx en linux

.CODE
mult256x64_Modulo_CoordCourbeSepc256k PROC

; prologue
 push        rax
 push        rbx
 push        rcx
 push        rbp  
 push        rsi  
 push        r12  
 push        r13  
 push        r14  
 push        r15  

; r�cup�ration  des variables en regitres:
IFDEF LINUX
 mov         rcx, param1 ; mov   rcx,param1 ; car le param1=rdi en linux est ecras� par param2. NB ; rcx volatile en linux+windows
 mov         r8,  param3 ; pour linux
 mov         rdx ,param2 ; car rdx est le pamra�tre implicite de mult
ENDIF
 mov         r10,qword ptr [rcx    ]  ; r10 = A0
 mov         rsi,qword ptr [rcx+8  ]  ; rsi = A1
 mov         rbp,qword ptr [rcx+10h]  ; rbp = A2
 mov         r9, qword ptr [rcx+18h]  ; r14 = A3
 
;	//-------------------------------------------
;	// calcul de A * B0 :
;	//          [ A3 ] [ A2 ] [ A1 ] [ A0 ]
;	// *                             [ B0 ] 
;	// ------------------------------------------
;	//						  [ C1 ] [ C0 ]
;	//				   [ C2 ] [ L_ ]		
;	//          [ C3 ] [ L _]
;	//   [ C4 ] [ L _]
;	//-------------------------------------------
;	// = [ C4 ] [ C3 ] [ C2 ] [ C1 ] [ C0 ]
;
;  A0     A1    A2    A3
;  r10    rsi   rbp   r9
;  B0
;  rdx
;  C0     C1    C2    C3   C4
;  r11    r12   r13   r14  r15

IFDEF MULX_SUPPORTED
; code si l'instruction mulx est disponible sur le processeur : Intel ADX (Multi-Precision Add-Carry Instruction Extensions)
  mulx        r13,rax,rsi          ; (r13,rax) = rsi * rdx   (C2,L_)	= A1*B0 
  mulx        r12,r11,r10          ; (r12,r11) = r10 * rdx   (C1,C0)	= A0*B0
  add         r12,rax              ;                         (c ,C1) = C1 + L_ + c
  mulx        r14,rax,rbp          ; (r12,rax) = rbp * rdx   (C3,L_) = A2*B0
  adc         r13,rax              ;                         (c ,C2) = C2 + L_ + c
  mulx        r15,rax,r9           ; (r15,rax) = r14 * rdx   (C4,L_) = A3*B0
ELSE ;MULX_SUPPORTED
  ; emule < mulx        r13,rax,rsi >
  mov         rax, rdx             ; rdx est le 4em param�te implicite de mulx. mais dans mul c'est rax
  push        rax                  ; car rax/rdx modif� par MUL
  mul         rsi                  ; (rdx,rax) = rsi*rax
  mov         r13,rdx              ; r13 =rdx , ie  (r13,rax) = rsi * rdx   (C2,L_)	= A1*B0 
  mov         rbx,rax              ; copie rax qui va petre modif�
  pop         rax
  ; emule < mulx        r12,r11,r10 >
  push        rax                  ; car modif� par MUL
  mul         r10                  ; (rdx,rax) = r10*rdx
  mov         r12,rdx              
  mov         r11,rax              
  add         r12,rbx              ;                         (c ,C1) = C1 + L_ + c
  mov         rbx,0
  adc         rbx,0                ; rbx = carry
  pop         rax
  ; emule <mulx        r14,rax,rbp>
  push        rax                  ; car modif� par MUL
  mul         rbp                  ; (rdx,rax) = rbp*rdx
  mov         r14,rdx              
  add         r13,rax              ;                         (  ,C2) = C2 + L_ 
  adc         r13,rbx              ;                         (c ,C2) = C2 + + c
  pop         rax
  ; emule <mulx        r15,rax,r9>
  pushf
  mul         r9                  ; (rdx,rax) = r9*rdx
  popf
  mov         r15,rdx              
ENDIF ;!MULX_SUPPORTED
  adc         r14,rax              ;                         (c ,C3) = C3 + L_ + c
  adc         r15,0                ;                          C4 = C4 + c
; Multiplication de partie d�passe ( C4 ) par 2^256 modulo P :  0x1000003d1
; et ajout au r�sultat
 xor         rsi,rsi                 ; RAZ c et of + rsi = 0
 mov         rax,1000003D1h   ; pour mulx c'est le paramt�re 4
 mul         r15;                    ; (rd, rax) = 15 * rdx 
 add         r11,rax                 ; (c ,C0)  = C0 + L_
 adc         r12,rdx                 ; (c ,C1)  = C1 + H  + c
 adc         r13,rsi                 ; (c ,C2)  = C2 + c 
 adc         r14,rsi                 ; (c ,C3)  = C3 + c
 
; si on d�passe P = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; on doit soustraire P, �quivalent a ajouter -P (ie P compl�ment� a 2) = _2pow256_mod
; si(      C3 == 0xffffffffffffffff
;		&& C2 == 0xffffffffffffffff
;		&& C1 == 0xffffffffffffffff
;		&& C0 >= 0xfffffffefffffc2f )
 cmp         r14,0FFFFFFFFFFFFFFFFh  
 jne         neDepassePas;  
  cmp         r13,r14  
  jne         neDepassePas
   cmp         r12,r14
   jne         neDepassePas; 
    mov         rax,0FFFFFFFEFFFFFC2Fh  
    cmp         r11,rax  
     jb          neDepassePas; 
; code si on d�passe => ajout de 0x1000003d1
         add         r11,rdx    ; C0 += 0x1000003d1
         adc         r12,rsi    ; C1 += c
         adc         r13,rsi    ; C2 += c
         adc         r14,rsi    ; C3 += c
         
neDepassePas:
; affectation du r�sultat :
 mov         qword ptr [r8    ],r11 ;  C0  = r11  
 mov         qword ptr [r8+8  ],r12 ;  C1  = r12
 mov         qword ptr [r8+10h],r13 ;  C2  = r13
 mov         qword ptr [r8+18h],r14 ;  C3  = r14

;Epilogue
 pop         r15  
 pop         r14  
 pop         r13  
 pop         r12  
 pop         rsi  
 pop         rbp  
 pop         rcx
 pop         rbx
 pop         rax
 ret  
 
 mult256x64_Modulo_CoordCourbeSepc256k endp
 END