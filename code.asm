; Задача №7
; Найти сумму диагональных элементовм матрицы 3х3
.386p   ; тип росессора: 80386 и выше с матем. сопроцессором
.model flat,stdcall ; плоская модель памяти и соглашение по передаче параметров stdcall
option casemap:none ; учитывать регистр имен

includelib D:\masm32\lib\kernel32.lib   ; библиотеки статического связывания для kernel32.dll и пр.
includelib D:\masm32\lib\user32.lib
includelib D:\masm32\lib\masm32.lib     ; внутренняя библиотека MASM32
include D:\masm32\include\kernel32.inc  ; константы и экспорт функций для kernel32.dll и пр.
include D:\masm32\include\user32.inc
include D:\masm32\include\masm32.inc

STD_OUTPUT_HANDLE equ -11   ; дескриптор вывода (см. памятку)
STD_INPUT_HANDLE equ -10    ; дескриптор ввода

; объявляем необходимые константы
.const 
	NULL equ 0
	MB_OK equ 0		; тип окна
	n 			equ	4 ; колличество строк
	m			equ	3  ; колличество столбцов
	mn			equ	m*n ; длина массива
	temp equ m-1
	middle equ (mn-1)*2
	elsizeequ		equ	4   ; байт в элементе
	NmberOfDigits 	equ	7   ; символов в числе, реаsльно на 2 меньше

; объявляем и инициализируем необходимые переменные
.data
	InputMsg db "Enter row:",0Ah,0Dh,0
                  MatrixMsg db "Matrix:",0Ah,0Dh,0
                  ResultMsg db "Sum: ",0Ah,0Dh,0
                  endl db 0Ah,0Dh,0
                  space db " ",0
	AnswerMessage1 db "Maximum element",0
	AnswerMessage2 db "Column (j)",0
	AnswerMessage3 db "Row (i)",0

	BufferStr db NmberOfDigits dup (0h)     ; буфер для ввода чисел
	BufferStrO db 5 dup (0h)
	num dd mn dup(0h)	; масив		
	sl dd 0

; объявляем необходимые для работы переменные
.data?
	OutHandle	dd	?
	InHandle	dd	?
	Len 	dd	?	; для API функций
 	Buffer	dd	?
	ActRead dd	?

            ;Сумма нечетных элементов столбцов
                  sum dd ?
				  middl1 dd ?
				  tmp dd ?

.code

; Процедуры ввода и вывода

; uses указывает MASM'у добавить сохранение на стек указанных регистров
; перед вызовом процедуры и восстановить их после завершения
; в данном случае мы сохраняем ecx поскольку он используется в loop
; proto используется для определения типов аргументов,
; т.е. попытка передать PrintStringToConsole DWORD закончится ошибкой во время компиляции

; Процедура вывода строки на консоль (аргумент - адрес строки)
    PrintStringToConsole proto val:PTR BYTE
    PrintStringToConsole proc uses eax ecx val:PTR BYTE
        invoke StrLen, val
        mov sl, eax
        invoke	WriteConsoleA,OutHandle,val,sl,offset Len,offset Buffer
        ret
    PrintStringToConsole endp

; Процедура вывода числа на консоль (аргумент - число)
    PrintDwordToConsole proto val:DWORD
    PrintDwordToConsole proc uses eax ecx val:DWORD
        invoke ltoa,val,offset BufferStrO
        invoke StrLen,offset BufferStrO
        mov sl,eax
        invoke	WriteConsoleA,OutHandle,offset BufferStrO,sl,offset Len,offset Buffer
        ret
    PrintDwordToConsole endp
	
	

; Процедура считывания числа с консоли (результат в eax)
    ReadIntFromConsole proto
    ReadIntFromConsole proc uses ecx
        invoke	ReadConsole,InHandle,offset BufferStr,NmberOfDigits,offset ActRead,0
        invoke atol,offset BufferStr   ; переводим в число
        ret
    ReadIntFromConsole endp

 start:
 ;------------------Получаем дескрипторы ввода и вывода -----------------
	invoke GetStdHandle,STD_OUTPUT_HANDLE  ; HANDLE для вывода
	mov OutHandle,eax			   ; и сохраняем его
	invoke GetStdHandle,STD_INPUT_HANDLE   ; HANDLE для ввода
	mov InHandle,eax			   ; и сохраняем его

 ;---------------------------------Ввод-----------------------------------
	xor esi,esi
	xor ecx,ecx
	mov ecx,n              ; сколько строк
	mov esi,offset num						
	
	OUTTER:		     ; цикл по строкам
		push ecx
		mov ecx,m     ; сколько столбцов (повторов вложенного цикла)
		
		; вывод приглашения
                                    invoke PrintStringToConsole, offset InputMsg

		; внутренний цикл
	INNER:
                                    ; считываем в буфер строку
                                    invoke ReadIntFromConsole
		mov [esi],eax
		add esi,elsizeequ ; смещаемся к следующему элементу

		loop INNER

		pop ecx
		loop OUTTER

;--------------------------Вычисление суммы диагональных элементов-----------------------------------

	mov sum, 0
	mov middl1, 0
    mov esi, 0
	
	mov eax, n
	cmp eax, m
	jle notgreater
	jg greater

	notgreater:
		mov ecx, n
		mov edi, n
		mov middl1, 2*(mn-m+n-1)
		jmp loop1
	
	greater:
		mov ecx, m
		mov edi, m
		mov middl1, 2*(m*m-1)
	
	

	loop1:
		;побочная диагональ
		mov eax, m
		imul eax, esi
		sub eax, esi
		add eax, edi
		sub eax, 1
		imul eax, 4
		mov ebx, [num+eax]
		add sum, ebx
	
		;главная диагональ
		mov eax, esi
		imul eax, m+1
		imul eax, 4
		mov ebx, [num+eax]
		add sum, ebx
	
		add esi,1
	loop loop1

	test edi, 1
	jz calc_end
	
	sub_central_element:	
		;вычитание центрального элемента
		mov esi, middl1
		mov eax, sum
		sub eax, [num+esi]
		mov sum, eax


	calc_end:
		
	
;--------------------------Вывод результата-----------------------------------
                  
	xor ecx,ecx
	xor ebp,ebp
	xor esi,esi

                  ; Выводим матрицу в консоль
                  invoke PrintStringToConsole, offset endl
                  invoke PrintStringToConsole, offset MatrixMsg

                  ; Цикл по строкам
                  mov esi, 0
                  mov ecx, n
                  PRINTROW:
                    push ecx

                    ; Цикл по столбцам
                    mov ecx, m
                    PRINTCOLUMN:
                        invoke PrintDwordToConsole, [num+esi]
                        invoke PrintStringToConsole, offset space
                    
                        ; Следующий элемент
                        add esi, elsizeequ
                        loop PRINTCOLUMN

                    ; Следующая строка
                    invoke PrintStringToConsole, offset endl
                    pop ecx
                    loop PRINTROW

                  invoke PrintStringToConsole, offset endl

                  ; Выводим ответ в консоль
                  invoke PrintStringToConsole, offset ResultMsg
                  invoke PrintDwordToConsole, sum
            

;---------------------------Выход--------------------------------------------
 INVOKE ExitProcess,0
 end    start 