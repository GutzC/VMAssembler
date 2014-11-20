; WHILE LOOP SKELETON
 LDR R3 MAX		; MAX value to compare against
WHILE MOV R2 R1	; Beginning of while loop, load R2 with starting value - while (R2 < R3)
 CMP R2 R3		; Compare i with size, R2 will be 0 when equal
 BRZ R2 ENDWHILE ; Exit while loop if R2 == R3
 ; STATEMENTS OF WHILE LOOP BEGIN 			
 ADI R1 R2		; Increment i by 1
 JMP WHILE 		; Return to top of while
ENDWHILE

; WHILE LOOP SKELETON - ITERATING THROUGH AN ARRAY, while (i < SIZE), i = 0 to start 
 LDR R3 SIZE 	; Load size of array into R3
 SUB R1 R1		; Clear R1
 ADI R1 0		; Set R1 to zero
 ; while(r1 < r3)
WHILE MOV R2 R1	; Beginning of while loop, load R2 with current value of 'i'
 CMP R2 R3		; Compare i with size, R2 will be 0 when equal
 BRZ R2 ENDWHILE ; Exit while loop if i == SIZE
 ; BEGIN WHILE STATEMENTS
 SUB R7 R7		; R7 = Offset, clear register
 ADI R7 1		; Set R7 to 1  
 MUL R7	R1		; Offset = element size * i
 LDA R4 ARR		; Load base address into R4 *** Base address isn't being added 
 ADD R4 R7		; Add offset for current index address, R4 == memory location of current index
 ; Do what you want with data at this index
 ADI R1 1		; Increment i by 1
 ; END WHILE STATEMENTS
 JMP WHILE 			; Return to top of while
ENDWHILE