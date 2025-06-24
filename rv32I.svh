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

typedef enum logic[2:0] {
  BYTE  = 3'h0,
  HALF  = 3'h1,
  WORD  = 3'h2,
  BYTEU = 3'h4,
  HALFU = 3'h5
} load_t;

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

typedef enum logic[9:0] {
  ADD   = {3'h0, 7'h00},
  SUB   = {3'h0, 7'h20},
  XOR   = {3'h4, 7'h00},
  OR    = {3'h6, 7'h00},
  AND   = {3'h7, 7'h00},
  SLL   = {3'h1, 7'h00},
  SRL   = {3'h5, 7'h00},
  SRA   = {3'h5, 7'h20},
  SLT   = {3'h2, 7'h00},
  SLTU  = {3'h3, 7'h00}
} operation_t;

typedef enum logic {
  RS1 = 1'b0,
  RSD = 1'b1
} rs1sel_t;

typedef enum logic {
  TMPSEL_BYTE = 1'b0,
  TMPSEL_HALF = 1'b1
} tmpsel_t;

typedef enum logic[1:0] {
  DATAOUTSEL_ALU = 2'h0,
  DATAOUTSEL_TMP = 2'h1,
  DATAOUTSEL_REG = 2'h2
} dataoutsel_t;

typedef enum logic[2:0] {
  BEQ = 3'h0,
  BNE = 3'h1,
  BLT = 3'h4,
  BGE = 3'h5,
  BLTU = 3'h6,
  BGEU = 3'h7
} branch_t;

