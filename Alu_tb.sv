`default_nettype none

module Alu_tb();

  class TestCase;
    logic[31:0] A;
    logic[31:0] B;
    logic[31:0] expected;

    function new(logic[31:0] A = 32'd0, B = 32'd0, expected = 32'd0);
      this.A = A;
      this.B = B;
      this.expected = expected;
    endfunction
  endclass

  class Test;
    TestCase test_queue[$];
    operation_t op;
    opcode_t opcode;
    string name;
    int error_count;
    int test_cases;

    static int total_tests = 0;
    static int successful_tests = 0;
    static string success_queue[$];
    static string failed_queue[$];

    function new(opcode_t opcode, operation_t op, string name);
      this.op = op;
      this.opcode = opcode;
      this.name = name;
    endfunction

    function void add(logic[31:0] A, B, expected);
      TestCase t = new(.A(A), .B(B), .expected(expected));
      this.test_queue.push_back(t);
      this.test_cases++;
    endfunction

    task run(
      ref logic[31:0] A, 
      ref logic[31:0] B, 
      ref opcode_t opcode,
      ref operation_t op
    );
      TestCase t;
      #10;
      total_tests++;
      this.error_count = 0;
      $display("\n<----------  %s --------->",this.name);
      $display("Running %d Test Cases:\n", test_cases);
      opcode = this.opcode;
      op = this.op;
      while(test_queue.size() > 0) begin
        t = test_queue.pop_front();
        A = t.A;
        B = t.B;
        #1;
        if(aluout == t.expected) begin
          $display("PASSED: opcode: %s", opcode.name, 
            " op: %b", op,
            " A: %h", A, 
            " B: %h", B,
            " aluout: %h", aluout
          );
        end else begin
          $display("FAILED: opcode: %s", opcode.name, 
            " op: %b", op,
            " A: %h", A, 
            " B: %h", B,
            " aluout: %h", aluout,
            "\nExpected: %h", t.expected
          );
          this.error_count++;
        end
      end

      if(error_count == 0) begin
        successful_tests++;
        $display("\nAll Test Cases Passed.\n");
        success_queue.push_back(this.name);
      end else begin
        $display("\n%d Test Cases Failed out of %d\n", error_count, test_cases);
        failed_queue.push_back(this.name);
      end

    endtask

    static function void summarize();
      $display("|------------------------|\n",
               "|-----ALU TB SUMMARY-----|\n",
               "|------------------------|\n",
               "Total Tests Ran: %d\n", total_tests,
               "Tests With No Errors: %d\n", successful_tests,
               "Tests That Failed: %d\n", total_tests - successful_tests
      );
      if(success_queue.size() > 0) begin
        $display("Successful Tests:\n");
        while(success_queue.size() > 0) begin
          $display(" - %s", success_queue.pop_front());
        end
      end
      if(failed_queue.size() > 0) begin
        $display("Failed Tests:\n");
        while(failed_queue.size() > 0) begin
          $display("  - %s", failed_queue.pop_front());
        end
      end
    endfunction
  endclass

  // takes an immediate and converts it into I instruction format
    // the values that shouldn't matter are randomized
  function logic[31:0] imm_I(input logic[11:0] imm);
    logic[19:0] rnd;
    rnd = $urandom_range(20'd0, 20'hF_FFFF);
    return {imm, rnd};
  endfunction

  // takes an immediate and converts it into S instruction format
    // the values that shouldn't matter are randomized
  function logic[31:0] imm_S(input logic[11:0] imm);
    logic[19:0] rnd;
    rnd = $urandom_range(20'd0, 20'hF_FFFF);
    return {imm[11:5], rnd[19:7], imm[4:0], rnd[6:0]};
  endfunction

  // takes an immediate and converts it into B instruction format
    // the values that shouldn't matter are randomized
  function logic[31:0] imm_B(input logic[12:0] imm);
    logic[19:0] rnd;
    rnd = $urandom_range(20'd0, 20'hF_FFFF);
    return {imm[12], imm[10:5], rnd[19:7], imm[4:1], imm[11], rnd[6:0]};
  endfunction

  // takes an immediate and converts it into J instruction format
    // the values that shouldn't matter are randomized
  function logic[31:0] imm_J(input logic[20:0] imm);
    logic[11:0] rnd;
    rnd = $urandom_range(12'd0, 12'hFFF);
    return {imm[20], imm[10:1], imm[11], imm[19:12], rnd};
  endfunction

  // takes an immediate and converts it into U instruction format
    // the values that shouldn't matter are randomized
  function logic[31:0] imm_U(input logic[19:0] imm);
    logic[11:0] rnd;
    rnd = $urandom_range(12'd0, 12'hFFF);
    return {imm, rnd};
  endfunction

  // 12 bit sign extend
 function logic[31:0] sext_12(input logic[11:0] imm);
    if(imm[11])
      return {20'hF_FFFF, imm};
    else  
      return {20'd0, imm};
  endfunction

  // 20 bit sign extend
 function logic[31:0] sext_20(input logic[19:0] imm);
    if(imm[19])
      return {12'hFFF, imm};
    else  
      return {12'd0, imm};
  endfunction

  // byte sign extend
  function logic[31:0] sext_byte(input logic[7:0] imm);
    if(imm[7])
      return {24'hFF_FFFF, imm};
    else  
      return {24'd0, imm};
  endfunction

  // half sign extend
  function logic[31:0] sext_half(input logic[15:0] imm);
    if(imm[15])
      return {16'hFFFF, imm};
    else  
      return {16'd0, imm};
  endfunction

  // inputs
  logic[31:0] A, B;
  opcode_t opcode;
  operation_t op;

  //outputs
  logic[31:0] aluout;

  Alu DUT(.A(A), .B(B), .opcode(opcode), .op(op), .aluout(aluout));

  //  TB variables

  Test tests[$];
  Test tmp;
  TestCase tcase;
  logic[31:0] imm;

  initial begin

    // OP Add Test
    tmp = new(OP, ADD, "OP Add Test");
    tmp.add(.A(32'd0), .B(32'd0), .expected(32'd0));
    tmp.add(.A(32'd1), .B(32'd1), .expected(32'd2));
    tmp.add(.A(32'd5), .B(32'd0), .expected(32'd5));
    tmp.add(.A(32'd0), .B(32'd7), .expected(32'd7));
    tmp.add(.A(32'hFFFF_FFFF), .B(32'd1), .expected(32'd0));
    tmp.add(.A(32'hFFFF_FFFF), .B(32'hFFFF_FFFF), .expected(32'hFFFF_FFFE));
    tmp.add(.A(32'h8000_0000), .B(32'h1), .expected(32'h8000_0001));
    tmp.add(.A(32'hFFFF_FFFF), .B(32'h8000_0000), .expected(32'h7FFF_FFFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = tcase.A + tcase.B;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end
    
    tests.push_back(tmp);

    // OP Sub Test
    tmp = new(OP, SUB, "OP Sub Test");
    tmp.add(.A(32'd0), .B(32'd0), .expected(32'd0));
    tmp.add(.A(32'd1), .B(32'd1), .expected(32'd0));
    tmp.add(.A(32'd5), .B(32'd0), .expected(32'd5));
    tmp.add(.A(32'd0), .B(32'd1), .expected(32'hFFFF_FFFF));
    tmp.add(.A(32'hFFFF_FFFF), .B(32'd1), .expected(32'hFFFF_FFFE));
    tmp.add(.A(32'hFFFF_FFFF), .B(32'hFFFF_FFFF), .expected(32'd0));
    tmp.add(.A(32'h8000_0000), .B(32'h1), .expected(32'h7FFF_FFFF));
    tmp.add(.A(32'hFFFF_FFFF), .B(32'h8000_0000), .expected(32'h7FFF_FFFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = tcase.A - tcase.B;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OP XOR Test
    tmp = new(OP, XOR, "OP XOR Test");
    tmp.add(.A(32'd0), .B(32'd0), .expected(32'd0));
    tmp.add(.A(32'd1), .B(32'd1), .expected(32'd0));
    tmp.add(.A(32'b101), .B(32'b10), .expected(32'b111));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = tcase.A ^ tcase.B;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OP OR Test
    tmp = new(OP, OR, "OP OR Test");
    tmp.add(.A(32'd0), .B(32'd0), .expected(32'd0));
    tmp.add(.A(32'd1), .B(32'd1), .expected(32'd1));
    tmp.add(.A(32'b101), .B(32'b10), .expected(32'b111));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = tcase.A | tcase.B;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OP AND Test
    tmp = new(OP, AND, "OP AND Test");
    tmp.add(.A(32'd0), .B(32'd0), .expected(32'd0));
    tmp.add(.A(32'd1), .B(32'd1), .expected(32'd1));
    tmp.add(.A(32'b101), .B(32'b10), .expected(32'd0));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = tcase.A & tcase.B;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OP SLL Test
    tmp = new(OP, SLL, "OP SLL Test");
    tmp.add(.A(32'd0), .B(32'd0), .expected(32'd0));
    tmp.add(.A(32'd1), .B(32'd1), .expected(32'd10));
    tmp.add(.A(32'b101), .B(32'b10), .expected(32'b10100));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = tcase.A << tcase.B[4:0];
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OP SRL Test
    tmp = new(OP, SRL, "OP SRL Test");
    tmp.add(.A(32'd0), .B(32'd0), .expected(32'd0));
    tmp.add(.A(32'd1), .B(32'd1), .expected(32'd0));
    tmp.add(.A(32'b10110), .B(32'b10), .expected(32'b101));
    tmp.add(.A(32'hFFFF_FFFF), .B(32'b10), .expected(32'h3FFF_FFFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = tcase.A >> tcase.B[4:0];
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OP SRA Test
    tmp = new(OP, SRA, "OP SRA Test");
    tmp.add(.A(32'd0), .B(32'd0), .expected(32'd0));
    tmp.add(.A(32'd1), .B(32'd1), .expected(32'd0));
    tmp.add(.A(32'b10110), .B(32'b10), .expected(32'b101));
    tmp.add(.A(32'hFFFF_FFFF), .B(32'b10), .expected(32'hFFFF_FFFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = $signed(tcase.A) >>> tcase.B[4:0];
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OP SLT Test
    tmp = new(OP, SLT, "OP SLT Test");
    tmp.add(.A(32'd0), .B(32'd0), .expected(32'd0));
    tmp.add(.A(32'd1), .B(32'd1), .expected(32'd0));
    tmp.add(.A(32'b10110), .B(32'b10), .expected(32'b0));
    tmp.add(.A(32'b101), .B(32'b10101), .expected(32'b1));
    tmp.add(.A(32'hFFFF_FFFF), .B(32'b10), .expected(32'b1));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = ($signed(tcase.A) < $signed(tcase.B)) ? 32'd1 : 32'd0;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OP SLTU Test
    tmp = new(OP, SLTU, "OP SLTU Test");
    tmp.add(.A(32'd0), .B(32'd0), .expected(32'd0));
    tmp.add(.A(32'd1), .B(32'd1), .expected(32'd0));
    tmp.add(.A(32'b10110), .B(32'b10), .expected(32'b0));
    tmp.add(.A(32'b101), .B(32'b10101), .expected(32'b1));
    tmp.add(.A(32'hFFFF_FFFF), .B(32'b10), .expected(32'b0));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = ($unsigned(tcase.A) < $unsigned(tcase.B)) ? 32'd1 : 32'd0;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    /* 
      |----------------------------------------------|
      |----------------- OPIMM Tests ----------------|
      |----------------------------------------------|
    */ 

    // OPIMM Add Test
    tmp = new(OPIMM, ADD, "OPIMM Add Test");
    tmp.add(.A(32'd0), .B(imm_I(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_I(12'd1)), .expected(32'd2));
    tmp.add(.A(32'd5), .B(imm_I(12'd0)), .expected(32'd5));
    tmp.add(.A(32'd0), .B(imm_I(12'd7)), .expected(32'd7));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_I(12'd1)), .expected(32'd0));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_I(12'hFFF)), .expected(32'hFFFF_FFFE));
    tmp.add(.A(32'h8000_0000), .B(imm_I(12'd1)), .expected(32'h8000_0001));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = sext_12($urandom_range(12'd0, 12'hFFF));
      tcase.B = imm_I(imm[11:0]);
      tcase.expected = tcase.A + imm;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end
    
    tests.push_back(tmp);

    // OPIMM XOR Test
    tmp = new(OPIMM, XOR, "OPIMM XOR Test");
    tmp.add(.A(32'd0), .B(imm_I(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_I(12'd1)), .expected(32'd0));
    tmp.add(.A(32'b101), .B(imm_I(12'b10)), .expected(32'b111));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = sext_12($urandom_range(12'd0, 12'hFFF));
      tcase.B = imm_I(imm[11:0]);
      tcase.expected = tcase.A + imm;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OPIMM OR Test
    tmp = new(OPIMM, OR, "OPIMM OR Test");
    tmp.add(.A(32'd0), .B(imm_I(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_I(12'd1)), .expected(32'd1));
    tmp.add(.A(32'b101), .B(imm_I(12'b10)), .expected(32'b111));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = sext_12($urandom_range(12'd0, 12'hFFF));
      tcase.B = imm_I(imm[11:0]);
      tcase.expected = tcase.A | imm;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OPIMM AND Test
    tmp = new(OPIMM, AND, "OPIMM AND Test");
    tmp.add(.A(32'd0), .B(imm_I(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_I(12'd1)), .expected(32'd1));
    tmp.add(.A(32'b101), .B(imm_I(12'b10)), .expected(32'd0));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = sext_12($urandom_range(12'd0, 12'hFFF));
      tcase.B = imm_I(imm[11:0]);
      tcase.expected = tcase.A & imm;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OPIMM SLL Test
    tmp = new(OPIMM, SLL, "OPIMM SLL Test");
    tmp.add(.A(32'd0), .B(imm_I(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_I(12'd1)), .expected(32'd10));
    tmp.add(.A(32'b101), .B(imm_I(12'b10)), .expected(32'b10100));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = imm_I({7'd0,imm[4:0]});
      tcase.expected = tcase.A << imm[4:0];
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OPIMM SRL Test
    tmp = new(OPIMM, SRL, "OPIMM SRL Test");
    tmp.add(.A(32'd0), .B(imm_I(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_I(12'd1)), .expected(32'd0));
    tmp.add(.A(32'b10110), .B(imm_I(12'd2)), .expected(32'b101));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_I(12'd2)), .expected(32'h3FFF_FFFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = imm_I({7'd0,imm[4:0]});
      tcase.expected = tcase.A >> imm[4:0];
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OPIMM SRA Test
    tmp = new(OPIMM, SRA, "OPIMM SRA Test");
    tmp.add(.A(32'd0), .B(imm_I(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_I(12'd1)), .expected(32'd0));
    tmp.add(.A(32'b10110), .B(imm_I(12'd2)), .expected(32'b101));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_I(12'd2)), .expected(32'hFFFF_FFFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = imm_I({7'h20,imm[4:0]});
      tcase.expected = $signed(tcase.A) >>> imm[4:0];
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OPIMM SLT Test
    tmp = new(OPIMM, SLT, "OPIMM SLT Test");
    tmp.add(.A(32'd0), .B(imm_I(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_I(12'd1)), .expected(32'd0));
    tmp.add(.A(32'b10110), .B(imm_I(12'd2)), .expected(32'b0));
    tmp.add(.A(32'b101), .B(imm_I(12'b10101)), .expected(32'b1));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_I(12'd2)), .expected(32'b1));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = imm_I(imm[11:0]);
      tcase.expected = ($signed(tcase.A) < $signed(sext_12(imm[11:0]))) ? 32'd1 : 32'd0;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // OPIMM SLTU Test
    tmp = new(OPIMM, SLTU, "OPIMM SLTU Test");
    tmp.add(.A(32'd0), .B(imm_I(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_I(12'd1)), .expected(32'd0));
    tmp.add(.A(32'b10110), .B(imm_I(12'd2)), .expected(32'b0));
    tmp.add(.A(32'b101), .B(imm_I(12'b10101)), .expected(32'b1));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_I(12'd2)), .expected(32'b0));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = imm_I(imm[11:0]);
      tcase.expected = ($unsigned(tcase.A) < $unsigned({20'd0, imm[11:0]})) ? 32'd1 : 32'd0;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    /* 
      |----------------------------------------------|
      |---------- Non Arithmetic Tests --------------|
      |----------------------------------------------|
    */ 
    

    // Load Address
    tmp = new(LOAD, operation_t'({ADDRESS, 7'd0}), "Load Address Test");
    tmp.add(.A(32'd0), .B(imm_I(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd8), .B(imm_I(12'd3)), .expected(32'd11));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_I(12'd1)), .expected(32'd0));
    tmp.add(.A(32'd0), .B(imm_I(12'hFFF)), .expected(32'hFFFF_FFFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = $urandom_range(12'd0, 12'hFFF);
      tcase.B = imm_I(imm[11:0]);
      tcase.expected = tcase.A + sext_12(imm[11:0]);
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // Load Byte
    tmp = new(LOAD, operation_t'({BYTE, 7'd0}), "Load Byte Test");
    tmp.add(.A(32'd0), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'd0));
    tmp.add(.A(32'hFF), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'hFFFF_FFFF));
    tmp.add(.A(32'hFFFF), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'hFFFF_FFFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = sext_byte(tcase.A[7:0]);
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // Load Half
    tmp = new(LOAD, operation_t'({HALF, 7'd0}), "Load Half Test");
    tmp.add(.A(32'd0), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'd0));
    tmp.add(.A(32'hFF), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'hFF));
    tmp.add(.A(32'hFFFF), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'hFFFF_FFFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = sext_half(tcase.A[15:0]);
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // Load ByteU
    tmp = new(LOAD, operation_t'({BYTEU, 7'd0}), "Load ByteU Test");
    tmp.add(.A(32'd0), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'd0));
    tmp.add(.A(32'hFF), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'hFF));
    tmp.add(.A(32'hFFFF), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'hFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = {24'd0, tcase.A[7:0]};
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // Load HalfU
    tmp = new(LOAD, operation_t'({HALFU, 7'd0}), "Load HalfU Test");
    tmp.add(.A(32'd0), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'd0));
    tmp.add(.A(32'hFF), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'hFF));
    tmp.add(.A(32'hFFFF), .B($urandom_range(32'd0, 32'hFFFF_FFFF)), .expected(32'hFFFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.B = $urandom_range(32'd0, 32'hFFFF_FFFF);
      tcase.expected = {16'd0, tcase.A[15:0]};
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // Store
    tmp = new(STORE, operation_t'(10'd0), "Store Test");
    tmp.add(.A(32'd0), .B(imm_S(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_S(12'd1)), .expected(32'd2));
    tmp.add(.A(32'd5), .B(imm_S(12'd0)), .expected(32'd5));
    tmp.add(.A(32'd0), .B(imm_S(12'd7)), .expected(32'd7));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_S(12'd1)), .expected(32'd0));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_S(12'hFFF)), .expected(32'hFFFF_FFFE));
    tmp.add(.A(32'h8000_0000), .B(imm_S(12'd1)), .expected(32'h8000_0001));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = sext_12($urandom_range(12'd0, 12'hFFF));
      tcase.B = imm_S(imm[11:0]);
      tcase.expected = tcase.A + imm;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // Branch
    tmp = new(BRANCH, operation_t'(10'd0), "BRANCH Test");
    tmp.add(.A(32'd0), .B(imm_B(13'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_B(13'd3)), .expected(32'd2));
    tmp.add(.A(32'd5), .B(imm_B(13'd0)), .expected(32'd5));
    tmp.add(.A(32'd0), .B(imm_B(13'd8)), .expected(32'd8));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_B(13'd2)), .expected(32'd1));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_B(13'h1FFE)), .expected(32'hFFFF_FFFD));
    tmp.add(.A(32'h8000_0000), .B(imm_B(13'd2)), .expected(32'h8000_0000));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = sext_12($urandom_range(12'd0, 12'hFFF) << 1);
      tcase.B = imm_B(imm[12:0]);
      tcase.expected = tcase.A + imm;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // JAL
    tmp = new(JAL, operation_t'(10'd0), "JAL Test");
    tmp.add(.A(32'd0), .B(imm_J(21'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_J(21'd2)), .expected(32'd3));
    tmp.add(.A(32'd5), .B(imm_J(21'd0)), .expected(32'd5));
    tmp.add(.A(32'd0), .B(imm_J(21'd8)), .expected(32'd8));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_J(21'd2)), .expected(32'd1));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_J(21'h1F_FFFE)), .expected(32'hFFFF_FFFD));
    tmp.add(.A(32'h8000_0000), .B(imm_J(21'd2)), .expected(32'h8000_0000));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = sext_20($urandom_range(20'd0, 20'hFFF) << 1);
      tcase.B = imm_J(imm[20:0]);
      tcase.expected = tcase.A + imm;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // JALR
    tmp = new(JALR, operation_t'(10'd0), "JALR Test");
    tmp.add(.A(32'd0), .B(imm_I(12'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_I(12'd1)), .expected(32'd2));
    tmp.add(.A(32'd5), .B(imm_I(12'd0)), .expected(32'd5));
    tmp.add(.A(32'd0), .B(imm_I(12'd7)), .expected(32'd7));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_I(12'd1)), .expected(32'd0));
    tmp.add(.A(32'hFFFF_FFFF), .B(imm_I(12'hFFF)), .expected(32'hFFFF_FFFE));
    tmp.add(.A(32'h8000_0000), .B(imm_I(12'd1)), .expected(32'h8000_0001));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = sext_12($urandom_range(12'd0, 12'hFFF));
      tcase.B = imm_I(imm[11:0]);
      tcase.expected = tcase.A + imm;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    //LUI
    tmp = new(LUI, operation_t'(10'd0), "LUI Test");
    tmp.add(.A($urandom_range(32'd0, 32'hFFFF_FFFF)), .B(imm_U(20'd0)), .expected(32'd0));
    tmp.add(.A($urandom_range(32'd0, 32'hFFFF_FFFF)), .B(imm_U(20'd1)), .expected(32'h1000));
    tmp.add(.A($urandom_range(32'd0, 32'hFFFF_FFFF)), .B(imm_U(20'hF_FFFF)), .expected(32'hFFFF_F000));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = $urandom_range(20'd0, 20'hF_FFFF);
      tcase.B = imm_U(imm[19:0]);
      tcase.expected = imm[19:0] << 12;
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // AUIPC
    tmp = new(AUIPC, operation_t'(10'd0), "AUIPC Test");
    tmp.add(.A(32'd0), .B(imm_U(20'd0)), .expected(32'd0));
    tmp.add(.A(32'd1), .B(imm_U(20'd1)), .expected(32'h1001));
    tmp.add(.A(32'hFFF), .B(imm_U(20'hF_FFFF)), .expected(32'hFFFF_FFFF));

    repeat(100) begin
      tcase = new();
      tcase.A = $urandom_range(32'd0, 32'hFFFF_FFFF);
      imm = $urandom_range(20'd0, 20'hF_FFFF);
      tcase.B = imm_U(imm[19:0]);
      tcase.expected = tcase.A + (imm[19:0] << 12);
      tmp.add(.A(tcase.A), .B(tcase.B), .expected(tcase.expected));
    end

    tests.push_back(tmp);

    // Run Tests
    while (tests.size() > 0) begin
      tmp = tests.pop_front();
      tmp.run(.A(A), .B(B), .opcode(opcode), .op(op));
    end

    // Print Summary
    Test::summarize();

    #10;
    $finish;
  end

  logic clock;

  initial begin
    clock = 1;
    forever begin
      #1 clock = ~clock;
    end
  end

  bit isknown = ~$isunknown({opcode, op, A, B});

  property slt_is_1or0;
    @(edge clock) isknown && (opcode == OP || opcode == OPIMM) && (op == SLT || op == SLTU) |-> 
      (aluout == 32'd0 || aluout == 32'd1);
  endproperty

  asrt_slt_is1or0: assert property(slt_is_1or0)
    else begin
      $display("SLT operation had a non 1 or 0 result at time %d", $time);
    end
endmodule
