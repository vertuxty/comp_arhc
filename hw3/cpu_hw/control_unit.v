// Реализация control_unit.
module control_unit(opcode, funct, memToReg, memWrite, branch, ALUsrc, regDst, regWrite, ALUControl, jump, branchNot, jal, help_jal);
    input [5:0] opcode;
    input [5:0] funct;
    output reg memToReg, memWrite, branch, ALUsrc, regDst, regWrite, jump, branchNot, jal, help_jal;
    output reg [2:0] ALUControl;
    reg [1:0] ALUop;
    always @(*) begin
      #1;
      if (opcode == 0) begin //R-type
        help_jal = 1'b0;
        // branchNot <= 1'b0;
        regWrite = 1'b1;
        regDst = 1'b1;
        ALUsrc = 1'b0;
        branch = 1'b0;
        memWrite = 1'b0;
        memToReg = 1'b0;
        // memToReg <= 2'b00; //fix
        ALUop = 2'b10;
        jump = 1'b0;
        jal = 1'b0;
      end
      if (opcode == 6'b100011) begin //lw
        // branchNot <= 1'b0;
        help_jal = 1'b0;
        // $display("lw MEM");
        regWrite = 1'b1;
        regDst = 1'b0;
        ALUsrc = 1'b1;
        branch = 1'b0;
        memWrite = 1'b0;
        memToReg = 1'b1;
        // memToReg <= 2'b01; //fix &&&
        ALUop = 2'b00;
        jump = 1'b0;
        jal = 1'b0;
      end
      if (opcode == 6'b101011) begin //sw
        // branchNot <= 1'b0;////
        help_jal = 1'b0;
        // $monitor("sw MEM");
        memToReg = 1'b0;
        // memToReg <=2'b00; //fix &&&
        regDst = 1'b0;
        // branchNot <= 1'b0;///////
        regWrite = 1'b0;
        ALUsrc = 1'b1;
        branch = 1'b0;
        memWrite = 1'b1;
        ALUop = 2'b00;
        jump = 1'b0;
        jal = 1'b0;
      end
      if (opcode == 6'b000100) begin //beq
        help_jal = 1'b0;
        // $display("beq");
        branchNot = 1'b0;
        regWrite = 1'b0;
        ALUsrc = 1'b0;
        branch = 1'b1;
        memWrite = 1'b0;
        ALUop = 2'b01;
        jal = 1'b0;
        jump = 1'b0;
      end
      if (opcode == 6'b000010) begin //для jump все делаем 0, кроме самого jump
        // branchNot <= 1'b0;
        help_jal = 1'b0;
        // branch <=1'b0;
        regWrite = 1'b0;
        memWrite = 1'b0;
        jal = 1'b0;
        jump = 1'b1;
      end
      if (opcode == 6'b001000) begin //addi
        help_jal = 1'b0;
        branchNot = 1'b0;
        // $monitor("addi AHAHHAH");
        ALUsrc = 1'b1;
        jal = 1'b0;
        regWrite = 1'b1;
        // memToReg <= 2'b00; //fix?
        memToReg = 1'b0;
        regDst = 1'b0;
        memWrite = 1'b0;
        branch = 1'b0;
        jump = 1'b0;
        jal = 1'b0;
        ALUop = 2'b00;
      end
      if (opcode == 6'b001100) begin //andi
        branchNot = 1'b0;
        help_jal = 1'b0;
        ALUsrc = 1'b1;//
        regWrite = 1'b1;//
        // memToReg <= 2'b00; //fix &&&
        memToReg = 1'b0;//
        regDst = 1'b0;//
        memWrite = 1'b0;//
        branch = 1'b0;//
        jump = 1'b0;
        jal = 1'b0;
        ALUop =2'b11;
        ALUControl = 3'b000;
        // ALUop <= 2'b01;
      end
      if (opcode == 6'b000101) begin //bne
        branchNot = 1'b1;
        help_jal = 1'b0;
        jump = 1'b0;
        branch = 1'b0;
        ALUop = 2'b01;
        memWrite = 1'b0;
        ALUsrc = 1'b0;
        regWrite = 1'b0;
        jal = 1'b0;
      end
      if (opcode == 6'b	000011) begin
        jal = 1'b1;
        jump = 1'b1;
        regWrite = 1'b1;
        memWrite = 1'b0;
        help_jal = 1'b1;

        memToReg = 1'b0; //любой, пусть будет 0.
      end
      #1;
      if (ALUop == 2'b00) begin // add
        ALUControl = 3'b010;
      end
      if (ALUop == 2'b01) begin // sub
        ALUControl = 3'b110;
      end
      if (ALUop == 2'b10) begin
        if (funct == 6'b100000) begin // add
            // $display("add");
            ALUControl = 3'b010;
        end
        if (funct == 6'b100010) begin // sub
            // $display("sub");
            ALUControl = 3'b110;
        end
        if (funct == 6'b100100) begin // and
            ALUControl = 3'b000;
        end
        if (funct == 6'b100101) begin // or
            ALUControl = 3'b001;
        end
        if (funct == 6'b101010) begin // slt
            ALUControl = 3'b111;
        end
      end
      #1;
    end
endmodule
// module control_unit(opcode, funct, memToReg, memWrite, Branch, ALUSrc, regDST, RegWrite, ALUControl, jump, BNE, jal, help_jal);
//     input [5:0] opcode;
//     input [5:0] funct;
//     output reg memToReg, memWrite, Branch, ALUSrc, regDST, RegWrite, BNE, jal, help_jal, jump;
//     output reg [2:0] ALUControl;
//     always @(*) begin
//         #1;
//         if (opcode == 6'b100011) begin //lw
//             RegWrite = 1'b1;
//             regDST = 1'b0;
//             ALUSrc = 1'b1;
//             Branch = 1'b0;
//             memWrite = 1'b0;
//             memToReg = 1'b1;
//             ALUControl = 3'b010;
//         end

//         if (opcode == 6'b101011) begin
//             RegWrite = 1'b0;
//             ALUSrc = 1'b1;
//             Branch = 1'b0;
//             memWrite = 1'b1;
//             ALUControl = 3'b010;
//         end

//         if (opcode == 6'b000100) begin
//             RegWrite = 1'b0;
//             ALUSrc = 1'b0;
//             Branch = 1'b1;
//             memWrite = 1'b0;
//             ALUControl = 3'b110;
//         end


//         if (opcode == 6'b000000) begin //R-type
//             RegWrite <= 1'b1;
//             regDST <= 1'b1;
//             ALUSrc <= 1'b0;
//             Branch <= 1'b0;
//             memWrite <= 1'b0;
//             memToReg <= 1'b0;

//             if (funct == 6'b100000) begin //add
//                 ALUControl <= 3'b010;
//             end
            
//             if (funct == 6'b100010) begin
//                 ALUControl <= 3'b110;
//             end

//             if (funct == 6'b100100) begin
//                 ALUControl <= 3'b000;
//             end

//             if (funct == 6'b100101) begin
//                 ALUControl <= 3'b001;
//             end

//             if (funct == 6'b101010) begin
//                 ALUControl <= 3'b111;
//             end
//         end

//         if (opcode == 6'b001000) begin //addi
//             ALUSrc <= 1'b1;
//             RegWrite <= 1'b1;
//             memToReg <= 1'b0;
//             regDST <= 1'b0;
//             memWrite <= 1'b0;
//             Branch <= 1'b0;
//             ALUControl <= 3'b010;
//         end

//         if (opcode == 6'b001100) begin //andi - те же флаги что и в addi, кроме алу кнтрола, тут использовать ALUcontrol = 3'b000;
//             ALUSrc <= 1'b1;
//             RegWrite <= 1'b1;
//             memToReg <= 1'b0;
//             regDST <= 1'b0;
//             memWrite <= 1'b0;
//             Branch <= 1'b0;
//             ALUControl <= 3'b000;
//         end
//         #1;
//     end
// endmodule