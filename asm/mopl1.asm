;***************************************************************************************************
; MOPL1.ASM - учебный пример для выполнения 
; лабораторной работы N1 по машинно-ориентированному программированию
; 10.09.02: Негода В.Н.
;***************************************************************************************************
        .MODEL SMALL
        .STACK 200h
	.386
;       Используются декларации констант и макросов
        INCLUDE MOPL1.INC	
        INCLUDE MOPL1.MAC

; Декларации данных
        .DATA    
SLINE	DB	78 DUP (CHSEP), 0
REQ	DB	"Фамилия И.О.: ",0FFh
MINIS	DB	"МИНИСТЕРСТВО ОБРАЗОВАНИЯ РОССИЙСКОЙ ФЕДЕРАЦИИ",0
ULSTU	DB	"УЛЬЯНОВСКИЙ ГОСУДАРСТВЕННЫЙ ТЕХНИЧЕСКИЙ УНИВЕРСИТЕТ",0
DEPT	DB	"Кафедра вычислительной техники",0
MOP	DB	"Машинно-ориентированное программирование",0
LABR	DB	"Лабораторная работа N 1",0
REQ1    DB      "Замедлить(-),ускорить(+), посчитать функцию f(f), выйти(ESC)? ",0FFh
TACTS   DB	"Время работы в тактах: ",0FFh
EMPTYS	DB	0
BUFLEN = 70
BUF	DB	BUFLEN
LENS	DB	?
SNAME	DB	BUFLEN DUP (0)
PAUSE	DW	0, 0 ; младшее и старшее слова задержки при выводе строки
TI	DB	LENNUM+LENNUM/2 DUP(?), 0 ; строка вывода числа тактов
LAB1_MSG_IN_X DB "Введите X", 0
LAB1_MSG_IN_Y DB "Введите Y", 0
LAB1_F_VAR DB "f6 = !x1!x2x3 | x1x3 | x2!x3 | x2x4 | x1!x3!x4", 0
LAB1_MSG_F DB "Функция равна: $"
LAB1_MSG_Z DB "Z равен:", 0
LAB1_MSG_CHCK DB "Проверка массива:", 0
X_ DB 20 dup(0)
X  DD 0
Y DD 0
Z DD 0
F DD 0

                                          ; запас для разделительных "`"

;========================= Программа =========================
        .CODE
; Макрос заполнения строки LINE от позиции POS содержимым CNT объектов,
; адресуемых адресом ADR при ширине поля вывода WFLD
BEGIN	LABEL	NEAR
	; инициализация сегментного регистра
	MOV	AX,	@DATA
	MOV	DS,	AX
	; инициализация задержки
	MOV	PAUSE,	PAUSE_L
	MOV	PAUSE+2,PAUSE_H
	PUTLS	REQ	; запрос имени
	; ввод имени
	LEA	DX,	BUF
	CALL	GETS	
@@L:	; циклический процесс повторения вывода заставки
	; вывод заставки
	; ИЗМЕРЕНИЕ ВРЕМЕНИ НАЧАТЬ ЗДЕСЬ
	FIXTIME
	PUTL	EMPTYS
	PUTL	SLINE	; разделительная черта
	PUTL	EMPTYS
	PUTLSC	MINIS	; первая 
	PUTL	EMPTYS
	PUTLSC	ULSTU	;  и  
	PUTL	EMPTYS
	PUTLSC	DEPT	;   последующие 
	PUTL	EMPTYS
	PUTLSC	MOP	;    строки  
	PUTL	EMPTYS
	PUTLSC	LABR	;     заставки
	PUTL	EMPTYS
	; приветствие
	PUTLSC	SNAME   ; ФИО студента
	PUTL	EMPTYS
	; разделительная черта
	PUTL	SLINE
	; ИЗМЕРЕНИЕ ВРЕМЕНИ ЗАКОНЧИТЬ ЗДЕСЬ 
	DURAT    	; подсчет затраченного времени
	; Преобразование числа тиков в строку и вывод
	LEA	DI,	TI
	CALL	UTOA10	
	PUTL	TACTS
	PUTL	TI      ; вывод числа тактов
	; обработка команды
	PUTL	REQ1
	CALL	GETCH
	CMP	AL,	'-'    ; удлиннять задержку?
	JNE	CMINUS
	INC	PAUSE+2        ; добавить 65536 мкс
	JMP	@@L
