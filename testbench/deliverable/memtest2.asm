;
; Test: Move IREG to OREG at the specified memory adress
;   Note: due to randomized data, only reads in one value per address
;           this also removes the need for synchronization routines.
;

init:
    org     000
    JMP read_addr;
	ALIGN

read_addr:
    LOAD OREG, #4'hF; Put 0xF on the pins to indicate ready (sync)
    MOV I, IREG;    Read in the memory address then
    MOV OREG, I;    echo it the output to confirm
    jmp memcp;
    ALIGN

memcp:
	MOV	DM, IREG;	Move the pins to DM
    MOV	OREG, DM;   echo that data back out to pins
    JMP	read_addr;
	ALIGN
