; soustracion de 2 entier 256 bits modulo 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; Proto C :
;  void soustractionModulo_sepc256k(byte* pNombreA, byte* pNombreB, OUT byte* pResultat)
; calling convention : RCX, RDX, R8, R9 pours les 4 premiers paramètres. soit :
; byte* pNombreA  : rcx
; byte* pNombreB  : rdx
; byte* pResultat : r8

.CODE
sub256x256_Modulo_CoordCourbeSepc256k PROC

; prologue

; soustraction 256 bits avec retenue
 mov         r9,qword ptr  [rcx]  
 sub         r9,qword ptr  [rdx]  
 mov         r10,qword ptr [rcx+8]  
 sbb         r10,qword ptr [rdx+8]  
 mov         r11,qword ptr [rcx+10h]  
 sbb         r11,qword ptr [rdx+10h]  
 mov         rcx,qword ptr [rcx+18h]  
 sbb         rcx,qword ptr [rdx+18h]  

;	// SI A-B est négatif
;	if (carry)
 jnc          _endif_debordement;
    ;		// on enlève ce qui dépasse mod P
    mov     rax,1000003D1h  
    sub     r9,rax  
    sbb     r10,0  
    sbb     r11,0  
    sbb         rcx,0  
	
_endif_debordement:
; copie résultat
 mov         qword ptr [r8]    ,r9  
 mov         qword ptr [r8+8]  ,r10  
 mov         qword ptr [r8+10h],r11  
 mov         qword ptr [r8+18h],rcx  

;Epilogue
 ret  

 sub256x256_Modulo_CoordCourbeSepc256k endp
 END