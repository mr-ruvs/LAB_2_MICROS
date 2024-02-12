//***************************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programación de Microcontroladores
// Autor: Ruben Granados
// Proyecto: prelab
// Archivo: prelab.asm
// Hardware: ATMEGA328P
// Created: 06/02/2024 
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
/*
Setup:
	
	CALL Init_T0
	ldi R17, 0b0111_1111
	out DDRD, R17
	ldi R17, 0b0000_1001
	out DDRB, R17
	LDI R20, 0	// Contador de 10 mS
	ldi R19, 0		//contador
	ldi R21, 15


LOOP:
	IN R16, TIFR0
	;CPI R16, (1 << CS02)
	SBRS R16, OCF0A
	RJMP LOOP
	
	SBI TIFR0, OCF0A	; Apaga

	INC R20
	CPI R20, 10			; Se repite 10 veces el contador de 10 mS para alcanzar los 100 mS de las instrucciones
	BRNE LOOP
	CLR R20				; Se borra el contador
	sbi PINB, PB3
	lsr R19
	lsr R19
	cpse R19, R21		; if
	call LEDS			; si no llega a 15
	ldi R19, 0			; si llega a 15
	out PORTD, R19
	rjmp LOOP
	

LEDS:
	inc R19
	lsl R19
	lsl R19
	out PORTD, R19		; muestra en binario
	rjmp LOOP

//************************
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
	*/

	T7S: .DB 0x00, 0x10, 0x20, 0x30, 0
Setup:
	ldi R16, 1
	ldi ZH, HIGH(T7S <<1)
	ldi ZL, LOW(T7S <<1)
	add ZL, R16
	lpm R16, Z

LOOP:
	rjmp LOOP
