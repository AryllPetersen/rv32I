typedef enum logic[1:0] {
  PC = 2'h0,
  PLUS4, 2'h1,
  ALU, 2'h2
} pcsel_t;

typedef enum logic {
  IR = 1'b0,
  MEM = 1'b1
} irsel_t;

typedef enum logic {
  ALU = 1'b0,
  MEM = 1'b1,
} regsel_t;

typedef enum logic {
  REG = 1'b0,
  PC = 1'b1,
} alusel0_t;

typedef enum logic {
  REG = 1'b0,
  IR = 1'b1,
} alusel1_t;

typedef enum logic {
  PC = 1'b0,
  ALU = 1'b1,
} addrsel_t;

typedef struct packed {
  logic[6:0] funct7,
  logic[4:0] rs2,
  logic[4:0] rs1,
  logic[2:0] funct3,
  logic[4:0] rd,
  logic[6:0] opcode
} ir_R_t;

typedef struct packed {
  logic[11:0] imm,
  logic[4:0] rs1,
  logic[2:0] funct3,
  logic[4:0] rd,
  logic[6:0] opcode
} ir_I_t;

typedef struct packed {
  logic[6:0] imm1,
  logic[4:0] rs2,
  logic[4:0] rs1,
  logic[2:0] funct3,
  logic[4:0] imm0,
  logic[6:0] opcode
} ir_S_t;

typedef struct packed {
  logic[19:0] imm,
  logic[4:0] rd,
  logic[6:0] opcode
} ir_U_t;

typedef enum logic {
  ADD,
  SUB,
  XOR,
  OR,
  AND,
  SLL,
  SRL
  SRA,
  SLT,
  SLTU,
} op;

