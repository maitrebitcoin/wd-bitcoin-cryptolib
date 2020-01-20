; multiplication de 2 entier 256 bits modulo 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; Proto C :
; EXPORT void multiplicationModulo_sepc256k (byte* pNombreA, byte* pNombreB, OUT byte* pResultat)
; Microsoft x64 calling convention : RCX, RDX, R8, R9 pours les 4 premiers paramètres. soit :
; byte* pNombreA  : rcx
; byte* pNombreB  : rdx
; byte* pResultat : r8

.CODE
multiplicationModulo_sepc256k_ASM PROC

; prologue
 mov         qword ptr [rsp+18h],r8    ; sauver pResultat dans la zone des var locales. [rsp+68h] apres les push
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
 mov         r14,qword ptr [rcx+18h]  ; r14 = A3
 
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
;  r10    rsi   rbp   r14
;  B0
;  rdx
;  C0     C1    C2    C3   C4
;  r13    r9    r11   r12  r15

 mov         rdx,qword ptr [rdi]  ; rdx = B0
 mulx        r11,rax,rsi          ; (r11,rax) = rsi * rdx   (C2,L_)	= A1*B0 
 mulx        r9, r13,r10          ; (r9, r13) = r10 * rdx   (C1,C0)	= A0*B0
 add         r9,rax               ;                         (c ,C1) = C1 + L_ + c
 mulx        r12,rax,rbp          ; (r12,rax) = rbp * rdx   (C3,L_) = A2*B0
 adc         r11,rax              ;                         (c ,C2) = C2 + L_ + c
 mulx        r15,rax,r14          ; (r15,rax) = r14 * rdx   (C4,L_) = A3*B0
 adc         r12,rax              ;                         (c ,C3) = C3 + L_ + c
 adc         r15,0                ;                              C4 = C4 + c

;//*B1
;	//-----------------------------------------------------
;	// calcul de (A * B0) + ( A * B1 ) :
;	//                 [ A3 ] [ A2 ] [ A1 ] [ A0 ]
;	// *                             [ B1 ]  
;	// -----------------------------------------------
;	//					   	  [ H  ] [ L  ]
;	//                 [ H  ] [ L  ]
;	//          [ H  ] [ L  ]
;   //   [ C5 ] [ L  ]
;	// +        [ C4 ] [ C3 ] [ C2 ] [ C1 ] [ C0 ]  ( A * B0 , étage précédent )
;	//---------------------------------------------------
;	// = [ C5 ] [ C4 ] [ C3 ] [ C2 ] [ C1 ] [ C0 ]

 xor         rdx,rdx                 ; RAZ c et of
 mov         rdx,qword ptr [rdi+8]   ; rdx = B1  
 mulx        rcx,rax,r10             ; (rcx,rax) = r10 * rdx   (H_,L_) = A0*B1
 adox        r9,rax                  ;                         (of,C1) = C1 + L_
 mov         qword ptr [rsp+58h],r9  ;                            [C1] = r9   
 adox        r11,rcx                 ;                         (of,C2) = C2 + H_ + of
 mulx        rcx,rax,rsi             ; (rcx,rax) = rsi * rdx   (H_,L_) = A1*B1                         
 adcx        r11,rax                 ;                         (c, C2) = C2 + L_ 
 adox        r12,rcx                 ;                         (of,C3) = C3 + H_ + of
 mulx        rcx,rax,rbp             ; (rcx,rax) = rbp * rdx   (H_,L_) = A2*B1
 adcx        r12,rax                 ;                         (c, C3) = C3 + L_ 
 mulx        rbx,rax,r14             ; (rbx,rax) = r14 * rdx   (C5,L_) = A3*B1
 adox        r15,rcx                 ;                         (of,C4) = C4 + H_ + of
 adcx        r15,rax                 ;                         (c, C4) = C4 + L_ 
 mov         rdx,0                   ; pas xor pour conserver c et of
 adox        rbx,rdx                 ; rdx=0                       C5 += of
 adcx        rbx,rdx                 ; rdx=0                       C5 += c
                                     
 ;//*B2
 xor         rdx,rdx                 ; RAZ c et of
 mov         rdx,qword ptr [rdi+10h] ; rdx = B2
 mulx        rcx,rax,r10             ; (rcx,rax) = r10 * rdx   (H_,L_) = A0*B2
 adox        r11,rax                 ;                         (of,C2) = C2 + L_
 mov         qword ptr [rsp+60h],r11 ;                            [C2] = r11
 adox        r12,rcx                 ;                         (of,C3) = C2 + H_ + of
 mulx        rcx,rax,rsi             ; (rcx,rax) = rsi * rdx   (H_,L_) = A1*B2     
 adcx        r12,rax                 ;                         (c, C3) = C3 + L_ 
 adox        r15,rcx                 ;                         (of,C4) = C4 + H_ + of
 mulx        rcx,rax,rbp             ; (rcx,rax) = rbp * rdx   (H_,L_) = A2*B2
 adcx        r15,rax                 ;                         (c, C4) = C4 + L_ 
 mulx        r11,rax,r14             ; (rbx,rax) = r14 * rdx   (C6,L_) = A3*B2
 adox        rbx,rcx                 ;                         (of,C5) = C5 + H_ + of
 adcx        rbx,rax                 ;                         (c, C5) = C5 + L_ 
 mov         rdx,0                   ; pas xor pour conserver c et of
 adox        r11,rdx                 ; rdx=0                        C6 += of
 adcx        r11,rdx                 ; rdx=0                        C6 += c
 
  ;//*B3
 xor         rdx,rdx                 ; RAZ c et of
 mov         rdx,qword ptr [rdi+18h] ; rdx = B3
 mulx        rcx,rax,r10             ; (rcx,rax) = r10 * rdx   (H_,L_) = A0*B3
 adox        r12,rax                 ;                         (of,C3) = C3 + L_
 adox        r15,rcx                 ;                         (of,C4) = C4 + H_ + of
 mulx        rcx,rax,rsi             ; (rcx,rax) = rsi * rdx   (H_,L_) = A1*B3
 adcx        r15,rax                 ;                         (c, C4) = C4 + L_ 
 adox        rbx,rcx                 ;                         (of,C5) = C5 + H_ + of
 mov         rdi,qword ptr [rsp+58h] ; ---????-- rdi = C1
 mulx        rcx,rax,rbp             ; (rcx,rax) = rbp * rdx   (H_,L_) = A2*B3
 adcx        rbx,rax                 ;                         (c, C5) = C5 + L_ 
 adox        r11,rcx                 ;                         (of,C6) = C6 + H  + of
 mulx        r10,rax,r14             ; (r10,rax) = r14 * rdx   (C7,L_) = A3*B3
 adcx        r11,rax                 ;                         (c, C6) = C6 + L_
 mov         rdx,0                   ; pas xor pour conserver c et of
 adox        r10,rdx                 ; rdx=0                        C7 += of
 adcx        r10,rdx                 ; rdx=0                        C7 += c

