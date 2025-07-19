`default_nettype none

module Cpu(
  input logic clock,
  input logic resetn,
  inout tri[31:0] bus,
  output logic read, write,
  output logic[31:0] address
);
  // Program Counter 
  logic[31:0] pc_D;
  logic[31:0] pc;
  logic[31:0] pcplus4;

  // Instruction Register
  logic[31:0] ir_D;
  ir_R_t ir;

  // Register File
  logic[31:0] D;
  logic[4:0] sel0;
  logic[31:0] Q0, Q1;

  // Bus Driver
  logic[31:0] datain, dataout;

  // ALU
  logic[31:0] A, B;
  logic[31:0] aluout;

  // Temporary Register
  logic[23:0] tmp_Q, tmp_D;
  logic[31:0] tmp;

  // Mag Comparator
  logic AltB, AeqB;

  //Control Unit
  pcsel_t pcsel;
  irsel_t irsel; 
  regsel_t regsel;
  logic regen;
  alusel0_t alusel0;
  alusel1_t alusel1;
  operation_t op;
  addrsel_t addrsel;
  rs1sel_t rs1sel;
  tmpsel_t tmpsel;
  dataoutsel_t dataoutsel;
  logic un_signed;
  logic we;

  assign pcplus4 = 32'd4 + pc;

  assign pc_D = (pcsel == PCSEL_ALU) ? (aluout) : (
    (pcsel == PCSEL_PLUS4) ? pcplus4 : pc
  );

  assign ir_D = (irsel == IRSEL_MEM) ? datain : ir;

  assign D = (regsel == REGSEL_ALU) ? aluout : (
    (regsel == REGSEL_PLUS4) ? pcplus4 : datain
  );

  assign sel0 = (rs1sel == RS1) ? ir.rs1 : ir.rd;

  assign dataout = (dataoutsel == DATAOUTSEL_TMP) ? tmp : Q1;

  assign A = (alusel0 == ALUSEL0_REG) ? Q0 : pc;
  assign B = (alusel1 == ALUSEL1_REG) ? Q1 : ir;

  assign tmp_D = {datain[31:16], 
    (tmpsel == TMPSEL_BYTE) ? datain[15:8] : Q1[15:8]
  };
  assign tmp = {tmp_Q, Q1[7:0]};

  assign address = (addrsel == ADDRSEL_ALU) ? aluout : pcplus4;

  ControlUnit cu(
    .clock,
    .resetn,
    .ir,
    .AltB,
    .AeqB,
    .pcsel,
    .irsel, 
    .regsel,
    .regen,
    .alusel0,
    .alusel1,
    .op,
    .we, 
    .re(read),
    .addrsel,
    .rs1sel,
    .tmpsel,
    .dataoutsel,
    .un_signed
  );

  RegisterSimple #(.WIDTH(32), .INIT(-4)) PC(
    .clock,
    .resetn,
    .D(pc_D),
    .Q(pc)
  );

  RegisterSimple #(32) IR(
    .clock,
    .resetn,
    .D(ir_D),
    .Q(ir)
  );

  RegisterSimple #(24) TMP(
    .clock,
    .resetn,
    .D(tmp_D),
    .Q(tmp_Q)
  );

  RegisterFile rf(
    .clock,
    .resetn,
    .D,
    .sel0,
    .sel1(ir.rs2),
    .selin(ir.rd),
    .en(regen),
    .Q0,
    .Q1
  );

  Alu alu(
    .A,
    .B,
    .op,
    .opcode(ir.opcode),
    .aluout
  );

  MagComp mg(
    .A(Q0),
    .B(Q1),
    .un_signed,
    .AltB,
    .AeqB
  );

  BusDriver bd(
    .in(dataout),
    .out(datain),
    .we,
    .bus
  );

  assign write = we;

endmodule


/*
  Register with no enable input.
  Asyncronously resets to INIT
*/
module RegisterSimple
#(parameter WIDTH = 32, parameter INIT = 0)
(
  input logic clock, 
  input logic resetn,
  input logic[WIDTH-1:0] D,
  output logic[WIDTH-1:0] Q
);
  always_ff @(posedge clock, negedge resetn) begin
    if(~resetn) begin
      Q <= INIT;
    end else begin
      Q <= D;
    end
  end
endmodule