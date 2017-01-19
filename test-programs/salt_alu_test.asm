;
;  Revised March 29, 2010
;
;  This program tests the operation of the arithmetic/logic unit
;  for the EE431 micro processor logic unit. If the alu is
;  operating correctly the oreg will change states - staying in
;  each state for 1 or more clock cycles - as given below.
;  Note that after each function is tested oreg is cleared.
;  After all the functions of the alu are tested, the zero flag
;  is tested. When the testing is complete oreg is set to F.
;  After the zero flag is tested then two of the four no-operation
;  instructions are tested. These are NOPC8 and NOPCF. No-op
;  instructions NOPD8 and NOPDF are not tested.
;  
;  The correct sequence of values that oreg will have is
;  listed below. The first two value depend on the negate
;  fucntion, the zero is inserted for punctuation,
;  values 4 through 7, depend on the subtract 
;  fucntion, ect. 
;
;  neg:    oreg = B, 6, 0
;  sub:    oreg = 2, E, 9, 7, 0
;  add:    oreg = 8, 6, 0
;  and:    oreg = 1, 8, 0
;  mulhi: oreg = 1, 7, 0
;  mullo: oreg = E, 8, 0
;  xor:    oreg = 9, 6, 0
;  com:    oreg = A, 5, 0
;  carry flag: oreg = D, C, B, 0
;  NOPC8:   3, 2, 1, 0
;  NOPCF    9, 8, 1, 0
;  Done    oreg =  F
;
		org 00
start:  load oreg,#4'H0;  oreg = 0
		load x0,#4'H5;     x0 = 5
		load x1,#4'HA;     x1 = A
        load y0,#4'H3;     y0 = 3
		load y1,#4'HC;     y1 = C
;
;  Test negate (2's complement) function r = -x0 or r = -x1
;
		neg x0;            r  = -x0
        mov oreg,r;       oreg = B $$$$$$$$
        neg x1;
        mov oreg,r;       oreg = 6 $$$$$$$$
        load oreg,#4'H0;  oreg = 0 ********
;
;  Test subtract r = x - y, where x could be x0 ro x1 and
;  y could be y0 o y1
;
		sub x0,y0;         r = x0 - y0
        mov oreg,r;       oreg = 2 $$$$$$$$
		sub x1,y1;     
        mov oreg,r;       oreg = E $$$$$$$$
		sub x0,y1;
        mov oreg,r;       oreg = 9 $$$$$$$$
		sub x1,y0;     
        mov oreg,r;       oreg = 7 $$$$$$$$
        load oreg,#4'H0;  oreg = 0 ********
;
; Test add  r = x + y
;
		add x0,y0;         r = x0 + y0
        mov oreg,r;       oreg = 8 $$$$$$$$
		add x1,y1;     
        mov oreg,r;       oreg = 6 $$$$$$$$
        load oreg,#4'H0;  oreg = 0 ********
;
; Test and  r = x & y
;
		and x0,y0;         r = x0 & y0
        mov oreg,r;       oreg = 1 $$$$$$$$
		and x1,y1;     
        mov oreg,r;       oreg = 8 $$$$$$$$
        load oreg,#4'H0;  oreg = 0 ********
;
; Test high nibble of multply  r = x times y
;
		mulhi x1,y0;       r = ms 4 bits of x1 x y0
        mov oreg,r;       oreg = 1 $$$$$$$$
		mulhi x1,y1;     
        mov oreg,r;       oreg = 7 $$$$$$$$
        load oreg,#4'H0;  oreg = 0 ********
;
; Test low nibble of multply  r = x times y
;
		mullo x1,y0;       r = ls 4 bits of x1 x y0
        mov oreg,r;       oreg = E $$$$$$$$
		mullo x1,y1;     
        mov oreg,r;       oreg = 8 $$$$$$$$
        load oreg,#4'H0;  oreg = 0 ********
;
; Test and  r = x ^ y
;
		xor x1,y0;         r = x1 ^ y0
        mov oreg,r;       oreg = 9 $$$$$$$$
		xor x0,y0;     
        mov oreg,r;       oreg = 6 $$$$$$$$
        load oreg,#4'H0;  oreg = 0 ********
;
;  Test 1's complemen  r = ~x0 or r = ~x1
;
		com x0;            r  = ~x0
        mov oreg,r;       oreg = A $$$$$$$$
        com x1;
        mov oreg,r;       oreg = 5 $$$$$$$$
        load oreg,#4'H0;  oreg = 0 ******** 
;
; ***************************
; now test the zero flag - making sure it is
; set and cleared at the right time - not one
; clock cycle to late
; ***************************
;
		load x0,#4'H0;
                load x1,#4'HA;
        neg x0;           set zero flag
        neg x1;           clear zero flag since r = -x1 = 4'H6
        jnz flagcorrect; should jump
        jmp flagwrong;   should not reach this instruction
        ALIGN
flagcorrect:
        load oreg,#4'HD; oreg = D $$$$$$$$$$$$$
        neg x0;           set zero flag
        jnz flagwrong;   should not jump
        load oreg,#4'HC; oreg = C $$$$$$$$$$$$$
        load x0,#4'H0;
        neg x0;          r=-4'H0=4'H0 therefore zero flag set
        load oreg,#4'HB; a load instr. therefore zero flag should not change
        jnz flagwrong;   zero flag = 1'b1 so should not jump
        load oreg,#4'H0;
        jmp NOPC8test;
        ALIGN
flagwrong:
        load oreg,#4'HE; should never happen
        jmp done;
        ALIGN
;
; now test NOPC8
;
NOPC8test: 
         load x1,#4'HF;  
         NOPC8; should not change r or zero flag
         jnz done; zero flag is 1 so should not jump
         mov x0,r; x0 = 0
         jnz done; zero flag is 1 so should not jump
         mov y1,y0;  r should not change
         jnz done; zero flag is 1 so should not jump
         load m,#4'H7;  r should not change
         jnz done; zero flag is 1 so should not jump
         load oreg,#4'H3; oreg = 3
         com x1;   r=~F=0 so zero flag should get set
         jnz done;  should not jump
         load oreg,#4'H2; oreg = 2
         neg x1;   r=-F=1 so zero flag should be cleared
         NOPC8;
         mov oreg,r;  oreg = 1
         load oreg,#4'H0; oreg = 0
;
; now test NOPCF
;
NOPCFtest: 
         com x1;  x1 = F
         NOPCF; should not change r or zero flag
         jnz done; zero flag is 1 so should not jump
         mov x0,r; x0 = 0
         jnz done; zero flag is 1 so should not jump
         mov y1,y0;  r should not change
         jnz done; zero flag is 1 so should not jump
         load m,#4'H7;  r should not change
         jnz done; zero flag is 1 so should not jump
         load oreg,#4'H9; oreg = 9
         com x1;   r=~F=0 so zero flag should get set
         jnz done;  should not jump
         load oreg,#4'H8; oreg = 8
         neg x1;   r=-F=1 so zero flag should be cleared
         NOPCF;
         mov oreg,r;  oreg = 1
         load oreg,#4'H0; oreg = 0
         jmp done;
         ALIGN

        
done:   load oreg,#4'HF;  oreg = F   **************
        jmp done;
