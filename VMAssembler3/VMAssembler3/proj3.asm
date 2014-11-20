STBASE .INT 100000 ; Stack Base value
STLIM .INT 10000 ; Stack Limit value
SIZE .INT 7
tenth .INT 0
ZERO .INT 0
c .BYT 0
 .BYT 0
 .BYT 0
 .BYT 0
 .BYT 0
 .BYT 0
 .BYT 0
cnt .INT 0
data .INT 0
flag .INT 0
opdv .INT 0
; Start main()
; Call reset(1,0,0,0)
START LDR SB STBASE		; Set Stack Limit based on size of program
 LDR SL STLIM  		; Set Stack Limit based on size of program
 LDR SP STBASE		; Set Stack Base to bottom of Stack to begin
 MOV FP SP			; Set FP to bottom of Stack to begin
 ; CHECK OVERFLOW - prior to call to reset(w,x,y,z)
 MOV R5 SP			; Check for Overflow  -- Move stack pointer into R5
 ADI R5 -2			; Subtract 2 from stack pointer to get MEM index where next instruction would be (after Return Address and PFP )saved
 ADI R5 -4			; Subtract 1*num_of_params to make sure there is space to call function  (-3 == three parameters)
 CMP R5 SL			; Check if index is valid
 BLT R5 OVERFLOW	; If invalid, branch to OVERFLOW
 ; NO OVERFLOW, continue
 JMP NOOF1			; No Overflow, JMP over exit command
OVERFLOW TRP 0		; OVERFLOW OCCURRED, EXIT PROGRAM 
 ; UPDATE STACK POINTERS
NOOF1 MOV PFP FP	; PFP(R[13]) = FP(R[11])	- Update stack pointers
 MOV FP SP			; FP (R[11]) = SP (R[10]) 	- Update stack pointers
 ADI SP -1			; Adjust Stack Pointer for Return address (move up one instruction from current stack pointer) // Determine Return address
 ; ADD PFP TO STACK
 STR PFP SP			; Indirect - move PFP to top of Stack			
 ADI SP -1			; Adjust Stack Pointer for PFP (move up one instruction)
 ; ADD PARAMETERS TO STACK
 ADI SP 0			; Adjust Stack Pointer for PARAMETERS (-1 for each parameter, other than the first)
 LDR R5 ZERO		; ADD 1ST PARAMETER to top of stack
 ADI R5 0			; Set z value = 0
 STR R5 SP			; Store value in R5 to top of stack
 ADI SP -1			; Increment SP
 LDR R5 ZERO		; ADD 2ND PARAMETER to top of stack
 ADI R5 0			; Set x value = 0
 STR R5 SP
 ADI SP -1			
 LDR R5 ZERO		; ADD 3RD PARAMETER to top of stack
 ADI R5 0			; Set y value = 0
 STR R5 SP
 ADI SP -1	
 LDR R5 ZERO		; ADD 4TH PARAMETER to top of stack
 ADI R5 1			; Set w value = 1
 STR R5 SP
 ADI SP -1
 ; DONE ADDING PARAMETERS TO STACK
 ; CALCULATE RETURN ADDRESS
 MOV R1 R8			; Move PC into R1 to calculate return address
 ADI R1 12			; Add 12 to PC to point at return instruction (move down necessary instructions)
 ; ADD RETURN ADDRESS TO FP
 STR R1 FP			; Store return address at the mem address FP is pointing at
 ; GOTO FUNCTION
 JMP F1				; Jump to function
 JMP AFTERF1		; First statement after function call where we will return to, may need to jump the function to continue
; FIRST STATEMENT IN reset(w,x,y,z) - calculate space including local variables
; CHECK FOR OVERFLOW
F1 MOV R5 SP		; FIRST LINE INSIDE F1 Function, check for Overflow, If (SP - Space needed for Local & Temp variables < SL) OVERFLOW OCCURRED	
 ADI R5 -1			; 1 local var, subtract one from SP to check for space		
 CMP R5 SL			; Check if index is valid
 BLT R5 OVERFLOW	; If invalid, branch to OVERFLOW
 ; NO OVERFLOW, EXECUTE FUNCTION
 ; First actual instruction inside function after checking for Overflow
 ; Set temp value, k, to 0
 ; while (k < SIZE) {c[k] = 0; k++;}
 LDR R3 SIZE 	; Load size of array into R3
 MOV R5 FP		; Load FP into R5 for base (to store 'i' in temp variable on stack)
 ADI R5 -6		; Get local variable position on stack
 LDR R6 ZERO	; Load 0 into R6
 STR R6 R5		; Set mem[R5] to zero
 ; while(r6 < r3)
WHILE MOV R2 R6	; Beginning of while loop, load R2 with current value of 'i' from R6
 CMP R2 R3		; Compare i with size, R2 will be 0 when equal
 BRZ R2 ENDWHILE ; Exit while loop if i == SIZE
 ; BEGIN WHILE STATEMENTS
 SUB R7 R7		; R7 = Offset, clear register
 ADI R7 1		; Set R7 to 1  
 MUL R7	R6		; Offset = element size * i
 LDA R4 c		; Load base address into R4
 ADD R4 R7		; Add offset for current index address, R4 == memory location of current index
 ; Do what you want with data at this index
 LDR R2 ZERO	; Store zero in R2
 STR R2 R4		; Set c[k] to zero
 ; Get local variable value from stack, increment by 1, and store back in local variable on stack
 MOV R5 FP		; Load FP into R5 for base (to store 'i' in temp variable on stack)
 ADI R5 -6		; Get local variable position on stack
 LDR R6 R5		; Load 0 into R6
 ADI R6 1		; increment R6
 STR R6 R5		; Set mem[R5] to value in R6 
 ; END WHILE STATEMENTS
 JMP WHILE 			; Return to top of while
