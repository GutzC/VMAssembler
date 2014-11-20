A .BYT 65		; 'A'
B .BYT 66		; 'B'
T .BYT 84		; 'T'
F .BYT 70		; 'F'
STBASE .INT 100000 ; Stack Base value
STLIM .INT 10000 ; Stack Limit value
ONE .INT 1 		; 1
TWO .INT 2		; 2
THREE .INT 3	; 3
NL .BYT 10		; '\n' 
START LDR SB STBASE		; Set Stack Limit based on size of program
 LDR SL STLIM  		; Set Stack Limit based on size of program
 LDR SP STBASE		; Set Stack Base to bottom of Stack to begin
 MOV FP SP
 MOV R5 SP			; Check for Overflow  -- Move stack pointer into R5
 LDR R2 TWO
 SUB R5 R2			; Subtract 2 from stack pointer to get MEM index where next instruction would be (after Return Address and PFP )saved
 CMP R5 SL			; Check if index is valid
 BLT R5 OVERFLOW	; If invalid, branch to OVERFLOW
 JMP NOOF1			; No Overflow, JMP over exit command
OVERFLOW TRP 0		; OVERFLOW OCCURRED, EXIT PROGRAM 
NOOF1 MOV PFP FP	; PFP(R[13]) = FP(R[11])	- Update stack pointers
 MOV FP SP			; FP (R[11]) = SP (R[10]) 	- Update stack pointers
 ADI SP -1			; Adjust Stack Pointer for Return address (move up one instruction from current stack pointer) // Determine Return address
 STR PFP SP			; Indirect - move PFP to top of Stack			
 ADI SP -1			; Adjust Stack Pointer for PFP (move up one instruction)
 MOV R1 R8			; Move PC into R1 to calculate return address
 ADI R1 12			; Add 9 to PC to point at return instruction (move down three instructions)
 STR R1 FP			; Store return address at the mem address FP is pointing at
 JMP F1				; Jump to function
 JMP AFTERF1		; First statement after function call where we will return to, may need to jump the function to continue
F1 MOV R5 SP		; FIRST LINE INSIDE F1 Function, check for Overflow, If (SP - Space needed for Local & Temp variables < SL) OVERFLOW OCCURRED			
 CMP R5 SL			; Check if index is valid
 BLT R5 OVERFLOW	; If invalid, branch to OVERFLOW
 LDB R0 T			; First actual instruction inside function after checking for Overflow
 TRP 3					
 MOV R5 SP			; Check for Overflow  -- Move stack pointer into R5  ; NESTED FUNCTION CALL
 LDR R2 TWO
 SUB R5 R2			; Subtract 2 from stack pointer to get MEM index where next instruction would be (after Return Address and PFP )saved
 CMP R5 SL			; Check if index is valid
 BLT R5 OVERFLOW	; If invalid, branch to OVERFLOW
 MOV PFP FP			; PFP(R[13]) = FP(R[11])	- Update stack pointers
 MOV FP SP			; FP (R[11]) = SP (R[10]) 	- Update stack pointers
 ADI SP -1			; Adjust Stack Pointer for Return address (move up one instruction from current stack pointer) // Determine Return address
 STR PFP SP			; Indirect - move PFP to top of Stack			
 ADI SP -1			; Adjust Stack Pointer for PFP (move up one instruction)
 MOV R1 R8			; Move PC into R1 to calculate return address
 ADI R1 12			; Add 9 to PC to point at return instruction (move down three instructions)
 STR R1 FP			; Store return address at the mem address FP is pointing at
 JMP F2				; Jump to function
 JMP AFTERF2		; First statement after function call where we will return to, may need to jump the function to continue
F2 MOV R5 SP		; FIRST LINE INSIDE F1 Function, check for Overflow, If (SP - Space needed for Local & Temp variables < SL) OVERFLOW OCCURRED			
 CMP R5 SL			; Check if index is valid
 BLT R5 OVERFLOW	; If invalid, branch to OVERFLOW
 LDB R0 F			; First actual instruction inside function after checking for Overflow
 TRP 3
 MOV SP FP 			; return(deallocate activation record)
 MOV FP PFP
 MOV R5 SB			; Test for Underflow
 CMP R5 SP			; 
 BLT R5 OVERFLOW	; Exit program if UNDERFLOW occurred
 LDR R5 FP			; Retrieve Return Address from Stack (if returning a value - add return value on the top of the stack after de-allocating the frame, do not adjust SP for return value)
 JMR R5				; Jump to Return Address -- END NESTED FUNCTION CALL
AFTERF2 MOV SP FP 	; return(deallocate activation record)
 MOV FP PFP
 MOV R5 SB			; Test for Underflow
 CMP R5 SP			; 
 BLT R5 OVERFLOW	; Exit program if UNDERFLOW occurred
 LDR R5 FP			; Retrieve Return Address from Stack (if returning a value - add return value on the top of the stack after de-allocating the frame, do not adjust SP for return value)
 JMR R5				; Jump to Return Address 
AFTERF1 LDB R0 T	; First statement after the jump after function call F1
 TRP 3				
 TRP 0