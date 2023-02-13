; --- Mapeamento de Hardware (8051) ---
RS equ P1.3 ;Reg Select ligado em P1.3
EN equ P1.2 ;Enable ligado em P1.2
org 0000h
LJMP START
org 0003h
; Sub-rotina responsável por ligar o motor.
; Tendo como parâmetro o R7, caso seja #0h, entra nessa sub-rotina, ligando
;o motor.
; Caso seja #1, pula para a sub-rotina que desliga o motor.
LIGAMOTOR:
INC R7
CJNE R7,#01h,ACABOUAGASOLINA
ACALL IMPRIME
CLR P3.1 ;?
SETB P3.0;?Liga o motor
RETI
org 00013h
GASOLINA:;41 - 4E
ACALL lcd_init
mov A, #41h
MOV R6, #0EH
ACALL posicionaCursor
; Sub-rotina responsável por abastecer o tanque completamente.
ENCHER:
MOV A, #00101110b ;ou #'#'
ACALL sendCharacter
DJNZ R6,ENCHER
MOV R6, #0EH
MOV R4, #4EH
 ; Após preencher todos os níveis, imprime 100% para a gasolina.
MOV A, #0Ch
ACALL posicionaCursor
MOV A, #'1'
ACALL sendCharacter ;
MOV A, #'0'
ACALL sendCharacter ;
MOV A, #'0'
ACALL sendCharacter ;
MOV A, #'%'
ACALL sendCharacter ;
SETB EX0 ;Habilita a interrupção 0
SETB IT0 ;Trabalhando com borda de descida
RETI
org 040h
; Sub-rotina responsável por desligar o motor,
; saltar para sub-rotina que imprime motor OFF
; e voltar para a sub-rotina de loop.
ACABOUAGASOLINA:
ACALL DESLIGADO
CLR P3.0
CLR P3.1
MOV R7,#00h
SJMP PRESO
RET
; Sub-rotina para qual o programa salta inicialmente.
START:
MOV R4, #00H
MOV R6, #00H
MOV R7,#00H
MOV TMOD, #01100000b
SETB EA
SETB TR1
SETB P3.0
SETB EA ;Habilita as interrupções
SETB EX1
SETB IT1
SETB IT0 ;Trabalhando com borda de descida
ACALL DESLIGADO
; Sub-rotina de loop, servindo para checar constantemente os registradores
;e as interrupções externas.
PRESO:
NOP
CJNE R7,#00h,LOOP
SJMP PRESO
; Sub-rotina de loop, servindo para checar constantemente os registradores
;e as interrupções externas.
LOOP:
MOV a, tl1
MOV b, #35h
DIV ab
MOV a,b
JZ GASTEI
CJNE R4,#40h,LOOP
MOV R7,#00H
ACALL ACABOUAGASOLINA
sjmp PRESO;
; Sub-rotina responsável por decrementar o nível de gasolina conforme os
;giros do motor.
GASTEI:
ACALL NIVEL
MOV A,R4
ACALL posicionaCursor
DEC a
MOV R4,a
MOV A, #' '
ACALL sendCharacter ;
SJMP loop
; Sub-rotina responsável por fazer a verificação do nível de gasolina
; usando como parâmetro a posição do cursor.
NIVEL:
MOV a, R4
MOV b, #4EH
DIV ab
MOV a,b
JZ CEM
MOV a, R4
MOV b, #4BH
DIV ab
MOV a,b
JZ SETE
MOV a, R4
MOV b, #47H
DIV ab
MOV a,b
JZ CINQ
MOV a, R4
MOV b, #44H
DIV ab
MOV a,b
JZ VINTE
MOV a, R4
MOV b, #41H
DIV ab
MOV a,b
JZ ZERO
VOLTA:
RET
 ; Sub-rotinas que imprimem no display o nível relativo de gasolina.
