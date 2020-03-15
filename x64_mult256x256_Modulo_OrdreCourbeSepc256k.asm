; multiplication de 2 entier 256 bits modulo xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141
; Proto C :
; EXPORT void multiplicationModulo_sepc256k (byte* pNombreA, byte* pNombreB, OUT byte* pResultat)
; Microsoft x64 calling convention : RCX, RDX, R8, R9 pours les 4 premiers param�tres. soit :
; byte* pNombreA  : rcx
; byte* pNombreB  : rdx
; byte* pResultat : r8

; defines des paramètres
param1 equ rcx
param2 equ rdx
param3 equ r8
; déclaration de l'existence d'une fonction externe 
multiplication_256x256_512 PROTO C

.DATA
; 0x14551231950b75fc4402da1732fc9bebf
_2P256_MoinsP_Ordre qword 402da1732fc9bebfh, 4551231950b75fc4h, 000000000000001h, 000000000000000h
                         
.CODE
;===========================================================================================
; point d'entée =>
; Proto C :
; EXPORT void multiplicationModulo_Ordre_sepc256k_ASM (byte* pNombreA_256, byte* pNombreB_256, OUT byte* pResultat_256)
; Microsoft x64 calling convention : RCX, RDX, R8, R9 pours les 4 premiers param�tres. soit :
; byte* pNombreA_256  : rcx ( linux rdi )
; byte* pNombreB_256  : rdx ( linux rsi )
; byte* pResultat_512 : r8  ( linux rdx )
;===========================================================================================
 mult256x256_Modulo_OrdreCourbeSepc256k PROC

 ;prologue


     push        rbp  
     push        rsi  
     push        rdi  
     push        r14  
     push        r15  
     lea         rbp,[rsp-40h]  
     sub         rsp,140h  ; reserve pour var localed
     
     mov         rbx,param3 ; sauver l'adrese du résultat dans rbx

	; multiplication A*B => 512 bits
	; UI512 AxB_512;
	; multiplication_256x256_512_ASM(pNombreA, pNombreB, (PBYTE)&AxB_512);
    lea         param3,[rbp-50h]  ;  r8 = &AxB_512 
    call        multiplication_256x256_512    ; (rcx,rdx,r8)
    
 	; multiplication des 256 bits de poids fort par 2^256 - P => 0x14551231950b75fc4402da1732fc9bebf
    ;UI512 _resteModulo;
	; multiplication_256x256_512_ASM( (PBYTE)&AxB_512.high, (PBYTE)&_2P256_MoinsP_Ordre, (PBYTE)&_resteModulo);
    lea         param3,[rsp+30h] ;  [_resteModulo]  
    lea         param2,[_2P256_MoinsP_Ordre]  
    lea         param1,[rbp-30h]  ; AxB_512.high
    call        multiplication_256x256_512   ; (rcx,rdx,r8)
    	
    ; résultat : 256 bits + 64 de "carry"
	; UI64 C0 = AxB_512.low.v0;
    mov         rdi,qword ptr [rbp-50h] ; rdi =  &AxB_512 
    add         rdi,qword ptr [rsp+30h ]  ;  [_resteModulo]  
    mov         rsi,qword ptr [rbp-48h]  
    adc         rsi,qword ptr [rsp+38h]  
    mov         r14,qword ptr [rbp-40h]    
    adc         r14,qword ptr [rsp+40h]  
    mov         r15,qword ptr [rbp-38h]  
    adc         r15,qword ptr [rsp+48h]  
    adc         qword ptr [rsp+50h],0  
    adc         qword ptr [rsp+58h],0  
    adc         qword ptr [rsp+60h],0  
    adc         qword ptr [rsp+68h],0  
IFDEF LINUX
    mov r11, rsi ; se sont param1 et param2 en linux
    mov r12, rdi 
ENDIF
;	multiplication_256x256_512_ASM( (PBYTE)&_resteModulo.high, (PBYTE)&_2P256_MoinsP_Ordre, (PBYTE)&_resteModulo2);
     lea         param1,[rsp+50h]  
     lea         param2,[_2P256_MoinsP_Ordre]  
     lea         param3,[rsp+70h]               ; _resteModulo2
IFDEF LINUX
     push  r11  ; car r11/r12 ne sont pas préservés.
     push  r12
ENDIF
     call        multiplication_256x256_512 ; (rcx,rdx,r8)  
IFDEF LINUX
    pop r12
    pop r11
    mov rdi, r12 ; restauration 
    mov rsi, r11
ENDIF    
     add         rdi,qword ptr [rsp+70h] ; _resteModulo2.low
     adc         rsi,qword ptr [rsp+78h]  
     adc         r14,qword ptr [rsp+80h]  
     adc         r15,qword ptr [rsp+88h]  
     adc         qword ptr [rbp-70h],0   ; resteModulo2.high
     adc         qword ptr [rbp-68h],0  
     adc         qword ptr [rbp-60h],0  
     adc         qword ptr [rbp-58h],0  
IFDEF LINUX
    mov r11, rsi ; se sont param1 et param2 en linux
    mov r12, rdi 
ENDIF
;multiplication_256x256_512_ASM( (PBYTE)&_resteModulo2.high, (PBYTE)&_2P256_MoinsP_Ordre, (PBYTE)&_resteModulo3);
     lea         param1,[rbp-70h]  ; resteModulo2.high
     lea         param2,[_2P256_MoinsP_Ordre]  
     lea         param3,[rbp-10h]  ; _resteModulo3
IFDEF LINUX
     push  r11
     push  r12
ENDIF
     call        multiplication_256x256_512
IFDEF LINUX
    pop r12
    pop r11
    mov rdi, r12 ; restauration 
    mov rsi, r11
ENDIF

    add         rdi,qword ptr [rbp-10h]  ; _resteModulo3
    mov         rax,402DA1732FC9BEBFh  
    mov         rcx,rdi  
    adc         rsi,qword ptr [rbp-8]  
    mov         rdx,rsi  
    adc         r14,qword ptr [rbp]  
    mov         r8,r14  
    adc         r15,qword ptr [rbp+8]  
    mov         r9,r15  
    adc         rcx,rax  
    mov         rax,4551231950B75FC4h  
    adc         rdx,rax  
    adc         r8,1  
    adc         r9,0  
    setb        al  
    test        al,al  
 je          multiplicationModulo_ordre_sepc256k_else
; if (caryy)
		; Affecation du résultat avec la version qui depasse
         mov         qword ptr [rbx],    rcx  
         mov         qword ptr [rbx+8],  rdx  
         mov         qword ptr [rbx+10h],r8  
         mov         qword ptr [rbx+18h],r9  
         jmp         multiplicationModulo_ordre_sepc256k_end
;	else
multiplicationModulo_ordre_sepc256k_else:	
		; Affecation du résultat
         mov         qword ptr [rbx],    rdi  
         mov         qword ptr [rbx+8],  rsi  
         mov         qword ptr [rbx+10h],r14  
         mov         qword ptr [rbx+18h],r15  
multiplicationModulo_ordre_sepc256k_end:

; epilogue
 add         rsp,140h  
 pop         r15  
 pop         r14  
 pop         rdi  
 pop         rsi  
 pop         rbp  
 ret  

 mult256x256_Modulo_OrdreCourbeSepc256k ENDP


 END