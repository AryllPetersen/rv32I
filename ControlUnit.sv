`default_nettype none

module ControlUnit(
  input logic clock, resetn,
  input ir_R_t ir,
  input logic AltB, AeqB,

  output pcsel_t pcsel,
  output irsel_t irsel, 
  output regsel_t regsel,
  output logic regen,
  output alusel0_t alusel0,
  output alusel1_t alusel1,
  output operation_t op,
  output logic we, re,
  output addrsel_t addrsel,
  output rs1sel_t rs1sel,
  output tmpsel_t tmpsel,
  output dataoutsel_t dataoutsel,
  output logic un_signed
);

  enum logic[1:0]{
    FETCH = 2'h0, // no instruction is currently loaded and needs to be fetched
    PART1 = 2'h1, // 1st part of an instruction
    PART2 = 2'h2, // 2nd part of an instruction
    HALT  = 2'h3  // an error occurred and the FSM will stop until reset
  } state, state_d;

  assign un_signed = (ir.funct3 == BLTU || ir.funct3 == BGEU);

  always_comb begin

    // default values
    {pcsel, irsel, regsel, regen, alusel0, alusel1,
      op, we, re, addrsel, rs1sel, tmpsel, dataoutsel, 
      state_d} = '0;

    case({ir.opcode, ir.funct3, ir.funct7, state}) inside

      // FETCH instruction
      {7'b???_????, 10'b??_????_????, FETCH}: begin

        // get new instruction
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PLUS4, IRSEL_MEM, ADDRSEL_PC, 1'b1, 1'b0};

        // next state
        state_d = PART1;
      end

      // OP Instructions
      {OP, ADD  , PART1}, {OP, SUB, PART1}, {OP, XOR, PART1}, 
      {OP, OR   , PART1}, {OP, AND, PART1}, {OP, SLL, PART1}, 
      {OP, SRL  , PART1}, {OP, SRA, PART1}, {OP, SLT, PART1}, 
      {OP, SLTU , PART1}: begin

        // get new instruction
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PLUS4, IRSEL_MEM, ADDRSEL_PC, 1'b1, 1'b0};

        // load ALU result into rd
        regsel = REGSEL_ALU;
        regen = 1'b1;

        // set alu inputs to be from register file
        alusel0 = ALUSEL0_REG;
        alusel1 = ALUSEL1_REG;
        rs1sel = RS1;

        // operation for the alu to perfrom
        op = operation_t'({ir.funct3, ir.funct7});

        //tmpsel does not matter
        //dataoutsel does not matter

        // next state
        state_d = PART1;
      end  

      // OPIMM instructions
      {OP, ADD[9:7] , 7'b???_????, PART1}, {OP, XOR[9:7], 7'b???_????, PART1}, 
      {OP, OR[9:7]  , 7'b???_????, PART1}, {OP, AND[9:7], 7'b???_????, PART1}, 
      {OP, SLL                   , PART1}, {OP, SRL                  , PART1}, 
      {OP, SRA                   , PART1}, {OP, SLT[9:7], 7'b???_????, PART1}, 
      {OP, SLTU[9:7], 7'b???_????, PART1}: begin
        
        // get new instruction
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PLUS4, IRSEL_MEM, ADDRSEL_PC, 1'b1, 1'b0};

        // load ALU result into rd
        regsel = REGSEL_ALU;
        regen = 1'b1;

        // set alu inputs to be from register file and IR
        alusel0 = ALUSEL0_REG;
        alusel1 = ALUSEL1_IR;
        rs1sel = RS1;

        // operation for the alu to perfrom
        op = operation_t'({ir.funct3, ir.funct7});

        //tmpsel does not matter
        //dataoutsel does not matter

        // next state
        state_d = PART1;
      end  

      // LOAD instruction (Part 1)
      {LOAD, BYTE , 7'b???_????, PART1}, {LOAD, HALF  , 7'b???_????, PART1},
      {LOAD, WORD , 7'b???_????, PART1}, {LOAD, BYTEU , 7'b???_????, PART1},
      {LOAD, HALFU, 7'b???_????, PART1}: begin

        // read value from memory at address calculated by ALU
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PC, IRSEL_IR, ADDRSEL_ALU, 1'b1, 1'b0};

        // load memory value into rd
        regsel = REGSEL_MEM;
        regen = 1'b1;

        // set alu inputs to be register file and IR
        alusel0 = ALUSEL0_REG;
        alusel1 = ALUSEL1_IR;
        rs1sel = RS1;

        // add RS1 + IMM to calculate memory address 
        op = operation_t'({ADDRESS, 7'h00});

        //tmpsel does not matter
        //dataoutsel does not matter

        // next state
        state_d = PART2;
      end

      // LOAD instruction (Part 2)
      {LOAD, BYTE , 7'b???_????, PART2}, {LOAD, HALF  , 7'b???_????, PART2},
      {LOAD, WORD , 7'b???_????, PART2}, {LOAD, BYTEU , 7'b???_????, PART2},
      {LOAD, HALFU, 7'b???_????, PART2}: begin

        // retreive next instruction
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PLUS4, IRSEL_MEM, ADDRSEL_PC, 1'b1, 1'b0};

        // load alu output into rd
        regsel = REGSEL_ALU;
        regen = 1'b1;

        // set alu inputs to be rs1
        alusel0 = ALUSEL0_REG;
        //alusel1 does not matter
        rs1sel = RSD;

        // ALU will truncate rd depending on ir.funct3
        op = operation_t'({ir.funct3, ir.funct7});

        //tmpsel does not matter
        //dataoutsel does not matter

        // next state
        state_d = PART1;
      end

      // Store (BYTE | HALF) Instruction (Part 1)
      {STORE, BYTE, 7'b???_????, PART1}, {STORE, HALF, 7'b???_????, PART1}: begin

        // read value from memory at address calculated by ALU
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PC, IRSEL_IR, ADDRSEL_ALU, 1'b1, 1'b0};

        //regsel does not matter
        regen = 1'b0;

        // set ALU inputs to be RS1 and IR
        alusel0 = ALUSEL0_REG;
        alusel1 = ALUSEL1_IR;
        rs1sel = RS1;

        // op does not matter, ALU gets information from opcode

        // select value to store in temporary register
        tmpsel = (ir.funct3 == BYTE) ? TMPSEL_BYTE : TMPSEL_HALF;

        // dataoutsel does not matter

        // next state
        state_d = PART2;
      end

      // Store (BYTE | HALF) Instruction (Part 2)
      {STORE, BYTE, 7'b???_????, PART1}, {STORE, HALF, 7'b???_????, PART1}: begin

        // write value to memory at address calculated by ALU
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PC, IRSEL_IR, ADDRSEL_ALU, 1'b0, 1'b1};

        //regsel does not matter
        regen = 1'b0;

        // set ALU inputs to be RS1 and IR
        alusel0 = ALUSEL0_REG;
        alusel1 = ALUSEL1_IR;
        rs1sel = RS1;

        // op does not matter, ALU gets information from opcode

        //tmpsel does not matter

        //write temporary variable to storage location
        dataoutsel = DATAOUTSEL_TMP;

        // next state
        state_d = FETCH;
      end

      // Store (WORD) Instruction 
      {STORE, WORD, 7'b???_????, PART1}: begin

        // write value to memory at address calculated by ALU
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PC, IRSEL_IR, ADDRSEL_ALU, 1'b0, 1'b1};

        //regsel does not matter
        regen = 1'b0;

        // set ALU inputs to be RS1 and IR
        alusel0 = ALUSEL0_REG;
        alusel1 = ALUSEL1_IR;
        rs1sel = RS1;

        // op does not matter, ALU gets information from opcode

        //tmpsel does not matter

        //write temporary variable to storage location
        dataoutsel = DATAOUTSEL_REG;

        // next state
        state_d = FETCH;
      end

      {BRANCH, BEQ  , 7'b???_???? , PART1} , {BRANCH, BNE , 7'b???_????  , PART1}, 
      {BRANCH, BLT  , 7'b???_???? , PART1} , {BRANCH, BGE , 7'b???_????  , PART1}, 
      {BRANCH, BLTU , 7'b???_????,  PART1} , {BRANCH, BGEU, 7'b???_????  , PART1}: begin

        if(ir.funct3 == BEQ  && AeqB  || ir.funct3 == BNE  && ~AeqB ||
           ir.funct3 == BLT  && AltB  || ir.funct3 == BGE  && ~AltB ||
           ir.funct3 == BLTU && AltB  || ir.funct3 == BGEU && ~AltB) begin

          // get next instruction at address PC + IMM and increment PC
          {pcsel, irsel, addrsel, re, we} = 
            {PCSEL_ALU, IRSEL_MEM, ADDRSEL_ALU, 1'b1, 1'b0};
        end else begin

          // get next instruction at address PC and increment PC
          {pcsel, irsel, addrsel, re, we} = 
            {PCSEL_PLUS4, IRSEL_MEM, ADDRSEL_PC, 1'b1, 1'b0};
        end

        //regsel does not matter
        regen = 1'b0;

        // set ALU inputs to be PC and IR
        alusel0 = ALUSEL0_PC;
        alusel1 = ALUSEL1_IR;
        rs1sel = RS1;

        // op does not matter, ALU gets information from opcode

        //tmpsel does not matter
        //dataoutsel does not matter

        // next state
        state_d = PART1;
      end

      {JAL, 10'b??_????_????, PART1}, {JALR, 3'h0, 7'b???_????, PART1}: begin

        // get next instruction at either PC + IMM or RS1 + IMM
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_ALU, IRSEL_MEM, ADDRSEL_ALU, 1'b1, 1'b0};

        regsel = REGSEL_PLUS4;
        regen = 1'b1;

        // set ALU inputs to be (PC or RS1) and IR
        alusel0 = (ir.opcode == JAL) ? ALUSEL0_PC : ALUSEL0_REG;
        alusel1 = ALUSEL1_IR;
        rs1sel = RS1;

        // op does not matter, ALU gets information from opcode

        //tmpsel does not matter
        //dataoutsel does not matter

        // next state
        state_d = PART1;
      end

      {LUI, 10'b??_????_????, PART1}, {AUIPC, 10'b??_????_????, PART1}: begin

        // get next instruction
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PLUS4, IRSEL_MEM, ADDRSEL_PC, 1'b1, 1'b0};

        regsel = REGSEL_ALU;
        regen = 1'b1;

        // set ALU inputs to be PC and IMM
        alusel0 = ALUSEL0_PC;
        alusel1 = ALUSEL1_IR;
        rs1sel = RS1;

        // op does not matter, ALU gets information from opcode

        //tmpsel does not matter
        //dataoutsel does not matter

        // next state
        state_d = PART1;
      end

      // HALT
      {7'b???_????, 10'b??_????_????, HALT}: begin
        state_d = HALT;
      end
      default: begin
        $error("%h is an invalid instruction corresponding to state %s", ir, state.name);
        state_d = HALT;
      end
    endcase
  end

  always_ff @(posedge clock) begin
    if(~resetn)
      state <= FETCH;
    else  
      state <= state_d;
  end
endmodule