CEM:
ACALL lcd_init
MOV A, #0Ch
ACALL posicionaCursor
MOV A, #'1'
ACALL sendCharacter ;
MOV A, #'0'
ACALL sendCharacter ;
MOV A, #'0'
ACALL sendCharacter ;
MOV A, #'%'
ACALL sendCharacter ;
LJMP VOLTA;
SETE:
ACALL lcd_init
MOV A, #0Ch
ACALL posicionaCursor
MOV A, #' '
ACALL sendCharacter ;
MOV A, #'7'
ACALL sendCharacter ;
MOV A, #'5'
ACALL sendCharacter ;
MOV A, #'%'
ACALL sendCharacter ;
 LJMP VOLTA;
CINQ:
ACALL lcd_init
MOV A, #0Ch
ACALL posicionaCursor
MOV A, #' '
ACALL sendCharacter ;
MOV A, #'5'
ACALL sendCharacter ;
MOV A, #'0'
ACALL sendCharacter ;
MOV A, #'%'
ACALL sendCharacter ;
 LJMP VOLTA;
VINTE:
ACALL lcd_init
MOV A, #0Ch
ACALL posicionaCursor
MOV A, #' '
ACALL sendCharacter ;
MOV A, #'2'
ACALL sendCharacter ;
MOV A, #'5'
ACALL sendCharacter ;
MOV A, #'%'
ACALL sendCharacter ;
 LJMP VOLTA;
