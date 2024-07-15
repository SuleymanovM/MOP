.model small
.stack 200h
.386

include mlab1.inc    
include mlab1.mac

.data    
    sline     db 78 dup(CHSEP), 0
    req       db "Фамилия И.О.: ", 0FFh
    minis     db "Министерство образования Российской Федерации", 0
    ulstu     db "Ульяновский государственный технический университет", 0
    dept      db "Кафедра вычислительной техники", 0
    mop       db "Машинно-ориентированное программирование", 0
    labr      db "Лабораторная работа №1", 0
    req1      db "Замедлить время работы в тактах(-), ускорить время работы в тактах (+),", 0
	req2      db "вычислить функцию (f), выйти(ESC)?", 0FFh
	tacts     db "Время работы в тактах: ", 0FFh
    emptys    db 0
    buflen    =  70
    buf       db buflen
    lens      db ?
    sname     db buflen dup(0)
    pause     dw 0, 0
    ti        db LENNUM+LENNUM/2 dup(?), 0
;------------- Новые переменные ------------------------------------
    req3    db    "Введите 20 бит числа X", 0
    req31   db   "Введите 20 бит числа Y", 0
    req4    db    "f16 = x1x2!x3 | !x2x3 | !x1!x2 | !x2!x3", 0

    bitlen dw 20
    bits_array db 20 dup(?)
    result_x dd ?
    result_y dd ?

    x1 db ?
    x2 db ?
    x3 db ?


    c1 db ?
    c2 db ?
    c3 db ?
    c4 db ?

    f db ?
    z dd ?
;-------------------------------------------------------------------


;=======================================
.code
FUNC_EVAL:
	PUTCRLF
	PUTL req3

	COLLECT bits_array, bitlen
	CONVERT bits_array, bitlen
	mov result_x, ebx

	; mov al, ' '
	; call PUTC

	; PRINT result_x, 10
	
	PUTCRLF
	PUTL req4

;----------------------------------------------------
	; EXTRACT_BIT result_x, x3, 0
	; call PUTD

	; EXTRACT_BIT result_x, x2, 1
	; call PUTD

	; EXTRACT_BIT result_x, x1, 2
	; call PUTD





;----------------------------------------------------
	mov al, x1
	mov bl, x2
	mov cl, x3
	and bl, al
	not cl
	and cl, 1
	and bl, cl
	mov c1, bl

	mov al, x2
	mov bl, x3
	not al
	and al, 1
	and al, bl
	mov c2, al

	mov al, x1
	mov bl, x2
	not al
	not bl
	and al, 1
	and bl, 1
	and al, bl
	mov c3, al

	mov al, x2
	mov bl, x3
	not al
	not bl
	and al, 1
	and bl, 1
	and al, bl
	mov c4, al

	; mov al, ' '
	; call PUTC

	; mov al, c1
	; call PUTD




	; mov al, c2
	; call PUTD

	; mov al, c3
	; call PUTD

	; mov al, c4
	; call PUTD

	mov al, c1
	mov bl, c2
	mov cl, c3
	mov dl, c4
	or al, bl
	and al, 1
	or cl, dl
	and cl, 1
	or al, cl
	and al, 1
	mov f, al

	; mov al, ' '
	; call PUTC

	mov al, f
	call PUTD

;----------------------------------------------------
	PUTCRLF
	PUTL req31

	COLLECT bits_array, bitlen
	CONVERT bits_array, bitlen
	mov result_y, ebx

	; mov al, ' '
	; call PUTC

	; PRINT result_y, 10

	PUTCRLF


	cmp f, 1
	jne false

true:
	shl result_x, 2
	shl result_y, 1
	; mov al, '+'
	; call PUTC
	jmp after_true

false:
	shr result_x, 3
	shl result_y, 2
	; mov al, '-'
	; call PUTC

after_true:
	mov eax, result_x
	mov ebx, result_y
	add eax, ebx
	mov z, eax

	; mov al, ' '
	; call PUTC

	PRINT z, 2

	PUTCRLF

;----------------------------------------------------
; z11 &= z9
	mov ebx, z
	shr ebx, 9
	and ebx, 1

	mov ecx, z
	shr ecx, 11
	and ecx, 1

	and ebx, ecx
	shl ebx, 11
	mov eax, z
	and eax, 0FFFFF7FFh
	or eax, ebx
	mov z, eax
;----------------------------------------------------
; z17 |= z16
	mov ebx, z
	shr ebx, 16
	and ebx, 1

	mov ecx, z
	shr ecx, 17
	and ecx, 1

	or ebx, ecx
	shl ebx, 17

	mov eax, z
	and eax, 0FFFDFFFFh
	or eax, ebx
	mov z, eax
;----------------------------------------------------
; z13 = !z15
	mov ebx, z
	shr ebx, 15
	and ebx, 1
	not ebx
	and ebx, 1

	mov ecx, ebx
	shl ecx, 13

	mov eax, z
	and eax, 0FFFFDFFFh
	or eax, ecx
	mov z, eax

	PRINT z, 2


	mov ah, 4ch  
	int 21h
	
;----------------------------------------------------
BEGIN LABEL NEAR
	MOV AX, @DATA
	MOV DS, AX

	MOV pause, pause_L
	MOV pause+2, pause_H
	PUTLS req

	LEA DX, buf
	CALL GETS

@@L:
	FIXTIME
	PUTL emptys
	PUTL sline
	PUTL emptys
	PUTLSC minis 
	PUTL emptys
	PUTLSC ulstu  
	PUTL emptys
	PUTLSC dept 
	PUTL emptys
	PUTLSC mop  
	PUTL emptys
	PUTLSC labr
	PUTL emptys
	PUTLSC sname
	PUTL emptys
	PUTL sline 
	DURAT
	LEA DI, ti
	CALL UTOA10    
	PUTL tacts
	PUTL ti 
	PUTL req1




	PUTL req2
	CALL GETCH
	CMP AL, 'f'
	JE FUNC_EVAL
	CMP AL, '-'
	JNE CMINUS
	INC pause+2 
	JMP @@L

CMINUS:
	CMP AL, '+' 
	JNE CEXIT
	CMP WORD PTR pause+2, 0        
	JE BACK
	DEC pause+2 

BACK: 
	JMP @@L

CEXIT: 
	CMP AL, CHESC    
	JE @@E
	TEST AL, AL
	JNE BACK
	CALL GETCH
	JMP @@L

@@E:
	EXIT
	
	EXTRN PUTSS: NEAR
	EXTRN PUTC: NEAR
	EXTRN PUTD: NEAR
	EXTRN GETCH: NEAR
	EXTRN GETS: NEAR
	EXTRN SLEN: NEAR
	EXTRN UTOA10: NEAR
	EXTRN COLLECTOR: NEAR
	EXTRN CONVERTER: NEAR
	EXTRN PRINTER: NEAR
END BEGIN

