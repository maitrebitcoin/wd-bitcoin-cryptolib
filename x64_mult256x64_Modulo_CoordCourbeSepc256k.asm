; multiplication de 1 entier 256 bits par un entire 64 bits modulo 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; Proto C :
; EXPORT void multiplicationModulo_256x64_sepc256k (byte* pNombreA, UINT64 nombreB, OUT byte* pResultat)
; calling convention : RCX, RDX, R8, R9 pours les 4 premiers paramètres. soit :
; byte* pNombreA  : rcx
; UIN64 nombreB   : rdx
; byte* pResultat : r8

.CODE
mult256x64_Modulo_CoordCourbeSepc256k PROC

; prologue
 push        rax
 push        rbx
 push        rcx
 push        rbp  
 push        rsi  
 push        rdi  
 push        r12  
 push        r13  
 push        r14  
 push        r15  

; récupération  des variables en regitres:
 mov         rdi,rdx  
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

 mulx        r13,rax,rsi          ; (r13,rax) = rsi * rdx   (C2,L_)	= A1*B0 
 mulx        r12,r11,r10          ; (r12,r11) = r10 * rdx   (C1,C0)	= A0*B0
 add         r12,rax              ;                         (c ,C1) = C1 + L_ + c
 mulx        r14,rax,rbp          ; (r12,rax) = rbp * rdx   (C3,L_) = A2*B0
 adc         r13,rax              ;                         (c ,C2) = C2 + L_ + c
 mulx        r15,rax,r9           ; (r15,rax) = r14 * rdx   (C4,L_) = A3*B0
 adc         r14,rax              ;                         (c ,C3) = C3 + L_ + c
 adc         r15,0                ;                              C4 = C4 + c

; Multiplication de partie dépasse ( C4 ) par 2^256 modulo P :  0x1000003d1
; et ajout au résultat
 xor         rsi,rsi                 ; RAZ c et of + rsi = 0
 mov         rdx,1000003D1h          ; 
 mulx        rcx,rax,r15             ; (rcx,rax) = 15 * rdx   (H_,L_) = C4 * 0x1000003d1
 adcx        r11,rax                 ; (c ,C0)  = C0 + L_
 adcx        r12,rcx                 ; (c ,C1)  = C1 + H  + c
 adcx        r13,rsi                 ; (c ,C2)  = C2 + c 
 adcx        r14,rsi                 ; (c ,C3)  = C3 + c
 
; si on dépasse P = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; on doit soustraire P, équivalent a ajouter -P (ie P complémenté a 2) = _2pow256_mod
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
; code si on dépasse => ajout de 0x1000003d1
         add         r11,rdx    ; C0 += 0x1000003d1
         adc         r12,rsi    ; C1 += c
         adc         r13,rsi    ; C2 += c
         adc         r14,rsi    ; C3 += c
         
neDepassePas:
; affectation du résultat :
 mov         qword ptr [r8    ],r11 ;  C0  = r11  
 mov         qword ptr [r8+8  ],r12 ;  C1  = r12
 mov         qword ptr [r8+10h],r13 ;  C2  = r13
 mov         qword ptr [r8+18h],r14 ;  C3  = r14

;Epilogue
 pop         r15  
 pop         r14  
 pop         r13  
 pop         r12  
 pop         rdi  
 pop         rsi  
 pop         rbp  
 pop         rcx
 pop         rbx
 pop         rax
 ret  
 
 mult256x64_Modulo_CoordCourbeSepc256k endp
 END