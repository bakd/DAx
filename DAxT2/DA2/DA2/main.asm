; Coded by: Andy Sam

.org 0x0000
	rjmp RESET
.org 0x001A 
	jmp INTSUB ; interrupt vector for TIMER/COUNTER1 Overflow


.macro STACKSTART ;stack macro
			LDI R16, HIGH(RAMEND)
			OUT SPH, R16
			LDI	R16, LOW(RAMEND)
			OUT SPL, R16
.endmacro

RESET:	
			STACKSTART ;initialize stack macro
			LDI R16, 0xFF
			STS DDRB, R16 ; set all PORTB to output
			LDI R16, 0x61
			STS DDRC, R16 ; set  PORTC.0, PORTC.5, PORTC.6 to OUTPUT

			LDI R16, 0x01
			STS TIMSK1, R16 ; enable TIMER1 overflow interupt

			LDI R16, 0
			OUT PORTB, R16 ; output PORTB
			LDI R16, 0
			OUT PORTC, R16 ; output PORTC
			
			LDI R17, 1 ; HIGH/LOW edge counter, set to 1 for first HIGH EDGE

			SEI ; global interrupt 

			
MAIN:		RCALL DELAY ;begin delay
			RJMP MAIN

INTSUB:
			IN R24, SREG
			PUSH R24 ; stores SREG
			
			INC R17 ; increment edge counter
			CPI R17, 2 ; HIGHEDGE = 2, LOWEDGE = 1
			BREQ HIGHEDGE ; branch to counts on high edge
HEDGEDONE:
			POP R24
			OUT SREG, R24
			

			RETI ; finished subroutine

HIGHEDGE:	
			LDI R17, 0 ; clear edge counter
			INC R18 ; increment PORTB number of rising edge counts
			OUT PORTB, R18 ; output number of rising edge counts
		
			INC R19 ; increment to count number of edges count for 5
			CPI R19, 5 
			BREQ CFIVE ; if on 5th count branch
HIGHEDGERET1:
			INC R20 ; increment to count number of edges for 10
			CPI R20, 10
			BREQ CTEN ; if on 10th count branch
HIGHEDGERET2:
			RJMP HEDGEDONE ; go back to finish subroutine


CFIVE:
			LDI R19, 0 ; clear fives counter
			SBIS PORTC, 5 ; if PORTC.5 is set skip rjmp
			RJMP C5SKIP1
			CBI PORTC, 5 ; clear bit PORTC.5 if it was set before
			RJMP C5SKIP2
C5SKIP1:	SBI PORTC, 5 ; set bit PORTC.5 if it was clear before
C5SKIP2:	RJMP HIGHEDGERET1 ; return


CTEN:
			LDI R20, 0 ; clear tens counter
			SBIS PORTC, 6 ; if PORTC.6 is set skip rjmp
			RJMP C10SKIP1
			CBI PORTC, 6 ; clear bit PORTC.6 if it was set before
			RJMP C10SKIP2
C10SKIP1:	SBI PORTC, 5 ; set bit PORTC.6 if it was clear before
C10SKIP2:	RJMP HIGHEDGERET2 ; return




DELAY:
			LDI R16, 0xF8
			STS TCNT1H, R16
			LDI R16, 0x5F
			STS TCNT1L, R16 ; 65536 - 1953 =  63583, timer value for .25 seconds using 1024 prescaler
			LDI R16, 0x00
			STS TCCR1A, R16
			LDI R16, 0x05
			STS TCCR1B, R16 ; normal mode, 1024 prescaler
			
WAIT:		sbis TIFR1, TOV1
			rjmp wait

			LDI R16, 0x00
			STS TCCR1B, R16 ; timer stop
			LDI R16, 0x01
			STS TIFR1, R16 ; clear TOV1 flag
			RET

