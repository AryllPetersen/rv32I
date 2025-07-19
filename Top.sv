`default_nettype none

`define ECALL 32'h00000073

module Top();

  parameter TIMEOUT = 100000;

  logic clock, resetn;
  tri[31:0] bus;
  logic[31:0] address;
  logic read, write;

  Cpu cp(.*);
  Memory m(.*);

  logic[7:0] mem[2**17-1:0];
  logic[31:0] start_address, mem_size, temp;
  logic[31:0] section_addr[3:0];
  logic[31:0] section_size[3:0];
  string sections[3:0];
  bit[3:0] print_section; 
  opcode_t opcode;
  int i, i2;
  
  assign opcode = opcode_t'(bus[6:0]);
  assign sections = {"DATA", "SDATA","BSS","SBSS"};
  

  // timeout
  initial begin
    repeat(TIMEOUT) begin
      @(posedge clock);
    end
    $display("Timeout at %d", $time);
    $finish;
  end

  // clock
  initial begin
    clock <= 0;
    forever #5 clock = ~clock;
  end

  // initialize values
  initial begin

    // command line args
    if(!$value$plusargs("MEM_SIZE=%h", mem_size)) begin
      $error("No memory size Specified. You must run \"./simv +MEM_SIZE=%%d\"");
      $finish;
    end

    if(!$value$plusargs("START_ADDRESS=%h", start_address)) begin
      $error("No Start Address Specified. You must run \"./simv +START_ADDRESS=%%h\"");
      $finish;
    end

    print_section[0] = ($value$plusargs("DATA_ADDRESS=%h" , section_addr[0]) && $value$plusargs("DATA_SIZE=%h"  , section_size[0]));
    print_section[1] = ($value$plusargs("SDATA_ADDRESS=%h", section_addr[1]) && $value$plusargs("SDATA_SIZE=%h" , section_size[1]));
    print_section[2] = ($value$plusargs("BSS_ADDRESS=%h"  , section_addr[2]) && $value$plusargs("BSS_SIZE=%h"   , section_size[2]));
    print_section[3] = ($value$plusargs("SBSS_ADDRESS=%h" , section_addr[3]) && $value$plusargs("SBSS_SIZE=%h"  , section_size[3]));
    sections[0] = "DATA";
    sections[1] = "SDATA";
    sections[2] = "BSS";
    sections[3] = "SBSS";

    // load memory
    mem = '{default: '0};
    $readmemb("example/example.txt", mem, mem_size);

    // reset
    resetn <= 0;
    @(posedge clock);
    resetn <= 1;

    #1;
    force m.mem = mem; // initialize memory
    force cp.PC.Q = (start_address-4); // initialize PC counter
    force cp.rf.r[2].r.Q = (mem_size); // initialize stack pointer
    release cp.PC.Q;
    release m.mem;
    release cp.rf.r[2].r.Q;

    forever begin
      @(posedge clock);

      if(cp.cu.state == HALT) begin 
        if(cp.ir == `ECALL) begin 
          $display("ecall instruction found. Program Finished.");
        end else begin
          $display("CPU Halted. Program Finished.");
        end
        for(i = 0; i < 4; i++) begin
          if(print_section[i]) begin
            $display("\n===== %s SECTION =====", sections[i]);
            for(i2 = section_addr[i]; i2 < (section_addr[i]+section_size[i]); i2+=4) begin
              temp = {m.mem[i2+3], m.mem[i2+2], m.mem[i2+1], m.mem[i2]};
              $display("HEX: %h, DEC: %d", temp, $signed(temp));
            end
            $display("===== END %s SECTION =====", sections[i]);
          end
        end
        $finish;
      end

      if($test$plusargs("VERBOSE")) begin
        if(read && (cp.irsel == IRSEL_MEM)) begin
          if(bus == `ECALL) begin
            $display("Loading ECALL Instruction at 0x%h", address);
          end else begin
            $display("Loading %s Instruction at 0x%h", opcode.name, address);
          end
        end
        if(read && (cp.regsel == REGSEL_MEM) && cp.regen) begin
          $display("Reading value 0x%h from Memory at 0x%h", bus, address);
        end
        if(cp.pcsel == PCSEL_ALU) begin
          $display("Jumping to 0x%h", cp.pc_D);
        end
        if(write) begin
          $display("Writting value 0x%h to Memory at 0x%h", bus, address);
        end
      end
    end
  end


endmodule