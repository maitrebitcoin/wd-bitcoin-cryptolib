; soustracion de 2 entier 256 bits modulo 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; Proto C :
;  void soustractionModulo_sepc256k(byte* pNombreA, byte* pNombreB, OUT byte* pResultat)
; calling convention : RCX, RDX, R8, R9 pours les 4 premiers paramètres. soit :
; byte* pNombreA  : rcx
; byte* pNombreB  : rdx
; byte* pResultat : r8

; defines des paramètres
param1 equ rcx
param2 equ rdx
param3 equ r8

.CODE
sub256x256_Modulo_CoordCourbeSepc256k PROC

; prologue


; soustraction 256 bits avec retenue
 mov         r9,qword ptr  [param1]  
 sub         r9,qword ptr  [param2]  
 mov         r10,qword ptr [param1+8]  
 sbb         r10,qword ptr [param2+8]  
 mov         r11,qword ptr [param1+10h]  
 sbb         r11,qword ptr [param2+10h]  
 mov         rcx,qword ptr [param1+18h]  
 sbb         rcx,qword ptr [param2+18h]  

;	// SI A-B est négatif
;	if (carry)
 jnc          _endif_debordement;
    ;		// on enlève ce qui dépasse mod P
    mov     rax,1000003D1h  
    sub     r9,rax  
    sbb     r10,0  
    sbb     r11,0  
    sbb     rcx,0  
	
_endif_debordement:
; copie résultat
 mov         qword ptr [param3]    ,r9  
 mov         qword ptr [param3+8]  ,r10  
 mov         qword ptr [param3+10h],r11  
 mov         qword ptr [param3+18h],rcx  

;Epilogue
 ret  

 sub256x256_Modulo_CoordCourbeSepc256k endp
 END