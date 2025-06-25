`default_nettype none

module ALU(
  input logic[31:0] A, B,
  input opcode_t opcode,
  input operation_t op,

  output logic[31:0] aluout
);

  ir_I_t ir_I;
  ir_S_t ir_S;
  ir_U_t ir_U;
  logic[31:0] imm;

  assign ir_I = ir_I_t'(B);
  assign ir_S = ir_S_t'(B);
  assign ir_U = ir_U_t'(B);

  always_comb begin

    // default value
    {imm, aluout} = '0;

    case(opcode)
      OP: begin
        case(op)
          ADD:    aluout = A + B;
          SUB:    aluout = A - B;
          XOR:    aluout = A ^ B;
          OR:     aluout = A | B;
          AND:    aluout = A & B;
          SLL:    aluout = A << B;
          SRL:    aluout = A >> B;
          SRA:    aluout = A >>> B;
          SLT:    aluout = (A < B) ? 32'h1 : 32'h0; 
          SLTU:   aluout = ($unsigned(A) < $unsigned(B)) ? 32'h1 : 32'h0; 
          default: aluout = '0;
        endcase
      end

      OPIMM: begin
        imm = {20'd0, ir_I.imm};
        case(op) inside
          {ADD[9:7], 7'b???_????}:  aluout = A + imm;
          {XOR[9:7], 7'b???_????}:  aluout = A ^ imm;
          {OR[9:7], 7'b???_????}:   aluout = A | imm;
          {AND[9:7], 7'b???_????}:  aluout = A & imm;
          SLL: aluout = A << imm[4:0];
          SRL: aluout = A >> imm[4:0];
          SRA: aluout = A >>> imm[4:0];
          {SLT[9:7], 7'b???_????}:  aluout = (A < imm) ? 32'h1 : 32'h0; 
          {SLTU[9:7], 7'b???_????}: aluout = ($unsigned(A) < $unsigned(imm)) ? 32'h1 : 32'h0; 
          default: aluout = '0;
        endcase
      end

      LOAD: begin
        imm = {20'd0, ir_I.imm};
        case(op[9:7])
          ADDRESS:  aluout = A + imm;
          BYTE:     aluout = A[7] ? {24'hFFFFFF, A[7:0]} : {24'd0, A[7:0]};
          WORD:     aluout = A[15] ? {16'hFFFF, A[15:0]} : {16'd0, A[15:0]};
          BYTEU:    aluout = {24'd0, A[7:0]};
          HALFU:    aluout = {16'd0, A[15:0]};
          default:  aluout = '0;
        endcase 
      end

      STORE: begin
        imm = {20'd0, ir_S.imm1, ir_S.imm0};
        aluout = A + ((imm[11]) ? {20'hFFFFF, imm[11:0]}: imm);
      end

      BRANCH: begin
        imm = {19'd0, ir_S.imm1[6], ir_S.imm0[0],
               ir_S.imm1[5:0], ir_S.imm0[4:1], 1'b0};
        aluout = A + ((imm[12]) ? {19'h7FFFF, imm[12:0]} : imm);
      end

      JAL: begin
        imm = {11'd0, ir_U.imm[19], ir_U.imm[7:0], 
               ir_U.imm[8], ir_U.imm[18:9], 1'b0};
        aluout = A + ((imm[20]) ? {11'h3FF, imm[20:0]}: imm);
      end

      JALR: begin
        imm = {20'd0, ir_I.imm};
        aluout = A + ((imm[11]) ? {20'hFFFFF, imm[11:0]}: imm);
      end

      LUI: begin
        imm = {12'd0, ir_U.imm};
        aluout = imm << 12;
      end

      AUIPC: begin
        imm = {12'd0, ir_U.imm};
        aluout = A + imm << 12;
      end

      default: aluout = '0;
    endcase
  end

endmodule