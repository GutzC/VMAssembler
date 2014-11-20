 // Set Pointers to start procedure call
 
 MOV PFP FP			; PFP(R[13]) = FP(R[11])
 MOV FP SP			; FP (R[11]) = SP (R[10])
 
 // Determine Return address
 
 SUB SP THREE		; Adjust Stack Pointer for PFP (move up one instruction from current stack pointer)
 STR R3 SP			; Indirect - move PFP to top of Stack
 SUB SP THREE		; Adjust Stack Pointer for PFP (move up one instruction)
 MOV R1 R8			; Move PC into R1 to calculate return address
 ADI R1 9			; Add 9 to PC to point at instruction (move down three instructions)
 STR R1 FP			; Store return address at the instruction FP is pointing at
 JMP FP				; Jump to function
 TRP 0				; First statement after function call where we will return to