CMINUS:	CMP	AL,	'+'    ; укорачивать задержку?
	JNE	LAB1_CFUNC
	CMP	WORD PTR PAUSE+2, 0		
	JE	BACK
	DEC	PAUSE+2        ; убавить 65536 мкс
BACK:	JMP	@@L
LAB1_CFUNC:
	CMP AL, 'f'
	JE LAB1_CODE
	CMP AL, 'F'
	JE LAB1_CODE
	JMP CEXIT
LAB1_CODE:
	MOV ECX, 5
	PUTL	EMPTYS
	PUTL	EMPTYS
	PUTL	EMPTYS
	PUTL	EMPTYS
	PUTL	EMPTYS
	PUTL SLINE
	
	PUTL LAB1_MSG_IN_X

	MOV ECX, 20
	LEA ESI, X_ + 20; в ESI хранится адрес конца массива
	XOR EDX,EDX

LAB1_IN_X:
	SHL EDX, 1
	DEC SI
	BTR DWORD PTR [SI], 0
	CALL GETCH
	CALL PUTC
	CMP AL, '1'
	JNE LAB1_IN_X_NZ
	ADD DWORD PTR [SI], 1
	ADD EDX, 1
LAB1_IN_X_NZ:
	LOOP LAB1_IN_X 
	MOV X, EDX

	MOV AL, 10
	CALL PUTC
	MOV AL, 13
	CALL PUTC
	;теперь x1: [ESI + 1] и т.д.

	PUTL LAB1_MSG_CHCK

	MOV ECX, 20
	LEA ESI, X_ + 20

LAB1_FUNC_CALC: ;f6 = !x1!x2x3 | x1x3 | x2!x3 | x2x4 | x1!x3!x4

	DEC SI
	MOV AX, [SI]
	ADD AX, '0'
	CALL PUTC
	LOOP LAB1_FUNC_CALC

	MOV AL, 10
	CALL PUTC
	MOV AL, 13
	CALL PUTC

	XOR EAX, EAX
	XOR EBX, EBX

	MOV AL, [ESI+1] ; x1
	MOV BL, [ESI+2] ; x2
	AND AL, BL		; !x1!x2
	MOV BL, [ESI+3] ; x3
	BTC BX, 0
	AND AL, BL		; !x1!x2x3

	MOV F, EAX 		; F = !x1!x2x3


	MOV AL, [ESI+2] ; x2
	BTC AX, 0
	MOV BL, [ESI+3] ; x3	
	BTC BX, 0
	AND AL, BL		; x1x3

	OR EAX, F 		; !x1!x2x3 | x1x3
	MOV F, EAX		; F = !x1!x2x3 | x1x3


	MOV AL, [ESI+1] ; x1	
	BTC AX, 0
	MOV BL, [ESI+2] ; x2
	BTC BX, 0 		; !x2	
	AND AL, BL		; x2!x3

	OR EAX, F 		; x1x3x4 | x1!x2 | x2!x3
	MOV F, EAX		; F = x1x3x4 | x1!x2 | x2!x3


	MOV AL, [ESI+2] ; x1	
	BTC AX, 0
	MOV BL, [ESI+3] ; x2
	BTC BX, 0 		; !x2	
	AND AL, BL		; x2!x3

	OR EAX, F 		; x1x3x4 | x1!x2 | !x3!x4 | x2x4
	MOV F, EAX		; F = x1x3x4 | x1!x2 | !x3!x4 | x2x4


	MOV AH, 09h     
    LEA DX, LAB1_MSG_F
    INT 21h

	ADD AX, '0'
	CALL PUTC

	PUTL EMPTYS
	PUTL LAB1_MSG_IN_Y

	MOV ECX, 20 	; Ввод Y
	XOR EDX, EDX

LAB1_IN_Y:
	SHL EDX, 1
	CALL GETCH
	CALL PUTC
	CMP AL, '1'
	JNE LAB1_IN_Y_NZ
	ADD EDX, 1

LAB1_IN_Y_NZ:
	LOOP LAB1_IN_Y
	
	MOV Y, EDX

	PUTL EMPTYS

	CMP F, 0 		; Проверка функции
	JE LAB1_F_FALSE
	JNE LAB1_F_TRUE

; X * 2 - Y
LAB1_F_TRUE:
	SHL X, 2
	SHL Y, 1
	MOV EAX, X      ; Y * 2 
	MOV EBX, Y
	ADD EAX, EBX		
	MOV Z, EAX		; Z = X * 4 + Y * 2

	JMP LAB1_Z_FIRST	

