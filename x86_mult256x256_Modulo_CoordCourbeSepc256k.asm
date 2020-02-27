; multiplication de 2 entier 256 bits modulo 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; version 21 bits

.MODEL FLAT ; requis par masm

multiplication_256x256_512 PROTO C

.DATA
; 0x1000003d1
_2P256_MoinsP_Ordre qword 00000001000003d1h, 000000000000000h, 000000000000000h, 000000000000000h

.CODE

;----------- fct utilitaire ---------
; somme  de 2 entier 256 bits => 256 bits + Carry Flag
; edi,src = SRC
; ebx     = DST
_add_256_256 PROC

    ;+0
    mov         eax,[edi]
    add         eax,[esi]
    mov         [ebx],eax
    ;+4
    mov         eax,[edi+04h]
    adc         eax,[esi+04h]
    mov         [ebx+04h],eax
    ;+8
    mov         eax,[edi+08h]
    adc         eax,[esi+08h]
    mov         [ebx+08h],eax
    ;+12
    mov         eax,[edi+0Ch]
    adc         eax,[esi+0Ch]
    mov         [ebx+0Ch],eax
    ;+16
    mov         eax,[edi+10h]
    adc         eax,[esi+10h]
    mov         [ebx+10h],eax
    ;+20
    mov         eax,[edi+14h]
    adc         eax,[esi+14h]
    mov         [ebx+14h],eax
    ;+24
    mov         eax,[edi+18h]
    adc         eax,[esi+18h]
    mov         [ebx+18h],eax
    ;+28
    mov         eax,[edi+1Ch]
    adc         eax,[esi+1Ch]
    mov         [ebx+1Ch],eax
    ; fin
    ret
_add_256_256 ENDP

; ------------------------------------------------------------------------------------------------------
_mult256x256_Modulo_CoordCourbeSepc256k PROC
; Proto C :
; EXPORT void mult256x256_Modulo_CoordCourbeSepc256k (byte* pNombreA, byte* pNombreB, OUT byte* pResultat)
;prologue
  push        ebp  
  push        edi         
  push        esi    
  push        ebx
  mov         ebp,esp  
  sub         esp,120h    ; reserverve mem var locale : 4 entier 512 bits
; ebp-40h  ;  AB512
; ebp-80h  ;  resteModulo512
; ebp-C0h  ;  resteModulo2_512
; ebp-100h ;  testDepassement = Resultat + _2P256_MoinsP_Ordre

; recu param
    mov ecx,[ebp +20]  ; pA
	mov esi,[ebp +24]  ; pB
;	mov edi,[ebp +28]  ; pResultat256

    ; multiplication A*B => 512 bits
    lea         eax,[ebp-40h]   ; AB512 (dest)
    push        eax
    push        esi             ; B
    push        ecx             ; A
    call        multiplication_256x256_512;  AB512 = A * B

    ; multiplication des 256 bits de poids fort par 2^256 - P => 0x14551231950b75fc4402da1732fc9bebf
    lea         eax,[ebp-80h]             ;  resteModulo512 (dest)
    push        eax
    lea         eax,[ebp-20h]             ;  AxB_512.High
    push        eax
    lea         eax,[_2P256_MoinsP_Ordre] ;  2"256-P = 0x1000003d1
    push        eax
    call        multiplication_256x256_512; resteModulo512 =  AxB_512.High * 0x14551231950b75fc4402da1732fc9bebf


    ; calcul de :
    ; A*B.High*0x14551231950b75fc4402da1732fc9bebf + A*B.Low
    ; résultat : 256 bits + 32 de "carry"
	; UI64 C0 = AxB_512.low.v0;
    lea         edi,[ebp-40h]  ;  AxB_512.low 
    lea         esi,[ebp-80h]  ;  resteModulo512.Low
    mov         ebx,[ebp +28]  ;  Resultat256 (dest)
    call  _add_256_256         ;  Resultat256 = AxB_512.low + resteModulo512.Low
    ; ajout du carry au poids fort de resteModulo512.High, avant mutliplication
    mov eax,0 ; eax=  0, sans modifier c
    adc         [esi+20h],eax  ; resteModulo512.High
    adc         [esi+24h],eax
    adc         [esi+28h],eax
    adc         [esi+2Ch],eax
    adc         [esi+30h],eax
    adc         [esi+34h],eax
    adc         [esi+38h],eax
    adc         [esi+3Ch],eax

    ; multiplication du poids fort de <resteModulo512>
    lea         eax,[ebp-00C0h]           ;  resteModulo2_512 (dest) 
    push        eax
    lea         eax,[_2P256_MoinsP_Ordre] ;  2"256-P
    push        eax
    lea         esi,[esi+20h]             ; resteModulo512.High
    push        esi
    call        multiplication_256x256_512; resteModulo2_512 =  resteModulo512.High * 0x1000003d1

    ; 2eme addiction au résultat
    ; *pResultat256 = *pResultat256 + temp3.Low
    mov         edi,[ebp +28]  ;  edi = pResultat256 
    lea         esi,[ebp-00C0h]; resteModulo2_512.low
    mov         ebx,[ebp +28]  ;  ebx = pResultat256 (dest)
    call  _add_256_256         ; pResultat256 = pResultat256 + resteModulo2_512.low


    ; cas ou le résultat est plus grand que P = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
    ; on fait l'addition pour voir
    lea         ebx,[ebp-0100h]           ; testDepassement (dest)
    lea         esi,[_2P256_MoinsP_Ordre]  ; 0x1000003d1
    mov         edi,[ebp +28]              ; Resultat256 
    call  _add_256_256         ;  testDepassement = Resultat256 + 0x1000003d1
    jnc fin  ; si pas de dépassement,  terminé
        ; on dépasse le modulo
        mov   ebx,edi          ; testDepassement (dest)
        call  _add_256_256     ;  Resultat256 = Resultat256 + 0x1000003d1

fin:
; epiloqgue

 mov         esp,ebp  
 pop         ebx
 pop         esi
 pop         edi
 pop         ebp  
 ret         12   ;  3 * 4 octest mis sur la pile par l'appelant
 



_mult256x256_Modulo_CoordCourbeSepc256k endp
END