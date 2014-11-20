 // Make sure SP is set to one above current Activation Record
 // OVERFLOW
 MOV R5 SP			; Check for Overflow  -- Move stack pointer into R5
 LDR R2 TWO
 SUB R5 R2			; Subtract 2 from stack pointer to get MEM index where next instruction would be
 CMP R5 SL			; Check if index is valid
 BLT R5 OVERFLOW	; If invalid, branch to OVERFLOW
 JMP PASS1
OVERFLOW TRP 0		; OVERFLOW OCCURRED, EXIT PROGRAM
PASS1				; print "T" if no overflow occurred

 // UNDERFLOW
 
 MOV R5 SB			; Test for Underflow
 CMP R5 SP			; 
 BLT R5 OVERFLOW	; Exit program if UNDERFLOW occurred