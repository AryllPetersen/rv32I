`default_nettype none;

module ControlUnit_tb();


  typedef enum bit {
    PRINT = 1'b0,
    DONT_PRINT = 1'b1
  } print_t;

  class TestCase;

    // Inputs
    rand ir_R_t ir;
    rand logic AltB, AeqB;

    // Expected Outputs
    rand pcsel_t pcsel;
    rand irsel_t irsel; 
    rand regsel_t regsel;
    rand logic regen;
    rand alusel0_t alusel0;
    rand alusel1_t alusel1;
    rand operation_t op;
    rand logic we, re;
    rand addrsel_t addrsel;
    rand rs1sel_t rs1sel;
    rand tmpsel_t tmpsel;
    rand dataoutsel_t dataoutsel;
    rand logic un_signed;

    

    // which outputs don't matter
    rand bit dontCare_pcsel;
    rand bit dontCare_irsel; 
    rand bit dontCare_regsel;
    rand bit dontCare_regen;
    rand bit dontCare_alusel0;
    rand bit dontCare_alusel1;
    rand bit dontCare_op;
    rand bit dontCare_op_bits_6to0;
    rand bit dontCare_we, dontCare_re;
    rand bit dontCare_addrsel;
    rand bit dontCare_rs1sel;
    rand bit dontCare_tmpsel;
    rand bit dontCare_dataoutsel;
    rand bit dontCare_un_signed;

    // when resetBefore = 1, will reset ControlUnit before this test case is run
    logic resetBefore;
    opcode_t opcode;
    state_t state;

    constraint keep_opcode {
      ir.opcode == opcode;
    }

    constraint fetch{
      if(state == FETCH) {
        pcsel == PCSEL_PLUS4;
        irsel == IRSEL_MEM;
        //regsel Dont Care
        regen == 1'b0;
        //alusel0 Dont Care
        //alusel1 Dont Care
        //op Dont Care
        we == 1'b0;
        re == 1'b1;
        addrsel == ADDRSEL_PC;
        //rs1sel Dont Care
        //tmpsel Dont Care
        //dataoutsel Dont Care 
        //un_signed Dont Care


        dontCare_pcsel == 1'b0;
        dontCare_irsel == 1'b0; 
        dontCare_regsel == 1'b1;
        dontCare_regen == 1'b0;
        dontCare_alusel0 == 1'b1;
        dontCare_alusel1 == 1'b1;
        dontCare_op == 1'b1;
        dontCare_op_bits_6to0 == 1'b1;
        dontCare_we == 1'b0; 
        dontCare_re == 1'b0;
        dontCare_addrsel == 1'b0;
        dontCare_rs1sel == 1'b1;
        dontCare_tmpsel == 1'b1;
        dontCare_dataoutsel == 1'b1;
        dontCare_un_signed == 1'b1;
      }
    }

    constraint op_inst {
      if(opcode == OP && state == PART1) {
        {ir.funct3, ir.funct7} inside {
          ADD, SUB, XOR, OR, AND, SLL, 
          SRL, SRA, SLT, SLTU
        };
        pcsel == PCSEL_PLUS4;
        irsel == IRSEL_MEM;
        regsel == REGSEL_ALU;
        regen == 1'b1;
        alusel0 == ALUSEL0_REG;
        alusel1 == ALUSEL1_REG;
        op == operation_t'({ir.funct3, ir.funct7});
        we == 1'b0;
        re == 1'b1;
        addrsel == ADDRSEL_PC;
        rs1sel == RS1;
        //tmpsel Dont Care
        //dataoutsel Dont Care 
        //un_signed Dont Care

        dontCare_pcsel == 1'b0;
        dontCare_irsel == 1'b0; 
        dontCare_regsel == 1'b0;
        dontCare_regen == 1'b0;
        dontCare_alusel0 == 1'b0;
        dontCare_alusel1 == 1'b0;
        dontCare_op == 1'b0;
        dontCare_op_bits_6to0 == 1'b0;
        dontCare_we == 1'b0; 
        dontCare_re == 1'b0;
        dontCare_addrsel == 1'b0;
        dontCare_rs1sel == 1'b0;
        dontCare_tmpsel == 1'b1;
        dontCare_dataoutsel == 1'b1;
        dontCare_un_signed == 1'b1;
      }
    };

    constraint opimm_inst {
      if(opcode == OPIMM && state == PART1) {
        ir.funct3 inside {
          ADD[9:7], XOR[9:7], OR[9:7], AND[9:7], SLL[9:7], 
          SRL[9:7], SRA[9:7], SLT[9:7], SLTU[9:7]
        };

        if(ir.funct3 inside {SLL[9:7], SRL[9:7]}) {
          ir.funct7 == 7'd0;
        }

        if(ir.funct3 inside {SRA[9:7]}) {
          ir.funct7 == 7'h20;
        }

        pcsel == PCSEL_PLUS4;
        irsel == IRSEL_MEM;
        regsel == REGSEL_ALU;
        regen == 1'b1;
        alusel0 == ALUSEL0_REG;
        alusel1 == ALUSEL1_IR;
        op == operation_t'({ir.funct3, ir.funct7});
        we == 1'b0;
        re == 1'b1;
        addrsel == ADDRSEL_PC;
        rs1sel == RS1;
        //tmpsel Dont Care
        //dataoutsel Dont Care 
        //un_signed Dont Care

        dontCare_pcsel == 1'b0;
        dontCare_irsel == 1'b0; 
        dontCare_regsel == 1'b0;
        dontCare_regen == 1'b0;
        dontCare_alusel0 == 1'b0;
        dontCare_alusel1 == 1'b0;
        dontCare_op == 1'b0;
        dontCare_op_bits_6to0 == (ir.funct3 inside {
          ADD[9:7], XOR[9:7], OR[9:7], AND[9:7],
          SLT[9:7], SLTU[9:7]
        });
        dontCare_we == 1'b0; 
        dontCare_re == 1'b0;
        dontCare_addrsel == 1'b0;
        dontCare_rs1sel == 1'b0;
        dontCare_tmpsel == 1'b1;
        dontCare_dataoutsel == 1'b1;
        dontCare_un_signed == 1'b1;
      }
    };

    constraint load_inst {
      if(opcode == LOAD) {
        ir.funct3 inside {BYTE, HALF, WORD, BYTEU, HALFU};
        if(state == PART1) {
          pcsel == PCSEL_PC;
          irsel == IRSEL_IR;
          regsel == REGSEL_MEM;
          regen == 1'b1;
          alusel0 == ALUSEL0_REG;
          alusel1 == ALUSEL1_IR;
          op[9:7] == ADDRESS;
          we == 1'b0;
          re == 1'b1;
          addrsel == ADDRSEL_ALU;
          rs1sel == RS1;
          //tmpsel Dont Care
          //dataoutsel Dont Care 
          //un_signed Dont Care

          dontCare_pcsel == 1'b0;
          dontCare_irsel == 1'b0; 
          dontCare_regsel == 1'b0;
          dontCare_regen == 1'b0;
          dontCare_alusel0 == 1'b0;
          dontCare_alusel1 == 1'b0;
          dontCare_op == 1'b0;
          dontCare_op_bits_6to0 == 1'b1;
          dontCare_we == 1'b0; 
          dontCare_re == 1'b0;
          dontCare_addrsel == 1'b0;
          dontCare_rs1sel == 1'b0;
          dontCare_tmpsel == 1'b1;
          dontCare_dataoutsel == 1'b1;
          dontCare_un_signed == 1'b1;
        }
        if(state == PART2) {
          pcsel == PCSEL_PLUS4;
          irsel == IRSEL_MEM;
          regsel == REGSEL_ALU;
          regen == 1'b1;
          alusel0 == ALUSEL0_REG;
          //alusel1 Don't Care
          op[9:7] == ir.funct3;
          we == 1'b0;
          re == 1'b1;
          addrsel == ADDRSEL_PC;
          rs1sel == RSD;
          //tmpsel Dont Care
          //dataoutsel Dont Care 
          //un_signed Dont Care

          dontCare_pcsel == 1'b0;
          dontCare_irsel == 1'b0; 
          dontCare_regsel == 1'b0;
          dontCare_regen == 1'b0;
          dontCare_alusel0 == 1'b0;
          dontCare_alusel1 == 1'b1;
          dontCare_op == 1'b0;
          dontCare_op_bits_6to0 == 1'b1;
          dontCare_we == 1'b0; 
          dontCare_re == 1'b0;
          dontCare_addrsel == 1'b0;
          dontCare_rs1sel == 1'b0;
          dontCare_tmpsel == 1'b1;
          dontCare_dataoutsel == 1'b1;
          dontCare_un_signed == 1'b1;
        }
      }
    };

    constraint store_inst {
      if(opcode == STORE && state inside {PART1, PART2}) {
        ir.funct3 inside {BYTE, HALF, WORD};
        if(ir.funct3 == WORD && state == PART1) {
          pcsel == PCSEL_PC;
          irsel == IRSEL_IR;
          //regsel Dont Care
          regen == 1'b0;
          alusel0 == ALUSEL0_REG;
          alusel1 == ALUSEL1_IR;
          //op Dont Care
          we == 1'b1;
          re == 1'b0;
          addrsel == ADDRSEL_ALU;
          rs1sel == RS1;
          //tmpsel Dont Care
          dataoutsel == DATAOUTSEL_REG;
          //un_signed Dont Care

          dontCare_pcsel        == 1'b0;
          dontCare_irsel        == 1'b0; 
          dontCare_regsel       == 1'b1;
          dontCare_regen        == 1'b0;
          dontCare_alusel0      == 1'b0;
          dontCare_alusel1      == 1'b0;
          dontCare_op           == 1'b1;
          dontCare_op_bits_6to0 == 1'b1;
          dontCare_we           == 1'b0; 
          dontCare_re           == 1'b0;
          dontCare_addrsel      == 1'b0;
          dontCare_rs1sel       == 1'b0;
          dontCare_tmpsel       == 1'b1;
          dontCare_dataoutsel   == 1'b0;
          dontCare_un_signed    == 1'b1;
        } else if(ir.funct3 inside {BYTE, HALF}) {
          if(state == PART1) {
            pcsel == PCSEL_PC;
            irsel == IRSEL_IR;
            //regsel Dont Care
            regen == 1'b0;
            alusel0 == ALUSEL0_REG;
            alusel1 == ALUSEL1_IR;
            //op Dont Care
            we == 1'b0;
            re == 1'b1;
            addrsel == ADDRSEL_ALU;
            rs1sel == RS1;
            tmpsel == (ir.funct3 == BYTE) ? TMPSEL_BYTE : TMPSEL_HALF;
            //dataoutsel Dont Care
            //un_signed Dont Care

            dontCare_pcsel        == 1'b0;
            dontCare_irsel        == 1'b0; 
            dontCare_regsel       == 1'b1;
            dontCare_regen        == 1'b0;
            dontCare_alusel0      == 1'b0;
            dontCare_alusel1      == 1'b0;
            dontCare_op           == 1'b1;
            dontCare_op_bits_6to0 == 1'b1;
            dontCare_we           == 1'b0; 
            dontCare_re           == 1'b0;
            dontCare_addrsel      == 1'b0;
            dontCare_rs1sel       == 1'b0;
            dontCare_tmpsel       == 1'b0;
            dontCare_dataoutsel   == 1'b1;
            dontCare_un_signed    == 1'b1;
          }
          if(state == PART2) {
            pcsel == PCSEL_PC;
            irsel == IRSEL_IR;
            //regsel Dont Care
            regen == 1'b0;
            alusel0 == ALUSEL0_REG;
            alusel1 == ALUSEL1_IR;
            //op Dont Care
            we == 1'b1;
            re == 1'b0;
            addrsel == ADDRSEL_ALU;
            rs1sel == RS1;
            //tmpsel Dont Care
            dataoutsel == DATAOUTSEL_TMP;
            //un_signed Dont Care

            dontCare_pcsel        == 1'b0;
            dontCare_irsel        == 1'b0; 
            dontCare_regsel       == 1'b1;
            dontCare_regen        == 1'b0;
            dontCare_alusel0      == 1'b0;
            dontCare_alusel1      == 1'b0;
            dontCare_op           == 1'b1;
            dontCare_op_bits_6to0 == 1'b1;
            dontCare_we           == 1'b0; 
            dontCare_re           == 1'b0;
            dontCare_addrsel      == 1'b0;
            dontCare_rs1sel       == 1'b0;
            dontCare_tmpsel       == 1'b1;
            dontCare_dataoutsel   == 1'b0;
            dontCare_un_signed    == 1'b1;
          }
        }
      }
    }

    constraint branch_inst {
      if(opcode == BRANCH && state == PART1) {
        ir.funct3 inside {
          BEQ, BNE, BLT, BGE,
          BLTU, BGEU 
        };

        if(AeqB) {
          AltB == 1'b0;
        }

        if(AeqB) {
          pcsel == ((ir.funct3 inside {BEQ, BGE, BGEU}) ? PCSEL_ALU : PCSEL_PLUS4);
          addrsel == ((ir.funct3 inside {BEQ, BGE, BGEU}) ? ADDRSEL_ALU : ADDRSEL_PC);
        } else if(~AltB){
          pcsel == ((ir.funct3 inside {BNE, BGE, BGEU}) ? PCSEL_ALU : PCSEL_PLUS4);
          addrsel == ((ir.funct3 inside {BNE, BGE, BGEU}) ? ADDRSEL_ALU : ADDRSEL_PC);
        } else {
          pcsel == ((ir.funct3 inside {BNE, BLT, BLTU}) ? PCSEL_ALU : PCSEL_PLUS4);
          addrsel == ((ir.funct3 inside {BNE, BLT, BLTU}) ? ADDRSEL_ALU : ADDRSEL_PC);
        }

        irsel == IRSEL_MEM;
        //regsel Dont Care
        regen == 1'b0;
        alusel0 == ALUSEL0_PC;
        alusel1 == ALUSEL1_IR;
        //op Dont Care
        we == 1'b0;
        re == 1'b1;
        rs1sel == RS1;
        //tmpsel Dont Care
        //dataoutsel Dont Care
        un_signed == (ir.funct3 inside {BGEU, BLTU});

        dontCare_pcsel        == 1'b0;
        dontCare_irsel        == 1'b0; 
        dontCare_regsel       == 1'b1;
        dontCare_regen        == 1'b0;
        dontCare_alusel0      == 1'b0;
        dontCare_alusel1      == 1'b0;
        dontCare_op           == 1'b1;
        dontCare_op_bits_6to0 == 1'b1;
        dontCare_we           == 1'b0; 
        dontCare_re           == 1'b0;
        dontCare_addrsel      == 1'b0;
        dontCare_rs1sel       == 1'b0;
        dontCare_tmpsel       == 1'b1;
        dontCare_dataoutsel   == 1'b1;
        dontCare_un_signed    == 1'b0;
      }
    }

    constraint jal_inst {
      if(state == PART1) {
        if(opcode == JALR) {
          ir.funct3 == 3'd0;
        }
        if(opcode inside {JAL, JALR}) {
          pcsel == PCSEL_ALU;
          irsel == IRSEL_MEM;
          regsel == REGSEL_PLUS4;
          regen == 1'b1;
          alusel0 == (opcode == JAL) ? ALUSEL0_PC : ALUSEL0_REG;
          alusel1 == ALUSEL1_IR;
          //op Dont Care
          we == 1'b0;
          re == 1'b1;
          addrsel == ADDRSEL_ALU;
          rs1sel == RS1;
          //tmpsel Dont Care
          //dataoutsel Dont Care
          //un_signed Dont Care

          dontCare_pcsel        == 1'b0;
          dontCare_irsel        == 1'b0; 
          dontCare_regsel       == 1'b0;
          dontCare_regen        == 1'b0;
          dontCare_alusel0      == 1'b0;
          dontCare_alusel1      == 1'b0;
          dontCare_op           == 1'b1;
          dontCare_op_bits_6to0 == 1'b1;
          dontCare_we           == 1'b0; 
          dontCare_re           == 1'b0;
          dontCare_addrsel      == 1'b0;
          dontCare_rs1sel       == (opcode == JAL);
          dontCare_tmpsel       == 1'b1;
          dontCare_dataoutsel   == 1'b1;
          dontCare_un_signed    == 1'b1; 
        }   
      }  
    }

    constraint lui_inst {
      if(state == PART1 && (opcode == LUI || opcode == AUIPC)) {
        pcsel == PCSEL_PLUS4;
        irsel == IRSEL_MEM;
        regsel == REGSEL_ALU;
        regen == 1'b1;
        alusel0 == ALUSEL0_PC;
        alusel1 == ALUSEL1_IR;
        //op Dont Care
        we == 1'b0;
        re == 1'b1;
        addrsel == ADDRSEL_PC;
        //rs1sel Dont Care
        //tmpsel Dont Care
        //dataoutsel Dont Care
        //un_signed Dont Care

        dontCare_pcsel        == 1'b0;
        dontCare_irsel        == 1'b0; 
        dontCare_regsel       == 1'b0;
        dontCare_regen        == 1'b0;
        dontCare_alusel0      == (opcode == LUI);
        dontCare_alusel1      == 1'b0;
        dontCare_op           == 1'b1;
        dontCare_op_bits_6to0 == 1'b1;
        dontCare_we           == 1'b0; 
        dontCare_re           == 1'b0;
        dontCare_addrsel      == 1'b0;
        dontCare_rs1sel       == 1'b1;
        dontCare_tmpsel       == 1'b1;
        dontCare_dataoutsel   == 1'b1;
        dontCare_un_signed    == 1'b1; 
      }
    }
    
    // constructor
    function new(opcode_t opcode);
      this.opcode = opcode;
      this.resetBefore = 1;
      this.state = PART1;
    endfunction

    task driveInputs();

      if(resetBefore) begin
        @(posedge clock); 
        $root.ControlUnit_tb.resetn <= 0;
        if(state != FETCH) begin
          @(posedge clock); // XX -> FETCH
          $root.ControlUnit_tb.resetn <= 1;
        end
      end

      @(posedge clock); // FETCH -> PART1
      $root.ControlUnit_tb.resetn <= 1;
      $root.ControlUnit_tb.ir <= this.ir;
      $root.ControlUnit_tb.AeqB <= this.AeqB;
      $root.ControlUnit_tb.AltB <= this.AltB;

    endtask

    function bit isCorrect(print_t print);
      bit correct;
      bit giveMsg;
      string val_str;
      string expected_str;
      string name_str;

      giveMsg = (print == PRINT);
      correct = 1'b1;

      if(giveMsg) begin
        $display("\n%s at time = %d", irStr(), $time);
      end

      if(out_has_x) begin
        $display("FAILED: DUT is displaying X values");
        return 1'b0;
      end

      if(~dontCare_pcsel) begin
        val_str = $root.ControlUnit_tb.pcsel.name;
        expected_str = this.pcsel.name;
        name_str = "pcsel";
        if($root.ControlUnit_tb.pcsel != this.pcsel) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_irsel) begin
        val_str = $root.ControlUnit_tb.irsel.name;
        expected_str = this.irsel.name;
        name_str = "irsel";
        if($root.ControlUnit_tb.irsel != this.irsel) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_regsel) begin
        val_str = $root.ControlUnit_tb.regsel.name;
        expected_str = this.regsel.name;
        name_str = "regsel";
        if($root.ControlUnit_tb.regsel != this.regsel) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_regen) begin
        val_str.bintoa($root.ControlUnit_tb.regen);
        expected_str.bintoa(this.regen);
        name_str = "regen";
        if($root.ControlUnit_tb.regen != this.regen) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_alusel0) begin
        val_str = $root.ControlUnit_tb.alusel0.name;
        expected_str = this.alusel0.name;
        name_str = "alusel0";
        if($root.ControlUnit_tb.alusel0 != this.alusel0) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_alusel1) begin
        val_str = $root.ControlUnit_tb.alusel1.name;
        expected_str = this.alusel1.name;
        name_str = "alusel1";
        if($root.ControlUnit_tb.alusel1 != this.alusel1) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_op) begin
        if(~dontCare_op_bits_6to0) begin
          val_str.bintoa($root.ControlUnit_tb.op);
          expected_str.bintoa(this.op);
          name_str = "op";
          if($root.ControlUnit_tb.op != this.op) begin
            correct = 1'b0;
            if(giveMsg) failedMsg(name_str, val_str, expected_str);
          end else begin
            if(giveMsg) passedMsg(name_str, val_str);
          end
        end else begin
          val_str.bintoa($root.ControlUnit_tb.op[9:7]);
          expected_str.bintoa(this.op[9:7]);
          name_str = "op[9:7]";
          if($root.ControlUnit_tb.op[9:7] != this.op[9:7]) begin
            correct = 1'b0;
            if(giveMsg) failedMsg(name_str, val_str, expected_str);
          end else begin
            if(giveMsg) passedMsg(name_str, val_str);
          end
        end
      end
      if(~dontCare_we) begin
        val_str.bintoa($root.ControlUnit_tb.we);
        expected_str.bintoa(this.we);
        name_str = "we";
        if($root.ControlUnit_tb.we != this.we) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_re) begin
        val_str.bintoa($root.ControlUnit_tb.re);
        expected_str.bintoa(this.re);
        name_str = "re";
        if($root.ControlUnit_tb.re != this.re) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_addrsel) begin
        val_str = $root.ControlUnit_tb.addrsel.name;
        expected_str = this.addrsel.name;
        name_str = "addrsel";
        if($root.ControlUnit_tb.addrsel != this.addrsel) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_rs1sel) begin
        val_str = $root.ControlUnit_tb.rs1sel.name;
        expected_str = this.rs1sel.name;
        name_str = "rs1sel";
        if($root.ControlUnit_tb.rs1sel != this.rs1sel) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_tmpsel) begin
        val_str = $root.ControlUnit_tb.tmpsel.name;
        expected_str = this.tmpsel.name;
        name_str = "tmpsel";
        if($root.ControlUnit_tb.tmpsel != this.tmpsel) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_dataoutsel) begin
        val_str = $root.ControlUnit_tb.dataoutsel.name;
        expected_str = this.dataoutsel.name;
        name_str = "dataoutsel";
        if($root.ControlUnit_tb.dataoutsel != this.dataoutsel) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      if(~dontCare_un_signed) begin
        val_str.bintoa($root.ControlUnit_tb.un_signed);
        expected_str.bintoa(this.un_signed);
        name_str = "un_signed";
        if($root.ControlUnit_tb.un_signed != this.un_signed) begin
          correct = 1'b0;
          if(giveMsg) failedMsg(name_str, val_str, expected_str);
        end else begin
          if(giveMsg) passedMsg(name_str, val_str);
        end
      end
      return correct;
    endfunction

    function void failedMsg(string varname, string value, string expected);
      $display("FAILED: %s = %s, expected: %s", varname, value, expected);
    endfunction

    function void passedMsg(string varname, string value);
      $display("PASSED: %s = %s", varname, value);
    endfunction

    function string irStr();
      string funct3, funct7, irstr;
      funct3.bintoa(ir.funct3);
      funct7.bintoa(ir.funct7);
      irstr.hextoa(ir);
      return {"ir = ",irstr,", opcode = ",opcode.name,", expected state = ",state.name,
        "\nir.funct3 = ",funct3,", funct7 = ",funct7};
    endfunction

    function void disableInputRandomization();
      this.ir.rand_mode(0);
      this.AeqB.rand_mode(0);
      this.AltB.rand_mode(0);
    endfunction

    function void enableInputRandomization();
      this.ir.rand_mode(1);
      this.AeqB.rand_mode(1);
      this.AltB.rand_mode(1);
    endfunction

  endclass

  class Test;
    string name;
    TestCase cases[$];
    int num_cases;
    int num_failed;

    static string failed_queue[$];
    static string passed_queue[$];
    static int total_tests = 0;
    static int tests_failed = 0;

    function new(string name);
      this.name = name;
      this.num_cases = 0;
      this.num_failed = 0;
      total_tests++;
    endfunction

    // add test case to queue
    function void add(TestCase t);
      this.num_cases++;
      cases.push_back(t);
    endfunction

    task run();
      TestCase t;
      bit isCorrect;

      this.num_failed = 0;
      $display("\n\n <---------- %s ---------->\n\n", this.name);

      while(cases.size() > 0) begin
        t = cases.pop_front();
        t.driveInputs();

        #1;

        if(~t.isCorrect(PRINT)) begin
          num_failed++;
        end
      end

      if(this.num_failed > 0) begin
        $display("\n%d Test Cases Failed Out of %d.", num_failed, num_cases);
        failed_queue.push_back(this.name);
        tests_failed++;
      end else begin
        $display("\n All Test Cases Passed for %s.", this.name);
        passed_queue.push_back(this.name);
      end

    endtask

    static function void summarize();
      $display("\n|------------------------|\n",
               "|-----ALU TB SUMMARY-----|\n",
               "|------------------------|\n",
               "Total Tests Ran: %d\n", total_tests,
               "Tests With No Errors: %d\n", total_tests - tests_failed,
               "Tests That Failed: %d\n", tests_failed
      );
      if(passed_queue.size() > 0) begin
        $display("Successful Tests:\n");
        while(passed_queue.size() > 0) begin
          $display(" - %s", passed_queue.pop_front());
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

  // Inputs
  logic clock, resetn;
  ir_R_t ir;
  logic AltB, AeqB;

  // Outputs
  pcsel_t pcsel;
  irsel_t irsel; 
  regsel_t regsel;
  logic regen;
  alusel0_t alusel0;
  alusel1_t alusel1;
  operation_t op;
  logic we, re;
  addrsel_t addrsel;
  rs1sel_t rs1sel;
  tmpsel_t tmpsel;
  dataoutsel_t dataoutsel;
  logic un_signed;

  ControlUnit DUT(.*);

  // TB variables
  Test test_queue[$];
  Test test;
  TestCase tcase;
  parameter NUM_RAND_TESTS = 1000;
  parameter TIMEOUT = 1000000;
  logic abort;
  logic out_has_x;
  opcode_t opcode_rand;

  assign out_has_x = $isunknown({pcsel, irsel, regsel, regen, alusel0, 
    alusel1, op, we, re, addrsel, rs1sel, tmpsel, dataoutsel, un_signed});

  initial begin
    repeat(TIMEOUT) #1;

    $display("Test Bench Timed out at T = %d", $time);
    $finish;
  end

  initial begin
    clock = 0;
    resetn = 0;
    forever #5 clock = ~clock;
  end

  initial begin
    abort = 0;
    opcode_rand = OP;

    test = new("Fetch Test");
    repeat(10) begin
      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = FETCH;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize Fetch");
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("OP Test");
    repeat(NUM_RAND_TESTS) begin
      tcase = new(OP);
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize OP");
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("OPIMM Test");
    repeat(NUM_RAND_TESTS) begin
      tcase = new(OPIMM);
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize OPIMM");
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("LOAD Test");
    repeat(NUM_RAND_TESTS) begin
      tcase = new(LOAD);
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize LOAD");
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("STORE Test");
    repeat(NUM_RAND_TESTS) begin
      tcase = new(STORE);
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize STORE");
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("BRANCH Test");
    repeat(NUM_RAND_TESTS) begin
      tcase = new(BRANCH);
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize BRANCH");
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("LUI Test");
    repeat(NUM_RAND_TESTS) begin
      tcase = new(LUI);
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize LUI");
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("AUIPC Test");
    repeat(NUM_RAND_TESTS) begin
      tcase = new(AUIPC);
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize AUIPC");
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("JAL Test");
    repeat(NUM_RAND_TESTS) begin
      tcase = new(JAL);
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize JAL");
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("JALR Test");
    repeat(NUM_RAND_TESTS) begin
      tcase = new(JALR);
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize JALR");
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("FETCH -> OP Transition Test");
    repeat(NUM_RAND_TESTS) begin
      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = FETCH;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize FETCH -> OP Transition Test");
        abort = 1;
        break;
      end
      test.add(tcase);

      tcase = new(OP);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize FETCH -> OP Transition Test");
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("FETCH -> OPIMM Transition Test");
    repeat(NUM_RAND_TESTS) begin
      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = FETCH;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      tcase = new(OPIMM);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("FETCH -> LOAD1 -> LOAD2 -> (Random Instruction) Transition Test");
    opcode_rand = OP;
    repeat(NUM_RAND_TESTS) begin
      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = FETCH;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      tcase = new(LOAD);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      tcase = new tcase;
      tcase.state = PART2;
      tcase.resetBefore = 0;
      tcase.disableInputRandomization();
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new("FETCH -> STORE1 -> STORE2 -> FETCH Transition Test");
    repeat(NUM_RAND_TESTS) begin
      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = FETCH;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      tcase = new(STORE);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      if(tcase.ir.funct3 != WORD) begin
        tcase = new tcase;
        tcase.state = PART2;
        tcase.disableInputRandomization();
        tcase.resetBefore = 0;
        if(tcase.randomize() == 0) begin
          $error("Failed to randomize %s", test.name);
          abort = 1;
          break;
        end
        test.add(tcase);
      end

      tcase = new tcase;
      tcase.state = FETCH;
      tcase.disableInputRandomization();
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new ("FETCH -> BRANCH -> (Random Instruction) Transition Test");
    repeat(NUM_RAND_TESTS) begin
      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = FETCH;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      tcase = new(BRANCH);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new ("FETCH -> JAL -> (Random Instruction) Transition Test");
    repeat(NUM_RAND_TESTS) begin
      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = FETCH;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      tcase = new(JAL);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new ("FETCH -> JALR -> (Random Instruction) Transition Test");
    repeat(NUM_RAND_TESTS) begin
      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = FETCH;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      tcase = new(JALR);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new ("FETCH -> LUI -> (Random Instruction) Transition Test");
    repeat(NUM_RAND_TESTS) begin
      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = FETCH;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      tcase = new(LUI);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);

    test = new ("FETCH -> AUIPC -> (Random Instruction) Transition Test");
    repeat(NUM_RAND_TESTS) begin
      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = FETCH;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      tcase = new(AUIPC);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);

      opcode_rand = opcode_rand.next($urandom());
      tcase = new(opcode_rand);
      tcase.state = PART1;
      tcase.resetBefore = 0;
      if(tcase.randomize() == 0) begin
        $error("Failed to randomize %s", test.name);
        abort = 1;
        break;
      end
      test.add(tcase);
    end
    test_queue.push_back(test);


    if(abort) $finish;

    while(test_queue.size() > 0) begin
      test = test_queue.pop_front();
      test.run();
    end

    Test::summarize();

    #10;
    $finish;
  end

endmodule
