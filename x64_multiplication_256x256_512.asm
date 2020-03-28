; multiplication de 2 entier 256 bits => 1 entier 512



; Proto C :
; EXPORT void multiplication_256x256_512_ASM (byte* pNombreA_256, byte* pNombreB_256, OUT byte* pResultat_512)
; Microsoft x64 calling convention : RCX, RDX, R8, R9 pours les 4 premiers parametres. soit :
; byte* pNombreA_256  : rcx ( linux rdi )
; byte* pNombreB_256  : rdx ( linux rsi )
; byte* pResultat_512 : r8  ( linux rdx )

; defines
; en linux il sont remplacé par  RDI, RSI, RDX
param1 equ rcx
param2 equ rdx
param3 equ r8


.DATA
; index de la matrice 8x8 des entier 32 bits du produit de A*B a prendre pour additioner les partie et créer un résultat 256 bits
tabIndexAdd qword 	01h,  08h, 02h, 0
T1          qword 	0Ah,  09h, 03h,	10h, 04h , 0	
T2          qword	0Bh,  11h, 18h, 12h, 05h, 0Ch,	06h, 0
T3          qword	14h,  1Ah, 19h,	13h, 0Eh, 0Dh,  07h, 0
T4          qword	15h,  1Ch, 16h,	1Bh, 0Fh, 0		
T5          qword   1Eh,  1Dh, 17h, 0			
T6          qword   1Fh, 0		

.CODE

multiplication_256x256_512 PROC

; prologue
 push        rbx
 push        rbp  
 push        rsi  
 push        rdi
 push        r12  
 push        r13  
 ; sub         esp,100h    ; reserverve mem var locale : non fait car on remplis la pile avec 16 push 64 bits
 
 ; sauve rsp car il va bouger durant le calcule des multiplications 2 a 2
 mov          rbp, rsp

; récupération des variables A0..A3 en regitres:
IFDEF LINUX
 mov         r8,param3 ; car le param1=rdx en linux est ecrasé par "mul"
ENDIF
 ; rsi = A0..A3
 lea         rsi,[param1+18h] ; rsi = A3
 mov         r9 ,qword ptr [param2    ]  ; r9  = B0
 mov         r10,qword ptr [param2+8  ]  ; r10 = B1
 mov         r11,qword ptr [param2+10h]  ; r11 = B2
 mov         r12,qword ptr [param2+18h]  ; r12 = B3

;-------------------------------------------------------------------
;- partie 1 -- multiplications 2 a 2 de toutes les parties 64 bits -

; compteur de boucle : rdi
 mov         rdi,4
; on commence a la fin
for_i_0a4:
     mov         r13,qword ptr [rsi]     ; r13 = A3, ..., A0
     ; Bloc 3
     mov         rax,r13    ; rax = A3, ..., A0
     mul         r12                     ; [rdx,rax] = rax*r12 : A3*B3
     push        rdx                     ; 
     push        rax                     ; 
     ; Bloc 2
     mov         rax,r13                 ; rax = A0
     mul         r11                     ; [rdx,rax] = rax*r11 : A3*B2 
     push        rdx                     ;
     push        rax                     ; 
     ; Bloc 1
     mov         rax,r13                 ; rax = A0
     mul         r10                     ; [rdx,rax] = rax*r10  : A3*B1
     push        rdx                     ;                  ; 
     push        rax                     ; 
     ; Bloc 0
     mov         rax,r13                 ; rax = A0
     mul         r9                      ; [rdx,rax] = rax*r9  : A3*B1
     push        rdx                     ; 
     push        rax                     ; 
     ; A3->A2,
     lea rsi,[rsi-8] ; rsi -= 8
     ; fin de boucle
     dec  rdi                            ; i--
     jne   for_i_0a4                     ; if (i != 0) goto for_i_0a7 
; fin for (i=0 a 4)
 


;-------------------------------------------------------------------
;- partie 2 -- addition des multiplications                        -

 mov rdx,r8                 ;  rdx = pResultat512 (param 3)
 lea rsi,[tabIndexAdd]       ; rsi = tabIndexAdd

 ; affectation resultat  : A0*B0 :
   mov rax,[rsp]
   mov [rdx],rax
   lea rdx,[rdx+8] ; rdx = rdx + 8

;	for (int k = 1; k <=7; k++) // parcourt des lignes T1 a T6
 mov    rdi,7  
 xor    rcx,rcx ; rcx = 0
  
for_k_1a7:
      mov   rbx,[rsi] ; index
      add   rsi,8
      mov   rax,[rsp + rbx*8] ;  accumulateur = tabMult[nIndex]
      ; ajout retenue de l'étage précédent
      adc  rax,rcx
      mov  rcx,0 ; // carry = 0
      adc  rcx,0 ; carry += c

      __while_1:
         ; bloc 0 (pair)
          mov   rbx,[rsi]    ; index
          lea   rsi,[rsi+8]  ; rsi += 8 => suivant
          test  rbx,rbx      ; if (index= 0)
          je    __break_while_1;
              add   rax,[rsp + rbx*8] ; accumulateur += tabMult[nIndex]
              adc   rcx,0             ; carry += c
         ; bloc 1 , par de test car marque de fin que sur les positions paires
          mov   rbx,[rsi]    ; index
          lea   rsi,[rsi+8]  ; rsi += 8 => suivant
          add   rax,[rsp + rbx*8] ; accumulateur += tabMult[nIndex]
          adc   rcx,0             ; carry += c


          jmp __while_1;
      __break_while_1:
      ; affectation au poids faible , puis au on passe au poids fort suivant
      mov [rdx],rax
      lea rdx,[rdx+8] ; rdx += 8


      dec  edi   ; i-
     jne   for_k_1a7
;for_k_1a7:

; restaure rsp
mov          rsp, rbp 
;Epilogue
 pop         r13
 pop         r12
 pop         rdi  
 pop         rsi  
 pop         rbp  
 pop         rbx
 ret  

 multiplication_256x256_512 endp


 END
 