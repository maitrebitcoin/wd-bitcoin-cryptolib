; multiplication de 2 entier 256 bits => 1 entier 512
; version  x86 32 bits 

.MODEL FLAT


.DATA
; index de la matrice 8x8 des entier 32 bits du produit de A*B a prendre pour additioner les partie et créer un résultat 256 bits
tabIndexAdd dword 	01h	, 10h	, 02h   , 0
T1          dword 	12h	, 11h	, 03h	, 20h	,04h  ,0
T2          dword	13h	, 21h	, 30h	, 22h	,05h	,14h	,06h    ,0
T3          dword	24h	, 32h	, 31h	, 23h	,16h	,15h	,07h	,08h	,40h,	0
T4          dword	25h	, 34h	, 26h	, 33h	,17h	,09h	,18h	,0Ah	,41h	,50h	,42h, 0
T5          dword	36h	, 35h	, 27h	, 1Ah	,19h	,0Bh	,0Ch	,28h	,52h	,51h	,43h	,44h	,60h,	0
T6          dword	37h	, 1Bh	, 0Dh	, 1Ch	,0Eh	,29h	,38h	,2Ah	,53h	,45h	,54h	,46h	,61h	,70h	,62h , 0
T7          dword	48h	, 2Ch	, 1Eh	, 1Dh	,0Fh	,3Ah	,39h	,2Bh	,64h	,56h	,55h	,47h	,72h	,71h	,63h , 0
T8          dword	49h	, 58h	, 4Ah	, 2Dh	,3Ch	,2Eh	,1Fh	,3Bh	,65h	,74h	,66h	,57h	,73h , 0
T9          dword	5Ah	, 59h	, 4Bh	, 68h	,4Ch	,3Eh	,3Dh	,2Fh	,76h	,75h	,67h , 0
T10         dword	5Bh	, 69h	, 78h	, 6Ah	,4Dh	,5Ch	,4Eh	,3Fh	,77h , 0
T11         dword	6Ch	, 7Ah	, 79h	, 6Bh	,5Eh	,5Dh	,4Fh	,0
T12         dword	6Dh	, 7Ch	, 6Eh	, 7Bh	,5Fh , 0
T13         dword	7Eh	, 7Dh	, 6Fh, 0
T14         dword	7Fh,   0


.CODE

;------------------------------------------
_x86_multiplication256x256_512_ASM PROC 
;void x86_multiplication256x256_512_ASM(byte* pNombreA, byte* pNombreB, OUT byte* pResultat512)
;prologue
  push        ebp  
  push        edi         
  push        esi    
  push        ebx
  mov         ebp,esp  
; sub         esp,200h    ; reserverve mem var locale

; recu param
    mov ecx,[ebp +20]  ; pA
	mov esi,[ebp +24]  ; pB

;	// construction du tableau des Ax * Bx
;	for (int i = 8; i > 0; i--)
; compteur de boucle : edi
 mov         edi,8
; on commence a la fin
    lea ebp,[ecx+1Ch] ; ebp a la fin de A
    lea esi,[esi+1Ch]