; X / 8 + Y
LAB1_F_FALSE:
	SHR X, 3
	SHL Y, 2
	MOV EAX, X      ; X / 8
	MOV EBX, Y
	ADD EAX, EBX		
	MOV Z, EAX		; Z = X / 8 + Y * 2


LAB1_Z_FIRST:
	MOV EBX, Z 
	XOR EAX, EAX
	PUTL LAB1_MSG_Z
	SHL EBX, 12		; сдвиг лишних 12 битов слева
	MOV ECX, 20

LAB1_OUT_Z_0:
    SHL EBX, 1  	; Сдвиг значения EBX на 1 бит влево
    DEC ECX     	; Уменьшение счетчика
    JC LAB1_OUT_Z_NZ_0

LAB1_OUT_Z_Z_0:
    MOV AL, '0'  	; Если бит был 0, выводим '0'
    CALL PUTC
    JMP CHECK_EXIT_0

LAB1_OUT_Z_NZ_0:
    MOV AL, '1'  	; Если бит был 1, выводим '1'
    CALL PUTC

CHECK_EXIT_0:
    CMP ECX, 0  	; Проверяем, закончили ли мы вывод всех бит
    JG LAB1_OUT_Z_0	; Если да, то продолжаем вывод

; z17 |= z16; z13 = ¯z15; z11 &= z9; 
; z7& = z4; z9 |= z11; z15 = ¯z17;

	MOV AL, 10
	CALL PUTC
	MOV AL, 13
	CALL PUTC

	MOV EAX, Z
	BT EAX, 16		; проверка 16-го бита
	JC LAB1_Z_FIRST_NZ

	MOV EBX, 0		; если 11-й бит равен 0
	JMP LAB1_Z_FIRST_CALC

LAB1_Z_FIRST_NZ:	
	MOV EBX, 1		; если 11-й бит равен 1

LAB1_Z_FIRST_CALC:	
	SHL EBX, 17		; создание маски для операции OR
	MOV EAX, Z
	OR EAX, EBX 	; применение маски
	MOV Z, EAX

	BT EAX, 15		; проверка 17-го бита
	JC LAB1_Z_SECOND_NZ
	
	; z17 |= z16; z13 = ¯z15; z11 &= z9; 
	; z7& = z4; z9 |= z11; z15 = ¯z17;

	BTS EAX, 13		; если 17-й бит равен 0, то 15-й бит равен 1
	JMP LAB1_Z_THIRD

LAB1_Z_SECOND_NZ:	
	BTR EAX, 13		; если 17-й бит равен 1, то 15-й бит равен 0

LAB1_Z_THIRD:
	MOV Z, EAX

	BT EAX, 9		; проверка 4-го бита
	JC LAB1_Z_THIRD_END ; если 4-й бир равен 1, то 7-й бит не изменяем

LAB1_Z_THIRD_Z:		
	BTR EAX, 11		; если 4-й бит равен 0, то 7-й бит равен 0

LAB1_Z_THIRD_END:
	MOV Z, EAX
	
	PUTL LAB1_MSG_Z

	MOV EBX, Z 
	XOR EAX, EAX

	SHL EBX, 12		; сдвиг лишних 12 битов слева
	MOV ECX, 20

LAB1_OUT_Z:
    SHL EBX, 1  	; Сдвиг значения EBX на 1 бит влево
    DEC ECX     	; Уменьшение счетчика
    JC LAB1_OUT_Z_NZ

LAB1_OUT_Z_Z:
    MOV AL, '0'  	; Если бит был 0, выводим '0'
    CALL PUTC
    JMP CHECK_EXIT

LAB1_OUT_Z_NZ:
    MOV AL, '1'  	; Если бит был 1, выводим '1'
    CALL PUTC

CHECK_EXIT:
    CMP ECX, 0  	; Проверяем, закончили ли мы вывод всех бит
    JG LAB1_OUT_Z	; Если да, то продолжаем вывод
    JLE @@E   	; Если нет, то выходим




CEXIT:	CMP	AL,	CHESC	
	JE	@@E
	TEST	AL,	AL
	JNE	BACK
	CALL	GETCH
	JMP	@@L
	; Выход из программы
@@E:	EXIT	
        EXTRN	PUTSS:  NEAR
        EXTRN	PUTC:   NEAR
	EXTRN   GETCH:  NEAR
	EXTRN   GETS:   NEAR
	EXTRN   SLEN:   NEAR
	EXTRN   UTOA10: NEAR
	END	BEGIN