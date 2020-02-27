; multiplication de 1 entier 256 bits par un entire 32 bits modulo 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F
; version 32 bits
; Proto C :
; EXPORT void multiplicationModulo_256x32_sepc256k (byte* pNombreA, UINT64 nombreB, OUT byte* pResultat)

.MODEL FLAT ; requis par masm


.CODE

; procédure utilitaire : multiplication 256*32 sans modulo
multiplication_256x32_512 PROC
	; Proto C :
	;  void multiply256x32_256(int256 *À, int32 B, OUT int256 *C);
	; calcule C = À * B
	; AVEC 
	;	   edi = *À
	;	   ESI = *B
	;	   ECX = *C (dest)
	;
	; À en big endian :
	; 0				+4			+8			 +12
	; poids faible						 poids fort
	
	; prolohue
	Push    ebp
	mov     ebp, ESP   
	Push	ebx
	Push 	edx
	Push    ecx
	Push 	edi
	Push 	esi
	
	; recu param
	mov edi,[ebp +8]
	mov ebx,[ebp+12] ; B
	mov ecx,[ebp+16]
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; A0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; A0 * B0
	mov eax,[edi+0]
	mul ebx		; (edx,eax) = eax * ebx
	mov [ecx+ 0],eax
	mov [ecx+ 4],edx
	; Raz fin du buffer
	xor eax,eax
	mov [ecx+  8],eax
	mov [ecx+ 12],eax
	mov [ecx+ 16],eax
	mov [ecx+ 20],eax
	mov [ecx+ 24],eax
	mov [ecx+ 28],eax

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; A1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; A1 * B0
	mov eax,[edi+4]
	mul ebx		; (edx,eax) = eax * ebx
	Add [ecx+ 4],eax  
	adc [ecx+ 8],edx
	mov eax,0      ; eax = 0
	adc [ecx+ 12],eax ; //+0+c
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; A2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; A2 * B
	mov eax,[edi+8]
	mul ebx		; (edx,eax) = eax * ebx
	Add [ecx+ 8],eax  
	adc [ecx+ 12],edx
	mov eax,0      ; eax = 0
	adc [ecx+ 16],eax ; //+0+c
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; A3 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; A3 * B
	mov eax,[edi+12]
	mul ebx		; (edx,eax) = eax * ebx
	Add [ecx+ 12],eax  
	adc [ecx+ 16],edx
	mov eax,0      ; eax = 0
	adc [ecx+ 20],eax ; //+0+c
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; A4 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; A4 * B
	mov eax,[edi+16]
	mul ebx		; (edx,eax) = eax * ebx
	Add [ecx+ 16],eax  
	adc [ecx+ 20],edx
	mov eax,0      ; eax = 0
	adc [ecx+ 24],eax ; //+0+c
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; A5 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; A5 * B
	mov eax,[edi+20]
	mul ebx		; (edx,eax) = eax * ebx
	Add [ecx+ 20],eax
	adc [ecx+ 24],edx
	mov eax,0      ; eax = 0
	adc [ecx+ 28],eax ; //+0+c	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; A6 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; A6 * B
	mov eax,[edi+24]
	mul ebx		; (edx,eax) = eax * ebx
	Add [ecx+ 24],eax  
	adc [ecx+ 28],edx
	mov eax,0      ; eax = 0
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; A7 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; A7 * B
	mov eax,[edi+28]
	mul ebx		; (edx,eax) = eax * ebx
	Add [ecx+ 28],eax  
	; retenue AVEC carry
	adc edx, 0 
	mov eax, edx

	; epilogue
	Pop esi
	Pop edi
	Pop ecx
	Pop edx	
	Pop	ebx
	Pop	ebp
	ret 12

multiplication_256x32_512 ENDP

;-----------------------------------------------------
_mult256x32_Modulo_CoordCourbeSepc256k PROC
; prologue
    push edi
 ; récup adresses paramètres
    mov edi,[ESP+8]  ; P1 = A dans edi
    mov edx,[ESP+12] ; P2 = B dans edx
    mov ecx,[ESP+16] ; P3 = pResultat dans ecx

    ; calcul de A*B => pResultat sasns modulo
    push ecx
    push edx
    push edi
    call multiplication_256x32_512
    ; eax contient le dépassement
     mov ecx,[ESP+16] ; P3 = pResultat dans ecx
_while_depasse:
    cmp eax,0
    je fin  ; si e==0 (pas de dépassement),  terminé
        ; on dépasse le modulo
        ; on ajoute a 0x1000003d au résultat
   	    mov ebx,000003D1h
	    add [ecx],ebx
	    mov ebx,00000001h
	    adc [ecx+4], ebx
	    mov ebx,00000000h
	    adc [ecx+8 ], ebx
	    adc [ecx+12], ebx
	    adc [ecx+16], ebx
	    adc [ecx+20], ebx
	    adc [ecx+24], ebx
	    adc [ecx+28], ebx     
        ; on additionne pour chauqe fois qu'on dépasse (7x max)
        dec eax
        jmp _while_depasse

fin:
 ;epilogue
    pop edi
    ret 12

_mult256x32_Modulo_CoordCourbeSepc256k endp
END