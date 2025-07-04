`default_nettype none;

module MagComp(
  input logic[31:0] A, B,
  input logic un_signed,
  output logic AeqB, AltB
);
  assign AeqB = (A == B);
  assign AltB = (un_signed) ? 
    ($unsigned(A) < $unsigned(B)) :
    ($signed(A) < $signed(B)); 
endmodule

