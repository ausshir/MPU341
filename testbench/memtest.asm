;
; Test: Move from IREG to OREG for all
;	addresses in the Data Memory
;
init:
        org     000
	LOAD 	X0, #4'HF;	Memory address counter
	LOAD	Y0, #4'H1;	Sub-1 register
	LOAD	I,  #4'HF; 	Set memory address to 15
	MOV	OREG, I;	Output addr OREG to indicate ready.
	JMP	wait;	
	ALIGN

memcp:
	MOV	DM, IREG;	Move the pins to DM
	MOV	OREG, DM;	Move that data back out to pins
	SUB	X0, Y0;		Count from 16 to 0
	MOV	X0, R;				
	JNZ	memcp;		Read another value if not zero
	MOV	DM, IREG;	Do move for 0'th address
	MOV	OREG, DM;	
	JMP	inc_i;		Finally jump to another mem addr
	ALIGN

memcp_last:
	MOV	DM, IREG;	
	MOV	OREG, DM;	
	SUB	X0, Y0;		
	MOV	X0, R;				
	JNZ	memcp;		
	MOV	DM, IREG;	
	MOV	OREG, DM;	
	JMP	halt;		Finally jump to the end
	ALIGN
	

inc_i:	
	MOV	X1, I;	
	SUB	X1, Y0;		Decrement the memory index
	MOV	I, R;
	MOV	OREG, I;
	JNZ	wait;
	JMP	memcp_last;		
        ALIGN

wait:
	MOV Y1, IREG;		Move data into X and Y
	MOV X1, IREG;		sequentially
	SUB X1, Y1;		Subtract the data (check if same)
	JNZ wait;		If it is zero, keep waiting
	JMP memcp;		Otherwise, start reading new data
	ALIGN
	

halt:
        jmp     halt;
