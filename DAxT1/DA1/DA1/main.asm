;Code by: Andy Sam 



.DSEG
.EQU RAM_MIDDLE = 0x7FFF ; half of RAMEND
.EQU RAM_SOMEWHERE =  0x5555 
.EQU RAM_SOMEWHERE_ELSE = 0x3FFF / 4


.CSEG

.org 0


ldi ZL, LOW(RAM_MIDDLE)
out SPL, ZL
ldi ZH, HIGH(RAM_MIDDLE)
out SPH, ZH ;establish stack and pointer to be used

ldi YL, LOW(RAM_SOMEWHERE)
ldi YH, HIGH(RAM_SOMEWHERE)
ldi XL, LOW(RAM_SOMEWHERE_ELSE)
ldi XH, HIGH(RAM_SOMEWHERE_ELSE) ;set up multiple pointers to be used

ldi R25, 25 ;for counting initial loaded values


load_values: 	mov R16, R30 ;load low of Z to R16
				ld R20, Z+ ;increment Z address
		 		push R16 ;push low of Z to stack (or current address of Z in memory)
				dec R25 ; decrement counter R25
				brne load_values ; branch when counter R25 goes to 0


				ldi R16, 25 ;for counting off loaded values
				ldi R20, 0
				ldi R21, 0
				ldi R22, 0
				ldi R23, 0
				ldi R24, 0
				ldi R25, 0 ; Clears for registers to be used

repop:			pop R17 ; pop value of R17
				mov R18, R17 ; stores popped value for sevens check
				mov R19, R17 ; stores popped value for threes check
				rjmp s_check ; go to sevens check

returnto:		dec R16 ;decrement counter
				breq sevens_addition ;when counter goes to zero, go to addition
				rjmp repop ;loop back to pop stack until 0

s_check:		subi R18, 7 ;first subtracts 7 from popped value, then loop subract
				breq div_seven_yes ;if zero flag up, marked value as divisible by 7
				brmi t_check ;if negative flag, go to threes check
				rjmp s_check ;loop

t_check:		subi R19, 3;first subtracts 3 from popped value, then loop subtrac until neg or zero
				breq div_three_yes; if zero flag up, marked value as dvisible by 3 
				brmi returnto; if negative flag, go to popping counter decrement
				rjmp t_check ;loop

div_seven_yes:	inc R14 ;increment number of mults of sevens counter
				st Y+, R17 ;stores value to memory and increment Y pointer
				rjmp t_check

div_three_yes:	inc R15 ;increments number of mults of threes counter
				st X+, R17 ;stores value to memory and increment X pointer
				rjmp returnto

sevens_addition: ld  R25, -Y
				 add R20, R25
				 adc R21, R16 ; add R21 with 0 and carry
				 dec R14 ;decrement sevens counter
			     brne sevens_addition ; loop till no more mults of seven
			 	 rjmp threes_addition

threes_addition: ld R25, -X
				 add R22, R25
				 adc R23, R16 ; add R23 with 0 and carry
				 dec R15 ;decrement number of threes counter
				 brne threes_addition ; loop till no more mults of threes
end:		     rjmp end			;loop forever
