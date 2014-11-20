A .BYT 65		; 'A'
B .BYT 66		; 'B'
T .BYT 84		; 'T'
F .BYT 70		; 'F'
ONE .INT 1 		; 1
TWO .INT 2		; 2
NL .BYT 10		; '\n' 
START LDB R6 A
 LDB R4 A
 CMP R6 R4		; IF(R6 == R4)
 BNZ R6 ELSE	; Jump to ELSE if compare false
 LDB R0 T		; print "T" if R6 == R4 - IF STATEMENTS BEGIN
 TRP 4			; getch() and store in R[0]
 TRP 1
 JMP ENDIF		; Skip ELSE statements since we processed IF statements
ELSE LDB R0 F	; ELSE print "F" if R6 != R4 - ELSE STATEMENTS
 TRP 3			; End If-Else statement			
ENDIF LDB R0 NL
 TRP 3