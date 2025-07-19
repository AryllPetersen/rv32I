`default_nettype none

module Memory(
  input logic clock,
  input logic resetn,
  input logic read,
  input logic write,
  input logic[31:0] address,
  inout tri[31:0] bus
);
  logic[7:0] mem[2**17-1:0];
  logic[31:0] data_out, data_in;
  logic we, re;

  assign we = write & ~read;
  assign re = ~we;
  assign data_out = {mem[address+3], mem[address+2], mem[address+1], mem[address]};

  BusDriver bd(
    .we(re),
    .in(data_out),
    .out(data_in),
    .bus
  );

  always_ff @(posedge clock, negedge resetn) begin
    if(~resetn) begin
      mem <= '{default: '0};
    end else begin
      if(we) begin
        mem[address]   <= data_in[7:0];
        mem[address+1] <= data_in[15:8];
        mem[address+2] <= data_in[23:16];
        mem[address+3] <= data_in[31:24];
      end
    end
  end
endmodule