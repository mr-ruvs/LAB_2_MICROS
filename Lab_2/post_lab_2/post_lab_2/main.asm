//***************************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programación de Microcontroladores
// Autor: Ruben Granados
// Proyecto: post_lab_2
// Archivo: post_lab_2.asm
// Hardware: ATMEGA328P
// Created: 10/02/2024 
//***************************************************************************
.include "M328PDEF.inc"
.cseg
.org 0x00
//***************************************************************************
// Stack
LDI R16, LOW(RAMEND)
OUT SPL, R16
LDI R17, HIGH(RAMEND)
OUT SPH, R17
//***************************************************************************
// CONFIGURACION
//***************************************************************************

	T7S: .DB 0x3F, 0x06, 0x5B, 0x4F, 0X66, 0X6D, 0X7D, 0X07, 0X7F, 0X6F, 0X77, 0X7C, 0X39, 0X5E, 0X79, 0X71
SETUP:
	call Init_T0
	LDI R20, 0	// Contador de 10 mS
	ldi R19, 0					;	contador binario
	ldi R23, 0					;	alarma
	ldi R22, 15					;	tope sup
	ldi R24, 0					;	tope inf
	ldi R16, (1 << CLKPCE)
	sts CLKPR, R16				;	prescaler
	ldi R16, 0b0000_0111		; 
	sts CLKPR, R16				;				
;*********************************************************	   INPUTS
	ldi R16, 0b0000_0110
	out PORTB, R16				;input pullup
	ldi R16, 0b1111_1111
	out DDRD, R16				; OUTPUT
	ldi R16, 0b0111_1111
	out DDRC, R16				; output display
	ldi R18, 0					; T7S
	ldi R21, 0					; valor inicial
	ldi ZH, HIGH(T7S << 1)
	ldi ZL, LOW(T7S << 1)
	add ZL, R18
	lpm R18, Z
	
LOOP:
	sbrc R18, PC6
	sbi PIND, PD7
	out PORTC, R18
	cbi PORTD, PD7
	in R16, PINB
	sbrs R16, PB2				;	if bit = 1 ==> salta
	rjmp DB_1					;	verifica antirebote
	in R17, PINB
	sbrs R17, PB1
	rjmp DB_2
	in R16, TIFR0
	sbrs R16, OCF0A
	rjmp LOOP
	sbi TIFR0, OCF0A	; Apaga
	inc R20
	cpi R20, 1			; Se repite 1 veces el contador
	brne LOOP
	clr R20				; Se borra el contador
	sbi PINB, PB3
	cpse R19, R22		; if
	call LEDS			; si no llega a 15
	ldi R19, 0			; si llega a 15
	out PORTD, R19
	cpse R23, R24		;alarma
	sbi PORTD, PD6		;alarma
	rjmp LOOP

//**********************************************************		
DB_1:
	ldi R16, 100				;	espera el tiempo
	delay:
		dec R16
		brne delay
	;	lee el estado del botón despues del antirebote
	sbis PINB, PB2				;	salta si el bit es 1
	rjmp DB_1			;	repite verificación
	call AUMENTAR

DB_2:
	ldi R17, 100				;	espera el tiempo
	delay2:
		dec R17
		brne delay2
	sbis PINB, PB1				;	salta si el bit es 1
	rjmp DB_2			;	repite verificación
	call DECREMENTAR
	
AUMENTAR:
	cpse R21, R22 
	inc R21						; T7S
	mov R18, R21
	ldi ZH, HIGH(T7S << 1)
	ldi ZL, LOW(T7S << 1)
	add ZL, R18
	lpm R18, Z
	rjmp LOOP

DECREMENTAR:
	cpse R21, R24
	dec R21						; T7S
	mov R18, R21
	ldi ZH, HIGH(T7S << 1)
	ldi ZL, LOW(T7S << 1)
	add ZL, R18
	lpm R18, Z
	rjmp LOOP

LEDS: 
	inc R19
	lsl R19
	lsl R19
	out PORTD, R19		; muestra en binario
	cpse R23, R24		;alarma
	sbi PORTD, PD6		;alarma
	lsr R19
	lsr R19
	cpse R19, R21
	rjmp LOOP
	call ALARMA

Init_T0: 

	LDI R16, 0
	OUT TCNT0, R16
	LDI R16, 156
	OUT OCR0A, R16
	LDI R16, (1 << WGM01) ; 0b0000_0010 
	OUT TCCR0A, R16
	LDI R16, (1 << CS02)|(1 << CS00)
	OUT TCCR0B, R16
	RET

ALARMA:
	cpse R23, R24
	call APAGAR_ALARMA	; -=
	ldi R23, 15		;=
	sbi PORTD, PD6
	ldi R19, 15
	rjmp LOOP

APAGAR_ALARMA:
	ldi R23, 0
	ldi R19, 15
	rjmp LOOP