; Multiplication de partie dépasse ( C7 C6 C5 C4 ) par 2^256 modulo P :  0x1000003d1
; et ajout au résultat
 xor         rsi,rsi                 ; RAZ c et of + rsi = 0
 mov         rdx,1000003D1h          ; 
 mulx        rcx,rax,r15             ; (rcx,rax) = r15 * rdx   (H_,L_) = C4 * 0x1000003d1
 adox        r13,rax                 ;                         (of,C0) = C0 + L_
 adox        rdi,rcx                 ;                         (of,C1) = C1 + H_ + ch
 mulx        rcx,rax,rbx             ; (rcx,rax) = rbx * rdx   (H_,C5) = C5 * 0x1000003d1
 mov         rbx,qword ptr [rsp+60h] ; rbx = [C2] 
 adcx        rdi,rax                 ;                         (c, C1) = C1 + C5  
 adox        rbx,rcx                 ;                         (of,C2) = C2 + H_ + of
 mulx        rcx,rax,r11             ; (rcx,rax) = r11 * rdx   (H_,C5) = C6 * 0x1000003d1
 adcx        rbx,rax                 ;                         (c, C2) = C2 + C5  
 adox        r12,rcx                 ;                         (of,C3) = C3 + H_ + of
 mulx        r8,rax,r10              ; (r8,rax)  = r10 * rdx   (C4,L_) = C7* 0x1000003d1
 adcx        r12,rax                 ;                         (c, C3) = C3 + L_ + c
 adcx        r8,rsi                  ;                              C4 += c
 adox        r8,rsi                  ;                              C4 += of

; si C4 * 0
; on doit ajouter encore H x _2pow256_mod . toujours fait pour éviter des effets de side-channel
 xor         rsi,rsi    ; RAZ c et of
 mulx        rcx,rax,r8  ; (rcx,rax) = r8 * rdx   (H_,L_) = C4 * 0x1000003d1
 adcx        r13,rax     ; (c ,C0)  = C0 + L_
 adcx        rdi,rcx     ; (c ,C1)  = C1 + H  + c
 adcx        rbx,rsi     ; (c ,C2)  = C2 + c 
 adcx        r12,rsi     ; (c ,C3)  = C3 + c
 
; si on dépasse P = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; on doit soustraire P, équivalent a ajouter -P (ie P complémenté a 2) = _2pow256_mod
; si(      C3 == 0xffffffffffffffff
;		&& C2 == 0xffffffffffffffff
;		&& C1 == 0xffffffffffffffff
;		&& C0 >= 0xfffffffefffffc2f )
 cmp         r12,0FFFFFFFFFFFFFFFFh  
 jne         neDepassePas;  
  cmp         rbx,r12  
  jne         neDepassePas
   cmp         rdi,r12  
   jne         neDepassePas; 
    mov         rax,0FFFFFFFEFFFFFC2Fh  
    cmp         r13,rax  
     jb          neDepassePas; 
; code si on dépasse => ajout de 0x1000003d1
         add         r13,rdx    ; C0 += 0x1000003d1
         adc         rbx,rsi    ; C1 += c
         adc         rdi,rsi    ; C2 += c
         adc         r12,rsi    ; C3 += c
         
neDepassePas:
; affectation du résultat dans : r12 ( C3 = poids fort) , rbx, rdi, r13 (C0 = poids faible )
 mov         rax,qword ptr [rsp+68h] ;  rax = [pResultat]
 mov         qword ptr [rax    ],r13 ;  C0  = r13  
 mov         qword ptr [rax+8  ],rdi ;  C1  = rdi
 mov         qword ptr [rax+10h],rbx ;  C2  = rbx
 mov         qword ptr [rax+18h],r12 ;  C3  = r12

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

 multiplicationModulo_sepc256k_ASM endp
 END