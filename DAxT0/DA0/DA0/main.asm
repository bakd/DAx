;
; DA0.asm
;
; Created: 2/15/2016
; Author : Andy Sam
;




.include "m328pdef.inc"

	sbi DDRB, 2 ;set port b 2 as an output

	ldi r16, 55
	ldi r17, 57
	ldi r18, 58
	ldi r19, 52
	ldi r20, 59 ; "random" values set

	adc r16, r17
	adc r16, r18
	adc r16, r19
	adc r16, r20 ; addition of random values

	brvs H1 ; branch for overflow

	ldi r21, 0 
	out DDRB, r21
	rjmp H2

H1: ldi r21, 1 
	out DDRB, r21

H2:


