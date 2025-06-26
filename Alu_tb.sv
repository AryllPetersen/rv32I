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
      end else begin
        $display("\n%d Test Cases Failed out of %d\n", error_count, test_cases);
      end

    endtask

    static function void summarize();
      $display("|------------------------|\n",
               "|-----ALU TB SUMMARY-----|\n",
               "|------------------------|\n",
               "Total Tests Ran: %d\n", total_tests,
               "Tests With No Errors: %d\n", successful_tests
      );
    endfunction
  endclass

  // inputs
  logic[31:0] A, B;
  opcode_t opcode;
  operation_t op;

  //outputs
  logic[31:0] aluout;

  Alu DUT(.A(A), .B(B), .opcode(opcode), .op(op), .aluout(aluout));

  Test tests[$];
  Test tmp;
  TestCase tcase;
  

  initial begin

    tmp = new(OP, ADD, "Add Test");
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



    while (tests.size() > 0) begin
      tmp = tests.pop_front();
      tmp.run(.A(A), .B(B), .opcode(opcode), .op(op));
    end

    Test::summarize();

    #10;
    $finish;
  end
endmodule
