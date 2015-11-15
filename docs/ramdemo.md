## Testing RAM

Note: Not complete, needs a bit more work on ASSEMBLY language

This program is intended to test the RAM (data memory) by filling it up, and then reading back and verifying the contents.
The program works by using a counter as the address and data, writing each value to RAM and then reading back that data to check against the original counter.
The status of the check is held in a register and will be flagged if anything is wrong.

Pseudo-code

    load i with 0
    move i to DM
    compare i and max mem size
    conditional jump 2 previous
    load i with 0
    load x1 with 0
    load x0 with DM[i]
    compare x0 and x1
    conditional jump 5 ahead
    compare i with max mem size
    add 1 to x1
    compare i and max mem size
    conditional jump back 6
    set y0 with result
    jump 5 back

Real assembly

    NUM   RAMSIZE 4'b010101010; put number here
          LOAD i, #0
          LOAD x1, #RAMSIZE

    fill  MOV DM, i
          MOV x0, i
          AND x0, x1
          JNZ read
          JMP fill

    read  LOAD i, #0
          LOAD y1, #0
          MOV y0, DM
          AND y1, y2
          JNZ <A>
          LOAD OREG, #1
          JMP <A>