ENDWHILE MOV R5 FP	; Load FP into R5 for base
 ADI R5 -2			; GET z - 1ST PARAMETER (base - 2)
 LDR R5 R5			; Move value to R0 and print	
 STR R5 flag
 MOV R0 R5
 TRP 1 
 MOV R5 FP			; Load FP into R5 for base
 ADI R5 -3			; GET y - 2ND PARAMETER (base - 3)
 LDR R5 R5			; Move value to R0 and print	
 STR R5 cnt
 MOV R0 R5
 TRP 1 
 MOV R5 FP			; Load FP into R5 for base
 ADI R5 -4			; GET x - 3RD PARAMETER (base - 4)
 LDR R5 R5			; Move value to R0 and print	
 STR R5 opdv
 MOV R0 R5
 TRP 1 
 MOV R5 FP			; Load FP into R5 for base
 ADI R5 -5			; GET w - 4TH PARAMETER (base - 5)
 LDR R5 R5			; Move value to R0 and print	
 STR R5 data
 MOV R0 R5
 TRP 1 
 MOV SP FP 			; return(deallocate activation record)
 MOV FP PFP
 MOV R5 SB			; Test for Underflow
 CMP R5 SP			; 
 BLT R5 OVERFLOW	; Exit program if UNDERFLOW occurred
 LDR R5 FP			; Retrieve Return Address from Stack (if returning a value - add return value on the top of the stack after de-allocating the frame, do not adjust SP for return value)
 JMR R5				; Jump to Return Address 
 ; END reset(1,0,0,0)
 ; START getdata();
AFTERF1 MOV R5 SP	; Check for Overflow  -- Move stack pointer into R5
 ADI R5 -2			; Subtract 2 from stack pointer to get MEM index where next instruction would be (after Return Address and PFP )saved
 ADI R5 0			; Subtract 1*num_of_params to make sure there is space to call function
 CMP R5 SL			; Check if index is valid
 BLT R5 OVERFLOW	; If invalid, branch to OVERFLOW and exit
 ; No Overflow, continue
 MOV PFP FP			; PFP(R[13]) = FP(R[11])	- Update stack pointers
 MOV FP SP			; FP (R[11]) = SP (R[10]) 	- Update stack pointers
 ADI SP -1			; Adjust Stack Pointer for Return address (move up one instruction from current stack pointer) // Determine Return address
 STR PFP SP			; Indirect - move PFP to top of Stack			
 ADI SP -1			; Adjust Stack Pointer for PFP (move up one instruction)
 ADI SP 0			; Adjust Stack Pointer for parameters (0 if no parameters)
 MOV R1 R8			; Move PC into R1 to calculate return address
 ADI R1 12			; Add 12 to PC to point at return instruction (move down three instructions)
 STR R1 FP			; Store return address at the mem address FP is pointing at
 JMP F2				; Jump to function
 JMP AFTERF2		; First statement after function call where we will return to, may need to jump the function to continue
F2 MOV R5 SP		; FIRST LINE INSIDE F1 Function, check for Overflow, If (SP - Space needed for Local & Temp variables < SL) OVERFLOW OCCURRED			
 CMP R5 SL			; Check if index is valid
 BLT R5 OVERFLOW	; If invalid, branch to OVERFLOW
 ; No Overflow, begin function statements 
 ; First actual instruction inside function after checking for Overflow
 ; if (cnt < SIZE)
 LDR R6 cnt
 LDR R4 SIZE
 CMP R6 R4		; IF(R6 != R4)
 BRZ R6 ELSE	; Jump to ELSE if compare true
 ; IF STATEMENTS BEGIN
	; c[cnt] = getchar();
 TRP 4			; Get character from std in
 LDR R6 cnt		; Load value of cnt into R6 (index number)
 LDA R4 c		; Load base address into R4
 ADD R4 R6		; Add offset for current index address, R4 == memory location of current index
 STR R4 R0		; Store value read from standard in to c[cnt] 
 ADI R6 1		; increment cnt
 STR R6 cnt	 
 ; END IF STATEMENTS
 JMP ENDIF		; Skip ELSE statements since we processed IF statements
ELSE TRP 0
 ; ELSE STATEMENTS BEGIN
	; print out "Number too Big\n"
	; call flush()
 ; END ELSE STATEMENTS			
ENDIF TRP 0 
 ; End function statements, deallocate activation record
 MOV SP FP 			; return(deallocate activation record)
 MOV FP PFP
 MOV R5 SB			; Test for Underflow
 CMP R5 SP			; 
 BLT R5 OVERFLOW	; Exit program if UNDERFLOW occurred
 LDR R5 FP			; Retrieve Return Address from Stack (if returning a value - add return value on the top of the stack after de-allocating the frame, do not adjust SP for return value)
 JMR R5				; Jump to Return Address 
AFTERF2 LDB R0 T	; First statement after the jump after function call F1
 TRP 3				
 TRP 0 
; JUST FINISHED ENTERING IF in getdata()
; Trying to test whether it is stepping through the array values properly and trying to get it to read in characters
; for each index in c[] ... TRP 4 on line 164 is never reached, however. Step through the if statement to see why
; Lines 158 - 177