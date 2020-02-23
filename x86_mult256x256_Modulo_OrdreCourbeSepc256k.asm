; multiplication de 2 entier 256 bits modulo xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
; version  x86 32 bits 

.MODEL FLAT ; requis par masm

multiplication_256x256_512 PROTO C

.DATA

.DATA
; 0x14551231950b75fc4402da1732fc9bebf
_2P256_MoinsP_Ordre qword 402da1732fc9bebfh, 4551231950b75fc4h, 000000000000001h, 000000000000000h

.CODE
 
;------------------------------------------
_mult256x256_Modulo_OrdreCourbeSepc256k PROC
;void x86_multiplication256x256_512_ASM(byte* pNombreA, byte* pNombreB, OUT byte* pResultat256)
;prologue
  push        ebp  
  push        edi         
  push        esi    
  push        ebx
  mov         ebp,esp  
  sub         esp,80h    ; reserverve mem var locale

; recu param
    mov ecx,[ebp +20]  ; pA
	mov esi,[ebp +24]  ; pB
;	mov edi,[ebp +28]  ; pResultat256

    ; multiplication A*B => 512 bits
    lea         eax,[ebp-40h]  ;  temp = &AxB_512 
    push        eax
    push        esi             ; B
    push        ecx             ; A
    call        multiplication_256x256_512; 

    ; multiplication des 256 bits de poids fort par 2^256 - P => 0x14551231950b75fc4402da1732fc9bebf
    lea         eax,[ebp-80h]  ;  temp2 = &AxB_512 
    push        eax
    lea         eax,[ebp-20h]  ;  &AxB_512.High
    push        eax
    lea         eax,[_2P256_MoinsP_Ordre]  ;  2"256-P
    push        eax
    call        multiplication_256x256_512; 

    ; calcul de :
    ; A*B.High*0x14551231950b75fc4402da1732fc9bebf + A*B.Low
    ; résultat : 256 bits + 32 de "carry"
	; UI64 C0 = AxB_512.low.v0;
    lea         edi,[ebp-40h]  ;  temp   = &AxB_512 
    lea         esi,[ebp-80h]  ;  temp2.Low
    mov         ebx,[ebp +28]  ;  ebx = pResultat256 

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

; epiloqgue

 mov         esp,ebp  
 pop         ebx
 pop         esi
 pop         edi
 pop         ebp  
 ret  
 
_mult256x256_Modulo_OrdreCourbeSepc256k ENDP

END