`include "util.v"
`include "getters.v"
`include "control_unit.v"
`include "alu.v"
  /* реализованны следующие инструкции (тесты которые находятся в репозитори на гитхабе, все проходят верно):
  R-type:+    I-type:+     J-type:+
  -add        -addi        -jump (j)
  -sub        -lw          -jal 
  -and        -sw
  -or         -beq
  -slt        -bne
              -andi
  */
module mips_cpu(clk, pc, pc_new, instruction_memory_a, instruction_memory_rd, data_memory_a, data_memory_rd, data_memory_we, data_memory_wd,
                register_a1, register_a2, register_a3, register_we3, register_wd3, register_rd1, register_rd2);
  // сигнал синхронизации
  input clk;
  // текущее значение регистра PC
  inout [31:0] pc;
  // новое значение регистра PC (адрес следующей команды)
  output [31:0] pc_new;
  // we для памяти данных
  output data_memory_we;
  // адреса памяти и данные для записи памяти данных
  output [31:0] instruction_memory_a, data_memory_a, data_memory_wd;
  // данные, полученные в результате чтения из памяти
  inout [31:0] instruction_memory_rd, data_memory_rd;
  // we3 для регистрового файла
  output register_we3;
  // номера регистров
  output [4:0] register_a1, register_a2, register_a3;
  // данные для записи в регистровый файл
  output [31:0] register_wd3;
  // данные, полученные в результате чтения из регистрового файла
  inout [31:0] register_rd1, register_rd2;

  // TODO: implementation
  wire [31:0] PCplus4;
  //сразу определим значение переменной PCplus4
  adder adder1(pc, 4, PCplus4);

  assign instruction_memory_a = pc;

  wire branch; //beq
  wire ALUsrc;
  wire Zero;
  wire memToReg;
  wire BNE; //bne
  wire PCsrc;
  wire branchZero;
  wire bneNotZero;
  wire jump;

  wire [5:0] opcode;
  wire [5:0] funct;

  wire [4:0] rd_r_type;
  wire [4:0] register_a2_copy; // для mux2_5, т.к. нужно в инпут его!
  wire [15:0] imm;
  // wire [27:0] addr_J_type;
  wire [31:0] extend_addr_J_type;
  wire [31:0] extend_imm;
  wire [31:0] shifted_extend_imm; //поменял на signed
  wire [31:0] SrcB;
  wire [31:0] SrcA;
  wire [31:0] jump_addr;
  wire [31:0] PCbranch;
  wire [2:0] ALUControl;
  wire [31:0] curr_PC;
  wire negativeZero;
  wire resBEQ;
  wire resBNE;
  wire jal;
  wire help_jal;
  //получаем opcode
  get_op get_op1(instruction_memory_rd, opcode);
  //получаем funct
  get_funct get_funct1(instruction_memory_rd, funct);
  //определяем нужные флажки
  control_unit control_unit1(opcode, funct, memToReg, data_memory_we, branch, ALUsrc, regDst, register_we3, ALUControl, jump, BNE, jal, help_jal);
  //находим register_a1  
  get_register_a1 get_register_a1_1(instruction_memory_rd, register_a1);
  //находим register_a1
  get_register_a2 get_register_a2_1(instruction_memory_rd, register_a2);
  //определяем rd
  f15_to11 f15_to11_1(instruction_memory_rd, rd_r_type);
  //определяем что идет в register_a3
  wire [4:0] tmp_register_a3;
  mux2_5 mux2_5_first(register_a2, rd_r_type, regDst, tmp_register_a3);
  mux2_5 mux2_5_idk(tmp_register_a3, 5'b11111, help_jal, register_a3);
  // always @(*) begin
  //   if (jal == 1'b0) begin
  //     register_a3 <= tmp_register_a3;
  //   end
  //   else begin
  //     register_a3 <= 5'b11111;
  //   end
  // end
  //находим imm
  get_imm get_imm_1(instruction_memory_rd, imm);
  //расширяем его до 32 бит
  sign_extend sign_extend1(imm, extend_imm);
  //сдвигаем влево на 2 бита
  shl_2 shl_2_1(extend_imm, shifted_extend_imm);
  //складываем полученные результат с PCplus4
  adder adder2(shifted_extend_imm, PCplus4, PCbranch);
  //определяем SrcB
  mux2_32 mux2_32_first(register_rd2, extend_imm, ALUsrc, SrcB);
  //создадим переменную aluRes
  wire [31:0] aluRes;
  //определяем значение aluRes
  alu alu1(register_rd1, SrcB, ALUControl, aluRes, Zero); /// ПРОБЛМАВЫАЫАЫАВЫ
  //находим data_memory_a и data_memory_wd
  assign data_memory_a = aluRes;
  assign data_memory_wd = register_rd2;
  //определяем что идет в register_wd3
  wire [31:0] temp_wd3;
  mux2_32 mux2_32_fourth(aluRes, data_memory_rd, memToReg, temp_wd3);//поменял data_memory_a на aluRes
  mux2_32 mux2_32_five(temp_wd3, PCplus4, jal, register_wd3);
  //определяем адрес для jump
  // get_addr_J_type get_addr_J_type1(instruction_memory_rd, addr_J_type);
  //расширяем его и сдвигаем
  wire [25:0] addr_J_type;
  // assign addr_J_type = instruction_memory_rd;
 //передадим саму инструкцию, так будет удобнее просто
  get_addr_J_type get_addr_J_type_1(instruction_memory_rd, addr_J_type);

  jump_addr_create jump_addr_create1(addr_J_type, jump_addr);
  // initial begin
  //   #1;
  //   $monitor("jump_addr=%b, instr=%b", jump_addr, instruction_memory_rd);
  // end
  invert invert1(Zero, negativeZero);

  assign resBEQ = Zero & branch;
  // assign resBEQ = 0;
  assign resBNE = negativeZero & BNE;
  assign PCsrc = resBEQ | resBNE;

  mux2_32 mux2_32_second(PCplus4, PCbranch, PCsrc, curr_PC);
  // initial begin
  //   #1;
  //   $monitor(memToReg);
  // end
  
  mux2_32 mux2_32_third(curr_PC, jump_addr, jump, pc_new);

  initial begin
  //   $dumpfile("./dump.vcd");
  //   $dumpvars;
  // end
  // initial begin
  //   #2;
  //   // $monitor("jmp_addr=%b, pc_new=%b, register_a3=%d, instrc_rd=%b", jump_addr, pc_new, register_a3, instruction_memory_rd);
    $monitor("pc_new = %d, register_a1=%d, r=%d", pc_new, register_a3);
  //   // $monitor("opcode=%b, funct=%b, zero=%d, resBEQ=%d, PCsrc=%d, resBNE=%d, PCplus4=%d, ext_imm=%d, PCbranch=%d=%d", opcode, funct, Zero, resBEQ, PCsrc, resBNE, PCplus4, shifted_extend_imm, PCbranch, curr_PC);
  //   // $display("opcode=%b, funct=%b, memToReg=%d, data_memory_we=%d, branch=%d, ALUsrc=%d, regDst=%d, register_we3=%d, ALUControl=%b, jump=%d, BNE=%d", opcode, funct, memToReg, data_memory_we, branch, ALUsrc, regDst, register_we3, ALUControl, jump, BNE);
    // $monitor("opcode=%b, data_we=%b, register_we3=%b, register_a1=%d, register_a2=%d, register_a3=%d, register_wd3=%d, data_memory_a=%d, data_memory_rd=%d, pc_new=%d", opcode, data_memory_we, register_we3 , register_a1,   register_a2,   register_a3,   register_wd3,   data_memory_a,   data_memory_rd, pc_new);
  end
  // assign resBEQ = 0;
  // assign PCsrc = 0;

endmodule
