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
  output operations_t op,
  output logic we, re,
  output addrsel_t addrsel
);
  instruction_t instruction;
  logic inst_fetched, inst_fetched_d;
  
  assign instruction = instruction_t'{
    opcode: ir.opcode, 
    funct3: ir.funct3, 
    funct7: ir.funct7
  };

  always_comb begin
    {pcsel, irsel, regsel, regen, alusel0, alusel1,
       op, we, re, addrsel, inst_fetched_d} = '0;

    inst_fetched_d = 1'b1;

    if(inst_fetched) begin
      case(instruction) inside
        {OP, 3'b???, 7'b???????}: begin
          {pcsel, irsel, addrsel, re, we} = {PCSEL_PLUS4, IRSEL_MEM, ADDRSEL_PC, 1'b1, 1'b0};

          regsel = REGSEL_ALU;
          regen = 1'b1;
          alusel0 = ALUSEL0_REG;
          alusel1 = ALUSEL1_REG;
          op = ADD; // TODO
        end          
        default: begin
          assert(1'b0)
            else begin
              $error("%h is not a valid instruction", instruction);
            end
        end
      endcase
    end else begin
      {pcsel, irsel, addrsel, re, we} = {PCSEL_PLUS4, IRSEL_MEM, ADDRSEL_PC, 1'b1, 1'b0};
    end
  end

  always_ff @(posedge clock) begin
    if(~resetn)
      inst_fetched <= 1'b0;
    else  
      inst_fetched <= inst_fetched_d;
  end
endmodule