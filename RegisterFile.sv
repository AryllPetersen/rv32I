`default_nettype none;

module RegisterFile(
  input logic clock, resetn,
  input logic[4:0] sel0, sel1, selin,
  input logic en,
  input logic[31:0] D,
  output logic[31:0] Q0, Q1
);
  logic[31:1] enable;
  logic[31:0][31:0] Q;

  assign Q[0] = 32'd0;

  generate 
    genvar i;
    for(i = 1; i < 32; i++) begin: r
      assign enable[i] = (en) ? (selin == i) : 1'b0;
      Register r(
        .clock,
        .resetn,
        .D,
        .Q(Q[i]),
        .en(enable[i])
      );
    end 
  endgenerate

  assign Q0 = Q[sel0];
  assign Q1 = Q[sel1];

endmodule

module Register(
  input logic clock, resetn,
  input logic en,
  input logic[31:0] D,
  output logic[31:0] Q
);
  always_ff @(posedge clock, negedge resetn) begin
    if(~resetn) begin
      Q <= 32'd0;
    end else begin
      if(en) begin
        Q <= D;
      end
    end
  end
endmodule