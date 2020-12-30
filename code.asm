; ������ �7
; ����� ����� ������������ ���������� ������� 3�3
.386p   ; ��� ���������: 80386 � ���� � �����. �������������
.model flat,stdcall ; ������� ������ ������ � ���������� �� �������� ���������� stdcall
option casemap:none ; ��������� ������� ����

includelib D:\masm32\lib\kernel32.lib   ; ���������� ������������ ���������� ��� kernel32.dll � ��.
includelib D:\masm32\lib\user32.lib
includelib D:\masm32\lib\masm32.lib     ; ���������� ���������� MASM32
include D:\masm32\include\kernel32.inc  ; ��������� � ������� ������� ��� kernel32.dll � ��.
include D:\masm32\include\user32.inc
include D:\masm32\include\masm32.inc

STD_OUTPUT_HANDLE equ -11   ; ���������� ������ (��. �������)
STD_INPUT_HANDLE equ -10    ; ���������� �����

; ��������� ����������� ���������
.const 
	NULL equ 0
	MB_OK equ 0		; ��� ����
	n 			equ	4 ; ����������� �����
	m			equ	3  ; ����������� ��������
	mn			equ	m*n ; ����� �������
	temp equ m-1
	middle equ (mn-1)*2
	elsizeequ		equ	4   ; ���� � ��������
	NmberOfDigits 	equ	7   ; �������� � �����, ���s���� �� 2 ������

; ��������� � �������������� ����������� ����������
.data
	InputMsg db "Enter row:",0Ah,0Dh,0
                  MatrixMsg db "Matrix:",0Ah,0Dh,0
                  ResultMsg db "Sum: ",0Ah,0Dh,0
                  endl db 0Ah,0Dh,0
                  space db " ",0
	AnswerMessage1 db "Maximum element",0
	AnswerMessage2 db "Column (j)",0
	AnswerMessage3 db "Row (i)",0

	BufferStr db NmberOfDigits dup (0h)     ; ����� ��� ����� �����
	BufferStrO db 5 dup (0h)
	num dd mn dup(0h)	; �����		
	sl dd 0

; ��������� ����������� ��� ������ ����������
.data?
	OutHandle	dd	?
	InHandle	dd	?
	Len 	dd	?	; ��� API �������
 	Buffer	dd	?
	ActRead dd	?

            ;����� �������� ��������� ��������
                  sum dd ?
				  middl1 dd ?
				  tmp dd ?

.code

; ��������� ����� � ������

; uses ��������� MASM'� �������� ���������� �� ���� ��������� ���������
; ����� ������� ��������� � ������������ �� ����� ����������
; � ������ ������ �� ��������� ecx ��������� �� ������������ � loop
; proto ������������ ��� ����������� ����� ����������,
; �.�. ������� �������� PrintStringToConsole DWORD ���������� ������� �� ����� ����������

; ��������� ������ ������ �� ������� (�������� - ����� ������)
    PrintStringToConsole proto val:PTR BYTE
    PrintStringToConsole proc uses eax ecx val:PTR BYTE
        invoke StrLen, val
        mov sl, eax
        invoke	WriteConsoleA,OutHandle,val,sl,offset Len,offset Buffer
        ret
    PrintStringToConsole endp

; ��������� ������ ����� �� ������� (�������� - �����)
    PrintDwordToConsole proto val:DWORD
    PrintDwordToConsole proc uses eax ecx val:DWORD
        invoke ltoa,val,offset BufferStrO
        invoke StrLen,offset BufferStrO
        mov sl,eax
        invoke	WriteConsoleA,OutHandle,offset BufferStrO,sl,offset Len,offset Buffer
        ret
    PrintDwordToConsole endp
	
	

; ��������� ���������� ����� � ������� (��������� � eax)
    ReadIntFromConsole proto
    ReadIntFromConsole proc uses ecx
        invoke	ReadConsole,InHandle,offset BufferStr,NmberOfDigits,offset ActRead,0
        invoke atol,offset BufferStr   ; ��������� � �����
        ret
    ReadIntFromConsole endp

 start:
 ;------------------�������� ����������� ����� � ������ -----------------
	invoke GetStdHandle,STD_OUTPUT_HANDLE  ; HANDLE ��� ������
	mov OutHandle,eax			   ; � ��������� ���
	invoke GetStdHandle,STD_INPUT_HANDLE   ; HANDLE ��� �����
	mov InHandle,eax			   ; � ��������� ���

 ;---------------------------------����-----------------------------------
	xor esi,esi
	xor ecx,ecx
	mov ecx,n              ; ������� �����
	mov esi,offset num						
	
	OUTTER:		     ; ���� �� �������
		push ecx
		mov ecx,m     ; ������� �������� (�������� ���������� �����)
		
		; ����� �����������
                                    invoke PrintStringToConsole, offset InputMsg

		; ���������� ����
	INNER:
                                    ; ��������� � ����� ������
                                    invoke ReadIntFromConsole
		mov [esi],eax
		add esi,elsizeequ ; ��������� � ���������� ��������

		loop INNER

		pop ecx
		loop OUTTER

;--------------------------���������� ����� ������������ ���������-----------------------------------

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
		;�������� ���������
		mov eax, m
		imul eax, esi
		sub eax, esi
		add eax, edi
		sub eax, 1
		imul eax, 4
		mov ebx, [num+eax]
		add sum, ebx
	
		;������� ���������
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
		;��������� ������������ ��������
		mov esi, middl1
		mov eax, sum
		sub eax, [num+esi]
		mov sum, eax


	calc_end:
		
	
;--------------------------����� ����������-----------------------------------
                  
	xor ecx,ecx
	xor ebp,ebp
	xor esi,esi

                  ; ������� ������� � �������
                  invoke PrintStringToConsole, offset endl
                  invoke PrintStringToConsole, offset MatrixMsg

                  ; ���� �� �������
                  mov esi, 0
                  mov ecx, n
                  PRINTROW:
                    push ecx

                    ; ���� �� ��������
                    mov ecx, m
                    PRINTCOLUMN:
                        invoke PrintDwordToConsole, [num+esi]
                        invoke PrintStringToConsole, offset space
                    
                        ; ��������� �������
                        add esi, elsizeequ
                        loop PRINTCOLUMN

                    ; ��������� ������
                    invoke PrintStringToConsole, offset endl
                    pop ecx
                    loop PRINTROW

                  invoke PrintStringToConsole, offset endl

                  ; ������� ����� � �������
                  invoke PrintStringToConsole, offset ResultMsg
                  invoke PrintDwordToConsole, sum
            

;---------------------------�����--------------------------------------------
 INVOKE ExitProcess,0
 end    start 