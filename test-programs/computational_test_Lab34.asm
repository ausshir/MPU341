	ORG 00
	LOAD x0,#4'H0 ;x0 = 0
	LOAD x1,#4'H0 ;x1 = 0
	LOAD y0,#4'H0 ;y0 = 0
	LOAD y1,#4'H0 ;y1 = 0
	LOAD oreg,#4'H0 ;oreg = 0
	LOAD m,#4'H1 ;m = 1
	LOAD i,#4'H0 ;i = 0
	MOV x0,ireg ;x0 = ireg
	MOV x1,x0 ;x1 = x0
	MOV x0,ireg ;x0 = ireg
	MOV y0,x1 ;y0 = x1
    SUB x1,y0 ;r = x1 - y0
    JNZ error ;if difference is not 0, jump to error
	MOV x1,x0 ;x1 = x0
	MOV y1,y0 ;y1 = y0
	MOV y0,x1 ;y0 = x1
    SUB x1,y0 ;r = x1 - y0
    JNZ error ;if difference is not 0, jump to error

; re-initialize everything for i_loop
	LOAD x0,#4'H1 ;x0 = 1
	LOAD x1,#4'H0 ;x1 = 0
	LOAD y0,#4'H4 ;y0 = 4
	LOAD y1,#4'H0 ;y1 = 0
	LOAD oreg,#4'H0 ;oreg = 0
	LOAD m,#4'H1 ;m = 1
	LOAD i,#4'H0 ;i = 0
    JMP iloop ;jump to iloop

    ALIGN
iloop:
    MOV dm,y0 ;dm = y0
    MOV x1,i ;x1 = i
    ADD x0,y1 ;r = x0 + y1
    MOV y1,r ;y1 = r, increment y1 by 1
    SUB x1,y1 ;r = x0 - y1
    JNZ error ;if difference is not 0, jump to error
    COM x1 ;r = ~x1
    JNZ iloop ;if x1 is no 4'HF repeat

; re-initialize everything for ALU_test
; preset x0 to 4'HA and y0 to 4'H5 to do all the tests
	LOAD x0,#4'HA ;x0 = A
	LOAD x1,#4'H0 ;x1 = 0
	LOAD y0,#4'H5 ;y0 = 5
	LOAD y1,#4'H0 ;y1 = 0
	LOAD oreg,#4'H0 ;oreg = 0
	LOAD m,#4'H1 ;m = 1
	LOAD i,#4'H0 ;i = 0

    ADD x0,y0 ;r = x0 + y0
    MOV x1,r ;x1 = r
    LOAD y1,#4'HF ;y1 = F
    SUB x1,y1 ;r = x1 - y1
    JNZ error ;if difference is not 0, jump to error

    SUB x0,y0 ;r = x0 - y0
    MOV x1,r ;x1 = r
    LOAD y1,#4'H5 ;y1 = 5
    SUB x1,y1 ;r = x1 - y1
    JNZ error ;if difference is not 0, jump to error

    MULLO x0,y0 ;r = x0 * y0, LS nibble
    MOV x1,r ;x1 = r
    LOAD y1,#4'H2 ;y1 = 2
    SUB x1,y1 ;r = x1 - y1
    JNZ error ;if difference is not 0, jump to error

    MULHI x0,y0 ;r = x0 * y0, MS nibble
    MOV x1,r ;x1 = r
    LOAD y1,#4'H3 ;y1 = 3
    SUB x1,y1 ;r = x1 - y1
    JNZ error ;if difference is not 0, jump to error

    AND x0,y0 ;r = x0 & y0
    MOV x1,r ;x1 = r
    LOAD y1,#4'H0 ;y1 = 0
    SUB x1,y1 ;r = x1 - y1
    JNZ error ;if difference is not 0, jump to error

    XOR x0,y0 ;r = x0 ^ y0
    MOV x1,r ;x1 = r
    LOAD y1,#4'HF ;y1 = F
    SUB x1,y1 ;r = x1 - y1
    JNZ error ;if difference is not 0, jump to error

    NEG x0 ;r = -x0
    MOV x1,r ;x1 = r
    LOAD y1,#4'H6 ;y1 = 6
    SUB x1,y1 ;r = x1 - y1
    JNZ error ;if difference is not 0, jump to error

    COM x0 ;r = ~x0
    MOV x1,r ;x1 = r
    LOAD y1,#4'H5 ;y1 = 5
    SUB x1,y1 ;r = x1 - y1
    JNZ error ;if difference is not 0, jump to error

    JMP end ; finish test
    

; error exit
    ALIGN
error:
    LOAD oreg,#4'H1 ;oreg = 1
    JMP end ;jump to end

; exit
    ALIGN
end:
    JMP end ;stay here at the end of the program
