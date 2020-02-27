; soustracion de 2 entier 256 bits modulo 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; version 32 bits
; Proto C :
;  void soustractionModulo_sepc256k(byte* pNombreA, byte* pNombreB, OUT byte* pResultat)

.MODEL FLAT ; requis par masm

.CODE
_sub256x256_Modulo_CoordCourbeSepc256k PROC
; prologue
 push edi

; récup adresses paramètres
 mov edi,[ESP+8]  ; P1 = A dans edi
 mov edx,[ESP+12] ; P2 = B dans edx
 mov ecx,[ESP+16] ; P3 = pResultat dans ecx

	
	;  bit 0 a 31
	mov eax,[edi]
	sub eax,[edx]
	mov [ecx],eax   ;   A -= B
	; bits 32 a 63
	mov eax,[edi+4]
	sbb eax,[edx+4]
	mov [ecx+4],eax  ;  A -= B + retenue
	; bits 63..
	mov eax,[edi+8]
	sbb eax,[edx+8]
	mov [ecx+8],eax  ;  A -= B + retenue
	mov eax,[edi+12]
	sbb eax,[edx+12]
	mov [ecx+12],eax  ;  A -= B + retenue
	; bits 128 ...
	mov eax,[edi+16]
	sbb eax,[edx+16]
	mov [ecx+16],eax  ;  A -= B + retenue
	mov eax,[edi+20]
	sbb eax,[edx+20]
	mov [ecx+20],eax  ;  A -= B + retenue
	mov eax,[edi+24]
	sbb eax,[edx+24]
	mov [ecx+24],eax  ;  A -= B + retenue
	mov eax,[edi+28]
	sbb eax,[edx+28]
	mov [ecx+28],eax  ;  A -= B + retenue

;	// SI A-B est négatif
;	if (carry)
	jnc     _endif_debordement;
	;		// on enlève ce qui dépasse mod P = 1000003D1h
		mov eax,000003D1h
		sub [ecx],eax
		mov eax,00000001h
		sbb [ecx+4], eax
		mov eax,00000000h
		sbb [ecx+8 ], eax
		sbb [ecx+12], eax
		sbb [ecx+16], eax
		sbb [ecx+20], eax
		sbb [ecx+24], eax
		sbb [ecx+28], eax


_endif_debordement:

; epilogue
 pop edi
 ret 12



 _sub256x256_Modulo_CoordCourbeSepc256k endp
 END