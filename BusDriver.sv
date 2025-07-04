`default_nettype none;

module BusDriver(
  input logic we,
  input logic[31:0] in,
  output logic[31:0] out,
  inout tri[31:0] bus
);
  assign bus = (we) ? in : 'z;
  assign out = bus;

endmodule