ZERO:
ACALL lcd_init
MOV A, #0Ch
ACALL posicionaCursor
MOV A, #' '
ACALL sendCharacter ;
MOV A, #' '
ACALL sendCharacter ;
MOV A, #'0'
ACALL sendCharacter ;
MOV A, #'%'
ACALL sendCharacter ;
LJMP VOLTA;
; Sub-rotina responsável por atualizar o status do motor para ligado 'ON'.
IMPRIME:
ACALL lcd_init
MOV A, #00h
ACALL posicionaCursor
MOV A, #'M'
ACALL sendCharacter ;
MOV A, #'O'
ACALL sendCharacter ;
MOV A, #'T'
ACALL sendCharacter ;
MOV A, #'O'
ACALL sendCharacter ;
MOV A, #'R'
ACALL sendCharacter ;
MOV A, #' '
ACALL sendCharacter ;
MOV A, #'O'
ACALL sendCharacter ;
MOV A, #'N'
ACALL sendCharacter ;
MOV A, #' '
ACALL sendCharacter ;
MOV A, #' '
ACALL sendCharacter ;
MOV A, #'G'
ACALL sendCharacter ;
MOV A, #' '
ACALL sendCharacter ;
mov A, #40h
ACALL posicionaCursor
MOV A, #'E'
ACALL sendCharacter ;
mov A, #4Fh
ACALL posicionaCursor
MOV A, #'F'
ACALL sendCharacter ;
RET;
; Sub-rotina responsável por atualizar o status do motor para desligado
;'OFF'.
DESLIGADO:
acall lcd_init
mov A, #00h
ACALL posicionaCursor
MOV A, #'M'
ACALL sendCharacter ;
MOV A, #'O'
ACALL sendCharacter ;
MOV A, #'T'
ACALL sendCharacter ;
MOV A, #'O'
ACALL sendCharacter ;
MOV A, #'R'
ACALL sendCharacter ;
MOV A, #' '
ACALL sendCharacter ;
MOV A, #'O'
ACALL sendCharacter ;
MOV A, #'F'
ACALL sendCharacter ;
MOV A, #'F'
ACALL sendCharacter ;
MOV A, #' '
ACALL sendCharacter ;
MOV A, #'G'
ACALL sendCharacter ;
mov A, #40h
ACALL posicionaCursor
MOV A, #'E'
ACALL sendCharacter ;
mov A, #4Fh
ACALL posicionaCursor
MOV A, #'F'
ACALL sendCharacter ;
RETI;
; Abaixo, estão as funções responsáveis pelo funcionamento básico do
;Display.
; initialise the display
; see instruction set for details
lcd_init:
CLR RS ; clear RS - indicates that instructions are being
; function set
CLR P1.7 ; |
CLR P1.6 ; |
SETB P1.5 ; |
CLR P1.4 ; | high nibble set
SETB EN ; |
CLR EN ; | negative edge on E
CALL delay ; wait for BF to clear
; function set sent for first time -
; Why is function set high nibble sent twice? See 4-bit operation on pages
SETB EN ; |
CLR EN ; | negative edge on E
; same function set high nibble sent
SETB P1.7 ; low nibble set (only P1.7 needed to be
SETB EN ; |
CLR EN ; | negative edge on E
; function set low nibble sent
CALL delay ; wait for BF to clear
; entry mode set
; set to increment with no shift
CLR P1.7 ; |
CLR P1.6 ; |
CLR P1.5 ; |
CLR P1.4 ; | high nibble set
SETB EN ; |
CLR EN ; | negative edge on E
SETB P1.6 ; |
SETB P1.5 ; |low nibble set
SETB EN ; |
CLR EN ; | negative edge on E
CALL delay ; wait for BF to clear
CLR P1.7 ; |
CLR P1.6 ; |
CLR P1.5 ; |
CLR P1.4 ; | high nibble set
SETB EN ; |
CLR EN ; | negative edge on E
SETB P1.7 ; |
SETB P1.6 ; |
SETB P1.5 ; |
SETB P1.4 ; | low nibble set
SETB EN ; |
CLR EN ; | negative edge on E
CALL delay ; wait for BF to clear
RET
sendCharacter:
SETB RS ; setb RS - indicates that data is being
MOV C, ACC.7 ; |
MOV P1.7, C ; |
MOV C, ACC.6 ; |
MOV P1.6, C ; |
MOV C, ACC.5 ; |
MOV P1.5, C ; |
MOV C, ACC.4 ; |
MOV P1.4, C ; | high nibble set
SETB EN ; |
CLR EN ; | negative edge on E
MOV C, ACC.3 ; |
MOV P1.7, C ; |
MOV C, ACC.2 ; |
MOV P1.6, C ; |
MOV C, ACC.1 ; |
MOV P1.5, C ; |
MOV C, ACC.0 ; |
MOV P1.4, C ; | low nibble set
SETB EN ; |
CLR EN ; | negative edge on E
CALL delay ; wait for BF to clear
RET
;Posiciona o cursor na linha e coluna desejada.
;Escreva no Acumulador o valor de endereço da linha e coluna.
posicionaCursor:
CLR RS ; clear RS - indicates that instruction is being
SETB P1.7 ; |
MOV C, ACC.6 ; |
MOV P1.6, C ; |
MOV C, ACC.5 ; |
MOV P1.5, C ; |
MOV C, ACC.4 ; |
MOV P1.4, C ; | high nibble set
SETB EN ; |
CLR EN ; | negative edge on E
MOV C, ACC.3 ; |
MOV P1.7, C ; |
MOV C, ACC.2 ; |
MOV P1.6, C ; |
MOV C, ACC.1 ; |
MOV P1.5, C ; |
MOV C, ACC.0 ; |
MOV P1.4, C ; | low nibble set
SETB EN ; |
CLR EN ; | negative edge on E
CALL delay ; wait for BF to clear
RET
;Retorna o cursor para primeira posição sem limpar o display
retornaCursor:
CLR RS ; clear RS - indicates that instruction is being sent
CLR P1.7 ; |
CLR P1.6 ; |
CLR P1.5 ; |
CLR P1.4 ; | high nibble set
SETB EN ; |
CLR EN ; | negative edge on E
CLR P1.7 ; |
CLR P1.6 ; |
SETB P1.5 ; |
SETB P1.4 ; | low nibble set
SETB EN ; |
CLR EN ; | negative edge on E
CALL delay ; wait for BF to clear
RET
;Limpa o display
clearDisplay:
CLR RS ; clear RS - indicates that instruction is being sent
CLR P1.7 ; |
CLR P1.6 ; |
CLR P1.5 ; |
CLR P1.4 ; | high nibble set
SETB EN ; |
CLR EN ; | negative edge on E
CLR P1.7 ; |
CLR P1.6 ; |
CLR P1.5 ; |
SETB P1.4 ; | low nibble set
SETB EN ; |
CLR EN ; | negative edge on E
CALL delay ; wait for BF to clear
RET
delay:
MOV R0, #50
DJNZ R0, $
RET