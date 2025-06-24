`default_nettype none

module ControlUnit(
  input logic clock, resetn,
  input ir_R_t ir,
  input logic AltB, AeqB, AgtB,

  output pcsel_t pcsel,
  output irsel_t irsel, 
  output regsel_t regsel,
  output logic regen,
  output alusel0_t alusel0,
  output alusel1_t alusel1,
  output operation_t op,
  output logic we, re,
  output addrsel_t addrsel,
  output rs1sel_t rs1sel
);

  enum logic[1:0]{
    FETCH = 2'h0, // no instruction is currently loaded and needs to be fetched
    PART1 = 2'h1, // 1st part of an instruction
    PART2 = 2'h2, // 2nd part of an instruction
    PART3 = 2'h3  // 3rd part of an instruction
  } state, state_d;

  always_comb begin

    // default values
    {pcsel, irsel, regsel, regen, alusel0, alusel1,
      op, we, re, addrsel, inst_fetched_d, rs1_sel, 
      state_d} = '0;

    case({ir.opcode, ir.funct3, ir.funct7, state}) inside

      {7'b???_????, 10'b??_????_????, FETCH} begin

        // get new instruction
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PLUS4, IRSEL_MEM, ADDRSEL_PC, 1'b1, 1'b0};

        // next state
        state_d = PART1;
      end

      // OP Instructions
      {OP, ADD, PART1}, {OP, SUB, PART1}, {OP, XOR, PART1}, 
      {OP, OR, PART1},  {OP, AND, PART1}, {OP, SLL, PART1}, 
      {OP, SRL, PART1}, {OP, SRA, PART1}, {OP, SLT, PART1}, 
      {OP, SLTU, PART1}: begin

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
        op = operation_t'({instruction.funct3, instruction.funct7});

        // next state
        state_d = PART1;
      end  

      // OPIMM instructions
      {OP, ADD[9:7] , 7'b???_????, PART1}, {OP, XOR[9:7], 7'b???_????, PART1}, 
      {OP, OR[9:7]  , 7'b???_????, PART1}, {OP, AND[9:7], 7'b???_????, PART1}, 
      {OP, SLL[9:7] , 7'b???_????, PART1}, {OP, SRL[9:7], 7'b???_????, PART1}, 
      {OP, SRA[9:7] , 7'b???_????, PART1}, {OP, SLT[9:7], 7'b???_????, PART1}, 
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
        rs1_sel = RS1;

        // operation for the alu to perfrom
        op = operation_t'({instruction.funct3, instruction.funct7});

        // next state
        state_d = PART1;
      end  

      // LOAD instructions (Part 1)
      {LOAD, BYTE , 7'b???_????, PART1}, {LOAD, HALF  , 7'b???_????, PART1},
      {LOAD, WORD , 7'b???_????, PART1}, {LOAD, BYTEU , 7'b???_????, PART1},
      {LOAD, HALFU, 7'b???_????, PART1}: begin

        // read value from memory
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PC, IRSEL_IR, ADDRSEL_ALU, 1'b1, 1'b0};

        // load memory value into rd
        regsel = REGSEL_MEM;
        regen = 1'b1;

        // set alu inputs to be register file and IR
        alusel0 = ALUSEL0_REG;
        alusel1 = ALUSEL1_IR;
        rs1_sel = RS1;

        // add RS1 + IMM to calculate memory address 
        op = ADD;

        // next state
        state_d = PART2;
      end

      // LOAD instructions (Part 2)
      {LOAD, BYTE , 7'b???_????, PART2}, {LOAD, HALF  , 7'b???_????, PART2},
      {LOAD, WORD , 7'b???_????, PART2}, {LOAD, BYTEU , 7'b???_????, PART2},
      {LOAD, HALFU, 7'b???_????, PART2}: begin

        // retreive next instruction
        {pcsel, irsel, addrsel, re, we} = 
          {PCSEL_PLUS4, IRSEL_MEM, ADDRSEL_PC, 1'b1, 1'b0};

        // load memory value into rd
        regsel = REGSEL_ALU;
        regen = 1'b1;

        // set alu inputs to be register file and IR
        alusel0 = ALUSEL0_REG;
        //alusel1 does not matter
        rs1_sel = RSD;

        // add RS1 + IMM to calculate memory address 
        op = operation_t'({instruction.funct3, instruction.funct7});

        // next state
        state_d = PART1;
      end

      // Store Instructions (Part 1)
      
      default: begin
        
        $display("Error");
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