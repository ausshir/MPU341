        org 00
start:  load x0,#4'H4
        load y0,#4'H4
        jmp calc
        align
calc:   sub x0,y0
        jnz minus
        add x0,y0
        jnz plus
        align
minus:  jmp minus
        align
plus:   jmp plus
