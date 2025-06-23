typedef enum logic[6:0] {
  OP      = 7'b0110011,
  OPIMM   = 7'b0010011,
  LOAD    = 7'b0000011,
  STORE   = 7'b0100011,
  BRANCH  = 7'b1100011,
  JAL     = 7'b1101111,
  JALR    = 7'b1100111,
  LUI     = 7'b0110111,
  AUIPC   = 7'b0010111
} opcode_t;

typedef enum logic[1:0] {
  PCSEL_PC = 2'h0,
  PCSEL_PLUS4 = 2'h1,
  PCSEL_ALU = 2'h2
} pcsel_t;

typedef enum logic {
  IRSEL_IR = 1'b0,
  IRSEL_MEM = 1'b1
} irsel_t;

typedef enum logic[1:0] {
  REGSEL_ALU = 2'h0,
  REGSEL_MEM = 2'h1,
  REGSEL_PLUS4 = 2'h2
} regsel_t;

typedef enum logic {
  ALUSEL0_REG = 1'b0,
  ALUSEL0_PC = 1'b1
} alusel0_t;

typedef enum logic {
  ALUSEL1_REG = 1'b0,
  ALUSEL1_IR = 1'b1
} alusel1_t;

typedef enum logic {
  ADDRSEL_PC = 1'b0,
  ADDRSEL_ALU = 1'b1
} addrsel_t;

typedef struct packed {
  logic[6:0] funct7;
  logic[4:0] rs2;
  logic[4:0] rs1;
  logic[2:0] funct3;
  logic[4:0] rd;
  opcode_t  opcode;
} ir_R_t;

typedef struct packed {
  logic[11:0] imm;
  logic[4:0] rs1;
  logic[2:0] funct3;
  logic[4:0] rd;
  opcode_t  opcode;
} ir_I_t;

typedef struct packed {
  logic[6:0] imm1;
  logic[4:0] rs2;
  logic[4:0] rs1;
  logic[2:0] funct3;
  logic[4:0] imm0;
  opcode_t  opcode;
} ir_S_t;

typedef struct packed {
  logic[19:0] imm;
  logic[4:0] rd;
  opcode_t opcode;
} ir_U_t;

typedef enum logic[3:0] {
  ADD,
  SUB,
  XOR,
  OR,
  AND,
  SLL,
  SRL,
  SRA,
  SLT,
  SLTU
} operations_t;

typedef struct packed {
  opcode_t opcode;
  logic[2:0] funct3;
  logic[6:0] funct7;
} instruction_t;


