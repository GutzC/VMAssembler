A .BYT 65		; 'A'
B .BYT 66		; 'B'
T .BYT 84		; 'T'
F .BYT 70		; 'F'
STBASE .INT 100000 ; Stack Base value
STLIM .INT 10000 ; Stack Limit value
ONE .INT 1 		; 1
THREE .INT 3	; 3
NL .BYT 10		; '\n' 
START LDR SB STBASE		; Set Stack Limit based on size of program
 LDR SL STLIM  		; Set Stack Limit based on size of program
 LDR SP STBASE		; Set Stack Base to bottom of Stack to begin
 MOV FP SP			; Set FP to bottom of Stack to begin
 MOV R5 SP			; Check for Overflow  -- Move stack pointer into R5
 ADI R5 -2			; Subtract 2 from stack pointer to get MEM index where next instruction would be (after Return Address and PFP )saved
 ADI R5 -1			; Subtract 1*num_of_params to make sure there is space to call function  (-3 == three parameters)
 CMP R5 SL			; Check if index is valid
 BLT R5 OVERFLOW	; If invalid, branch to OVERFLOW
 JMP NOOF1			; No Overflow, JMP over exit command
OVERFLOW TRP 0		; OVERFLOW OCCURRED, EXIT PROGRAM 
NOOF1 MOV PFP FP	; PFP(R[13]) = FP(R[11])	- Update stack pointers
 MOV FP SP			; FP (R[11]) = SP (R[10]) 	- Update stack pointers
 LDR R4 ONE			; Load value into R4 for incrementing MEM addresses
 ADI SP -1			; Adjust Stack Pointer for Return address (move up one instruction from current stack pointer) // Determine Return address
 STR PFP SP			; Indirect - move PFP to top of Stack			
 ADI SP -1			; Adjust Stack Pointer for PFP (move up one instruction)
 ADI SP 0			; Adjust Stack Pointer for PARAMETERS (1*num_of_params)
 LDR R5 THREE		; ADD 1ST PARAMETER to top of stack
 STR R5 SP			; Store value in R5 to top of stack
 ADI SP -1			; Increment SP
 LDR R5 STLIM		; ADD 2ND PARAMETER to top of stack
 STR R5 SP
 ADI SP -1			
 LDR R5 ONE			; ADD 3RD PARAMETER to top of stack
 STR R5 SP
 ADI SP -1			
 MOV R1 R8			; Move PC into R1 to calculate return address
 ADI R1 12			; Add 9 to PC to point at return instruction (move down three instructions)
 STR R1 FP			; Store return address at the mem address FP is pointing at
 JMP F1				; Jump to function
 JMP AFTERF1		; First statement after function call where we will return to, may need to jump the function to continue
F1 MOV R5 SP		; FIRST LINE INSIDE F1 Function, check for Overflow, If (SP - Space needed for Local & Temp variables < SL) OVERFLOW OCCURRED			
 CMP R5 SL			; Check if index is valid
 BLT R5 OVERFLOW	; If invalid, branch to OVERFLOW
 ; First actual instruction inside function after checking for Overflow
 MOV R5 FP			; Load FP into R5 for base
 ADI R5 -2			; GET 1ST PARAMETER (base - 2)
 LDR R5 R5			; Move value to R0 and print	
 MOV R0 R5
 TRP 1 
; MOV R5 FP			; Load FP into R5 for base
; ADI R5 -3			; GET 2ND PARAMETER (base - 3)
; LDR R5 R5			; Move value to R0 and print	
; MOV R0 R5
; TRP 1 
; MOV R5 FP			; Load FP into R5 for base
; ADI R5 -4			; GET 3RD PARAMETER (base - 4)
; LDR R5 R5			; Move value to R0 and print	
; MOV R0 R5
; TRP 1 
 MOV SP FP 			; return(deallocate activation record)
 MOV FP PFP
 MOV R5 SB			; Test for Underflow
 CMP R5 SP			; 
 BLT R5 OVERFLOW	; Exit program if UNDERFLOW occurred
 LDR R5 FP			; Retrieve Return Address from Stack (if returning a value - add return value on the top of the stack after de-allocating the frame, do not adjust SP for return value)
 JMR R5				; Jump to Return Address 
AFTERF1 LDB R0 T	; First statement after the jump after function call F1
 TRP 3				
 TRP 0