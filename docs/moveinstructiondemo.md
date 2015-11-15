## Testing the MOV instruction
The below program was a sample for testing the MPU for its MOV functionality. The assembly code is below. It aims to:
  1. Load a number of registers with zeroes
  2. Bring i_pins (external pins) into the MPU and then shift it through x0 and x1
  3. Bring in another set of data from i_pins and pass it between the rest of the registers.


At 0x15 the ALU (not yet implemented) is to be used to set the value negative.
Note that column 1 is the address in hex, column 2, which starts after the colon, is the assembly instruction.

i_pins may be set to 0x0 and 0xF for testing to see that data was passed through properly and no bits get flipped or missed along the way.

    00: x0 = 0; // load x0 with the constant 0
    01: x1 = 0;
    02: y0 = 0;
    03: y1 = 0;
    04: o_reg = 0;
    05: m = 0;
    06: i = 0;
    07: x0 = i_pins; // move the value of i_pins to x0
    // value of i_pins comes from FPGA pins.
    // Of course in this class i_pins is simulated
    // in Modelsim-Altera with ‘‘initial’’ procedure
    08: x1 = x0;
    09: x0 = i_pins; // move the value of i_pins to x0
    // NOTE: should change value of i_pins after
    // 8th rising edge of clock so that a different
    // value gets moved to x0 on this instruction
    0A: y0 = x1;
    0B: x1 = x0;
    0C: y1 = y0;
    0D: y0 = x1;
    0E: m = y1;
    0F: y1 = y0;
    10: i = m;
    11: m = y1;
    12: o_reg = i;
    13: i = m;
    14: o_reg = i;
    15: r = -x0;
    16: o_reg = r;
    17: x0 = r;
    18: r = -x0;
    19: o_reg = r;
    1A: o_reg = F;
    1B: jump 00H;

Converted to machine code / op-codes by hand (no compiler yet!)

    ADDR: OP: ASSY; //comment
    00: 00: x0 = 0; //load instruction
    01: 10: x1 = 0;
    02: 20: y0 = 0;
    03: 30: y1 = 0;
    04: 40: o_reg = 0;
    05: 50: m = 0;
    06: 60: i = 0;
    07: 80: x0 = i_pins; // mov instruction
    08: 88: x1 = x0;
    09: 80: x0 = i_pins;
    0A: 91: y0 = x1;
    0B: 88: x1 = x0;
    0C: 9A: y1 = y0;
    0D: 91: y0 = x1;
    0E: AB: m = y1;
    0F: 9A: y1 = y0;
    10: B5: i = m;
    11: AB: m = y1;
    12: A6: o_reg = i;
    13: B5: i = m;
    14: A6: o_reg = i;
    15: C0: r = -x0; // ALU instruction
    16: A4: o_reg = r;
    17: 84: x0 = r;
    18: C0: r = -x0;
    19: A4: o_reg = r;
    1A: 4F: o_reg = F;
    1B: E0: jump 00H;
