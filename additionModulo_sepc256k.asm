; addition de 2 entier 256 bits modulo 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; Proto C :
; EXPORT void additionModulo_sepc256k(byte* pNombreA, byte* pNombreB, OUT byte* pResultat)
; Microsoft x64 calling convention : RCX, RDX, R8, R9 pours les 4 premiers paramètres. soit :
; byte* pNombreA  : rcx
; byte* pNombreB  : rdx
; byte* pResultat : r8

.CODE
additionModulo_sepc256k_ASM PROC

; prologue

; r9 = A0 + B0	
 mov         r9,qword ptr [rcx]  
 add         r9,qword ptr [rdx]  
;	carry = _addcarry_u64(carry, A1, B1, &C1);
 mov         r10,qword ptr [rcx+8]  
 adc         r10,qword ptr [rdx+8]  
;	carry = _subborrow_u64(carry, A2, B2, &C2);
 mov         r11,qword ptr [rcx+10h]  
 adc         r11,qword ptr [rdx+10h]  
;	carry = _subborrow_u64(carry, A3, B3, &C3);
 mov         rcx,qword ptr [rcx+18h]  
 adc         rcx,qword ptr [rdx+18h]  
; si débordement (IE A+B >= 2^256)
 jnc _endif_debordement;
     ; rajouter _2pow256_mod
     mov     rax,1000003D1h  
     add     r9,rax  
     adc     r10,0  
     adc     r11,0  
     adc     rcx,0  
_endif_debordement:


; copie résultat
 mov         qword ptr [r8]    ,r9  
 mov         qword ptr [r8+8]  ,r10  
 mov         qword ptr [r8+10h],r11  
 mov         qword ptr [r8+18h],rcx  

; ajout pour le cas du débordement
 ; rajouter _2pow256_mod
  mov     rax,1000003D1h  
  add     r9,rax  
  adc     r10,0  
  adc     r11,0  
  adc     rcx,0  
; si ca deborde, c'est que le nombre était plus grand que le modulo
; sinon c'est que le résultat etait ok
  jnc fin
     ; copie résultat si on était plus que le modulo
     mov         qword ptr [r8]    ,r9  
     mov         qword ptr [r8+8]  ,r10  
     mov         qword ptr [r8+10h],r11  
     mov         qword ptr [r8+18h],rcx  

fin:
;Epilogue
 ret  

 additionModulo_sepc256k_ASM endp
 END