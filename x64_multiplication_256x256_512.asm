; multiplication de 2 entier 256 bits => 1 entier 512


.CODE

; Proto C :
; EXPORT void multiplication_256x256_512_ASM (byte* pNombreA_256, byte* pNombreB_256, OUT byte* pResultat_512)
; Microsoft x64 calling convention : RCX, RDX, R8, R9 pours les 4 premiers parametres. soit :
; byte* pNombreA_256  : rcx
; byte* pNombreB_256  : rdx
; byte* pResultat_512 : r8
; --------------
; utilisation des registres 
;  A0    A1    A2    A3
;  rbx  rsi   rbp   r15
;  B0 = > B3
;  rdx
;  C0     C1    C2    C3    C4   C5   C6   c7
;  r8    r9    r10   r11   r12  r13  r14  rbx
multiplication_256x256_512 PROC

; prologue
 mov         qword ptr [rsp+18h],r8    ; sauver <pResultat> dans la zone réservée par l'appelant. [rsp+58h] apres les push
 push        rbx
 push        rbp  
 push        rsi  
 push        rdi
 push        r12  
 push        r13  
 push        r14  
 push        r15  
 
; récupération des variables A0..A3 en regitres:
 mov         rdi,rdx  
 mov         rbx,qword ptr [rcx    ]  ; rbx = A0
 mov         rsi,qword ptr [rcx+8  ]  ; rsi = A1
 mov         rbp,qword ptr [rcx+10h]  ; rbp = A2
 mov         r15,qword ptr [rcx+18h]  ; r15 = A3
 
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

 mov         rdx,qword ptr [rdi]  ; rdx = B0
 mulx        r10,rax,rsi          ; (r10,rax) = rsi * rdx   (C2,L_)	= A1*B0 
 mulx        r9, r8, rbx          ; (r9, r8)  = rbx * rdx   (C1,C0)	= A0*B0
 add         r9, rax              ;                         (c ,C1) = C1 + L_ + c
 mulx        r11,rax,rbp          ; (r11,rax) = rbp * rdx   (C3,L_) = A2*B0
 adc         r10,rax              ;                         (c ,C2) = C2 + L_ + c
 mulx        r12,rax,r15          ; (r12,rax) = r14 * rdx   (C4,L_) = A3*B0
 adc         r11,rax              ;                         (c ,C3) = C3 + L_ + c
 adc         r12,0                ;                          C4 = C4 + c

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
;	// +        [ C4 ] [ C3 ] [ C2 ] [ C1 ] [ C0 ]  ( A * B0 , �tage pr�c�dent )
;	//---------------------------------------------------
;	// = [ C5 ] [ C4 ] [ C3 ] [ C2 ] [ C1 ] [ C0 ]

 xor         rdx,rdx                 ; RAZ c et of
 mov         rdx,qword ptr [rdi+8]   ; rdx = B1  
 mulx        rcx,rax,rbx             ; (rcx,rax) = rbx * rdx   (H_,L_) = A0*B1
 adox        r9 ,rax                 ;                         (of,C1) = C1 + L_
 adox        r10,rcx                 ;                         (of,C2) = C2 + H_ + of
 mulx        rcx,rax,rsi             ; (rcx,rax) = rsi * rdx   (H_,L_) = A1*B1                         
 adcx        r10,rax                 ;                         (c, C2) = C2 + L_ 
 adox        r11,rcx                 ;                         (of,C3) = C3 + H_ + of
 mulx        rcx,rax,rbp             ; (rcx,rax) = rbp * rdx   (H_,L_) = A2*B1
 adcx        r11,rax                 ;                         (c, C3) = C3 + L_ 
 mulx        r13,rax,r15             ; (r13,rax) = r14 * rdx   (C5,L_) = A3*B1
 adox        r12,rcx                 ;                         (of,C4) = C4 + H_ + of
 adcx        r12,rax                 ;                         (c, C4) = C4 + L_ 
 mov         rdx,0                   ; pas xor pour conserver c et of
 adox        r13,rdx                 ; rdx=0                   C5 += of
 adcx        r13,rdx                 ; rdx=0                   C5 += c
                                     
 ; *B2
 xor         rdx,rdx                 ; RAZ c et of
 mov         rdx,qword ptr [rdi+10h] ; rdx = B2
 mulx        rcx,rax,rbx             ; (rcx,rax) = rbx * rdx   (H_,L_) = A0*B2
 adox        r10,rax                 ;                         (of,C2) = C2 + L_          
 adox        r11,rcx                 ;                         (of,C3) = C2 + H_ + of
 mulx        rcx,rax,rsi             ; (rcx,rax) = rsi * rdx   (H_,L_) = A1*B2     
 adcx        r11,rax                 ;                         (c, C3) = C3 + L_ 
 adox        r12,rcx                 ;                         (of,C4) = C4 + H_ + of
 mulx        rcx,rax,rbp             ; (rcx,rax) = rbp * rdx   (H_,L_) = A2*B2
 adcx        r12,rax                 ;                         (c, C4) = C4 + L_ 
 mulx        r14,rax,r15             ; (r15,rax) = r14 * rdx   (C6,L_) = A3*B2
 adox        r13,rcx                 ;                         (of,C5) = C5 + H_ + of
 adcx        r13,rax                 ;                         (c, C5) = C5 + L_ 
 mov         rdx,0                   ; pas xor pour conserver c et of
 adox        r14,rdx                 ; rdx=0                   C6 += of
 adcx        r14,rdx                 ; rdx=0                   C6 += c
 
 ; *B3
 xor         rdx,rdx                 ; RAZ c et of
 mov         rdx,qword ptr [rdi+18h] ; rdx = B3
 mulx        rcx,rax,rbx             ; (rcx,rax) = rbx * rdx   (H_,L_) = A0*B3
 adox        r11,rax                 ;                         (of,C3) = C3 + L_
 adox        r12,rcx                 ;                         (of,C4) = C4 + H_ + of
 mulx        rcx,rax,rsi             ; (rcx,rax) = rsi * rdx   (H_,L_) = A1*B3
 adcx        r12,rax                 ;                         (c, C4) = C4 + L_ 
 adox        r13,rcx                 ;                         (of,C5) = C5 + H_ + of
 mulx        rcx,rax,rbp             ; (rcx,rax) = rbp * rdx   (H_,L_) = A2*B3
 adcx        r13,rax                 ;                         (c, C5) = C5 + L_ 
 adox        r14,rcx                 ;                         (of,C6) = C6 + H  + of
 mulx        rbx,rax,r15             ; (rbx,rax) = r14 * rdx   (C7,L_) = A3*B3
 adcx        r14,rax                 ;                         (c, C6) = C6 + L_
 mov         rdx,0                   ; pas xor pour conserver c et of
 adox        rbx,rdx                 ; rdx=0                   C7 += of
 adcx        rbx,rdx                 ; rdx=0                   C7 += c


; affectation du resultat dans <pResultat_512>
 mov         rax,qword ptr [rsp+58h] ;  rax = [pResultat]
 mov         qword ptr [rax    ],r8  ;  C0  = r8  
 mov         qword ptr [rax+8  ],r9  ;  C1  = r9
 mov         qword ptr [rax+10h],r10 ;  C2  = r10
 mov         qword ptr [rax+18h],r11 ;  C3  = r11
 mov         qword ptr [rax+20h],r12 ;  C4  = r12
 mov         qword ptr [rax+28h],r13 ;  C5  = r13
 mov         qword ptr [rax+30h],r14 ;  C6  = r14
 mov         qword ptr [rax+38h],rbx ;  C7  = rbx

;Epilogue
 pop         r15  
 pop         r14  
 pop         r13 
 pop         r12
 pop         rdi  
 pop         rsi  
 pop         rbp  
 pop         rbx


 ret  

 multiplication_256x256_512 endp


 END