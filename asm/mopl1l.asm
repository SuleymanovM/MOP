;**********************************************
; ��楤��� ��� ������୮� ࠡ��� �1 �� ��� *
;**********************************************

.MODEL SMALL
.CODE
.386
	INCLUDE MOPL1.INC
	LOCALS
;=====================================================
; ����ணࠬ�� �뢮�� �� ��࠭ ��ப�, ����㥬�� SI, 
; � ����প�� �६��� ����� ᨬ������ � <CX,DX> mcs.
; ������⥫ﬨ ��ப� ����� ����� 0 ��� 0FFh.
; ���� ��ப� �����稢����� ���⮬ 0,
;   �� ���������� ���室 � ��砫� ����� ��ப�
; 
;=====================================================
	PUTSS PROC NEAR
		@@L:
			MOV AL, [SI]
			CMP AL, 0FFH
			JE @@R
			CMP AL, 0
			JZ @@E
			CALL PUTC
			INC SI
			CALL DILAY
			JMP SHORT @@L
		; Переход на следующую строку
		@@E:
			MOV AL, CHCR
			CALL PUTC
			MOV AL, CHLF
			CALL PUTC
		@@R:
			RET
	PUTSS ENDP

	PUTC PROC NEAR
		PUSH DX
		MOV DL, AL
		MOV AH, FUPUTC
		INT DOSFU
		POP DX
		RET
	PUTC ENDP

	PUTD PROC NEAR
		PUSH DX
		MOV DL, AL
		ADD DL, 30h
		MOV AH, FUPUTC
		INT DOSFU
		POP DX
		RET
	PUTD ENDP

;==============================================
	COLLECTOR PROC NEAR
		input_loop:
			mov ah, 01h
			int 21h
			sub al, '0'
			mov [di], al
			inc di
			loop input_loop

		ret
	COLLECTOR ENDP

	CONVERTER PROC NEAR
		convert_loop:
			shl ebx, 1
			mov al, [di]
			add ebx, eax
			inc di
			loop convert_loop

		ret
	CONVERTER ENDP

	PRINTER PROC NEAR
		process_digits:
			xor dx, dx
			div ecx
			push dx
			inc bx
			test eax, eax
			jnz process_digits

		print_loop:
			pop dx
			add dl, '0'
			mov ah, 02h
			int 21h
			dec bx
			jnz print_loop

		ret
	PRINTER ENDP
;==============================================




	GETC PROC NEAR
		MOV AH, FUGETC
		INT DOSFU
		RET
	GETC ENDP

	GETCH PROC NEAR
		MOV AH, FUGETCH
		INT DOSFU
		RET
	GETCH ENDP

	GETS PROC NEAR
		PUSH SI
		MOV SI, DX
		MOV AH, FUGETS
		INT DOSFU
		
		; прописать байт 0 в конец строки
		XOR AH, AH
		MOV AL, [SI+1]
		ADD SI, AX
		MOV BYTE PTR [SI+2], 0
		POP SI
		RET
	GETS ENDP

	SLEN PROC NEAR
		XOR AX, AX
		
		LSLEN:
			CMP BYTE PTR [SI], 0
			JE RSLEN
			CMP BYTE PTR [SI], 0FFh
			JE RSLEN
			INC AX
			INC SI
			JMP SHORT LSLEN
		RSLEN:
			RET
	SLEN ENDP







.DATA
	UBINARY DQ 0  ; Исходное двоичное 64-разрядное
	UPACK DT 0  ; Упакованные 18 десятичных цифр 

.CODE
	UTOA10 PROC NEAR
		PUSH CX
		PUSH DI
		MOV DWORD PTR [UBINARY], EAX
		MOV DWORD PTR [UBINARY+4], EDX
		FINIT   ; инициализация сопроцессора
		FILD UBINARY  ; забрасывание в него бинарного
		FBSTP UPACK  ; извлечение упаковонного десятичного
		MOV CX, LENPACK ; получено 9 пар цифр
		PUSH DS  ; писать 
		POP ES   ;   будем
		CLD       ;     через stosw
		LEA SI, UPACK   ;     с конца 
		ADD SI, LENPACK ;     буфера upack        
		
		; Цикл преобразования пар полубайтов в ASCII-коды цифр
		@@L:
			XOR AX, AX
			DEC SI
			MOV AL, [SI]
			SHL AX, 4
			SHR AL, 4 
			ADD AX, 3030h
			XCHG AL, AH
			STOSW  
			LOOP @@L
		
		; Фиксация конца строки
		XOR AL, AL
		STOSB

		; Улучшим читабельность слишком длинного числа
		CLD
		MOV AX, LENNUM-4 
		
		@@L1:
			MOV CX, AX
			POP DI    ; встаем на начало строки
			PUSH DI 
			MOV SI, DI
			INC SI
			REP MOVSB
			MOV BYTE PTR [DI], CHCOMMA ; вставить разделитель
			SUB AX, 4  ;     3 цифры + разделитель обработаны
			JS @@E        ; прекратить, если осталось не более 3-х 
			JMP SHORT @@L1

		@@E:
			POP SI
			PUSH SI
			XOR CX, CX

		; Съедаем первые нули
		;   сначала подсчитываем
		@@L2:
			CMP BYTE PTR [SI], '0'
			JE @@N
			CMP BYTE PTR [SI], CHCOMMA  
			JNE @@N1
		
		@@N:
			INC CX
			INC SI
			JMP SHORT @@L2
		
		@@N1: ;   а теперь съедаем
			POP DI
			SUB CX, LENNUM+1
			NEG CX
			REP MOVSB
			POP CX
			
		RET
	UTOA10 ENDP

	DILAY PROC NEAR
		MOV AH, 86h
		INT 15h
		RET
	DILAY ENDP

	PUBLIC PUTSS, PUTC, PUTD, GETCH, GETS, DILAY, SLEN, UTOA10, COLLECTOR, CONVERTER, PRINTER

END
