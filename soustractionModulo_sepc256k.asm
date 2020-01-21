; soustracion de 2 entier 256 bits modulo 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; Proto C :
; EXPORT void soustractionModulo_sepc256k(byte* pNombreA, byte* pNombreB, OUT byte* pResultat)
; Microsoft x64 calling convention : RCX, RDX, R8, R9 pours les 4 premiers paramètres. soit :
; byte* pNombreA  : rcx
; byte* pNombreB  : rdx
; byte* pResultat : r8

.CODE
soustractionModulo_sepc256k_ASM PROC

; prologue

;	carry = _subborrow_u64(carry, A0, B0, &C0);
 mov         r9,qword ptr [rcx]  
 sub         r9,qword ptr [rdx]  
;	carry = _subborrow_u64(carry, A1, B1, &C1);
 mov         r10,qword ptr [rcx+8]  
 sbb         r10,qword ptr [rdx+8]  
;	carry = _subborrow_u64(carry, A2, B2, &C2);
 mov         r11,qword ptr [rcx+10h]  
 sbb         r11,qword ptr [rdx+10h]  
;	carry = _subborrow_u64(carry, A3, B3, &C3);
 mov         rcx,qword ptr [rcx+18h]  
 sbb         rcx,qword ptr [rdx+18h]  
 setb        al  
;	// SI A-B est négatif
;	if (carry)
 test        al,al  
 je          _endif_debordement;
    ;		// on enlève ce qui dépasse mod P
    ;		carry = 0;
    ;		carry = _subborrow_u64(carry, C0, _2pow256_mod, &C0);
    mov     rax,1000003D1h  
    sub     r9,rax  
    ;		carry = _subborrow_u64(carry, C1, 0, &C1);
    sbb     r10,0  
	; carry = _subborrow_u64(carry, C2, 0, &C2);
    sbb     r11,0  
	;	    _subborrow_u64(carry, C3, 0, &C3);
    sbb         rcx,0  
	
_endif_debordement:
; copie résultat
 mov         qword ptr [r8]    ,r9  
 mov         qword ptr [r8+8]  ,r10  
 mov         qword ptr [r8+10h],r11  
 mov         qword ptr [r8+18h],rcx  

;Epilogue
 ret  

 soustractionModulo_sepc256k_ASM endp
 END