;   add        esp,200h                  ; esp => fin de tabMult
;		
for_i_0a7:
     mov         ecx,dword ptr [ebp]     ; ecx =  A[7]

     ; Bloc 7
     mov         eax,dword ptr [esi]     ; eax =  B[7]
     mul         ecx                     ; [edx,eax] = eax*ecx
     push        edx                     ; tabMult [0x1FC] =  edx
     push        eax                     ; tabMult [0x1F8] =  edx
     ; Bloc 6
     mov         eax,dword ptr [esi-04h] ; eax =  B[6]
     mul         ecx                     ; [edx,eax] = ebx*eax
     push        edx                     ; tabMult [0x1F4] = edx
     push        eax                     ; tabMult [0x1F0] = eax
     ; Bloc 5
     mov         eax,dword ptr [esi-08h] ; eax =  B[6]
     mul         ecx                     ; [edx,eax] = ebx*eax
     push        edx                     ; tabMult [0x1F4] = edx
     push        eax                     ; tabMult [0x1F0] = eax
     ; Bloc 4
     mov         eax,dword ptr [esi-0Ch] ; eax =  B[6]
     mul         ecx                     ; [edx,eax] = ebx*eax
     push        edx                     ; tabMult [0x1F4] = edx
     push        eax                     ; tabMult [0x1F0] = eax
     ; Bloc 3
     mov         eax,dword ptr [esi-10h] ; eax =  B[6]
     mul         ecx                     ; [edx,eax] = ebx*eax
     push        edx                     ; tabMult [0x1F4] = edx
     push        eax                     ; tabMult [0x1F0] = eax
     ; Bloc 2
     mov         eax,dword ptr [esi-14h] ; eax =  B[6]
     mul         ecx                     ; [edx,eax] = ebx*eax
     push        edx                     ; tabMult [0x1F4] = edx
     push        eax                     ; tabMult [0x1F0] = eax
     ; Bloc 1
     mov         eax,dword ptr [esi-18h] ; eax =  B[6]
     mul         ecx                     ; [edx,eax] = ebx*eax
     push        edx                     ; tabMult [0x1F4] = edx
     push        eax                     ; tabMult [0x1F0] = eax
     ; Bloc 0
     mov         eax,dword ptr [esi-1Ch] ; eax =  B[6]
     mul         ecx                     ; [edx,eax] = ebx*eax
     push        edx                     ; tabMult [0x1F4] = edx
     push        eax                     ; tabMult [0x1F0] = eax

     ; A6 -> A7;...
     lea         ebp,[ebp-4];            ; ebp = ebp -4

  dec  edi                               ; i--
 jne   for_i_0a7                         ; if (i != 0) goto for_i_0a7 
; fin for (i=0 a 7)

    ; restaure ebp
    lea ebp, [esp+200h]

;- partie 3 -- addition des multiplications ----
;
; esp = tabMult
; ebp = pResultat512
; esi = tabIndexAdd
 mov edx,[ebp +28]           ; pResultat512
 lea esi,[tabIndexAdd]       ; tabIndexAdd

 ; affectation resultat  : A0*B0 :
   mov eax,[esp]
   mov [edx],eax
   lea edx,[edx+4] ; edx = edx + 4

;	for (int k = 1; k < 16; k++)
 mov    edi,15  
 xor    ecx,ecx
  
for_k_1a16:
      mov   ebx,[esi] ; index
      add   esi,4
      mov   eax,[esp + ebx*4] ;  accumulateur = tabMult[nIndex]
      ; ajout
      adc  eax,ecx
      mov  ecx,0 ; // carry = 0
      adc  ecx,0 ; carry += c

      __while_1:
         ; bloc 0 (pair)
          mov   ebx,[esi]    ; index
          lea   esi,[esi+4]  ; esi = esi + 4
          test  ebx,ebx      ; if (index= 0)
          je    __break_while_1;
              add   eax,[esp + ebx*4] ; accumulateur += tabMult[nIndex]
              adc   ecx,0             ; carry += c
         ; bloc 1 , par de test car marque de fin que sur les positions paires
          mov   ebx,[esi]    ; index
          lea   esi,[esi+4]  ; esi = esi + 4
          add   eax,[esp + ebx*4] ; accumulateur += tabMult[nIndex]
          adc   ecx,0             ; carry += c
         ; bloc 2 (pair)
          mov   ebx,[esi]    ; index
          lea   esi,[esi+4]  ; esi = esi + 4
          test  ebx,ebx      ; if (index= 0)
          je    __break_while_1;
              add   eax,[esp + ebx*4] ; accumulateur += tabMult[nIndex]
              adc   ecx,0             ; carry += c
         ; bloc 3 , pas de test car marque de fin que sur les positions paires
          mov   ebx,[esi]    ; index
          lea   esi,[esi+4]  ; esi = esi + 4
          add   eax,[esp + ebx*4] ; accumulateur += tabMult[nIndex]
          adc   ecx,0             ; carry += c

          jmp __while_1;
      __break_while_1:
      ; affectation
      mov [edx],eax
      lea edx,[edx+4] ; edx = edx + 4


      dec  edi   ; i-
     jne   for_k_1a16
;for_k_1a16:

; epiloqgue

 mov         esp,ebp  
 pop         ebx
 pop         esi
 pop         edi
 pop         ebp  
 ret  
 
_x86_multiplication256x256_512_ASM ENDP

END