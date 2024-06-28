//модуль, вычелинающий биты из инструкции с 15 по 0.
module get_imm(a, b);
  input [31:0] a;
  output [15:0] b;
  assign b = a[15:0];
endmodule
//модуль, вычелинающий биты из инструкции с 25 по 21.
module get_register_a1(a, b);
  input [31:0] a;
  output [4:0] b;
  assign b = a[25:21];
endmodule
//модуль, вычелинающий из инструкции opcode.
module get_op(a, b);
  input [31:0] a;
  output [5:0] b;
  assign b = a[31:26];
endmodule
//модуль, вычелинающий из инструкции funct.
module get_funct(a, b);
  input [31:0] a;
  output [5:0] b;
  assign b = a[5:0];
endmodule
//модуль, вычелинающий биты из инструкции с 21 по 16.
module get_register_a2(a, b);
  input [31:0] a;
  output [4:0] b;
  assign b = a[20:16];
endmodule 
//модуль, вычелинающий биты из инструкции с 15 по 11.
module f15_to11(a, b);
  input [31:0] a;
  output [4:0] b; 
  assign b = a[15:11];
endmodule
//модуль, вычелинающий биты из инструкции с 25 по 0.
module get_addr_J_type(a, b); //для jump
    input [31:0] a;
    output [25:0] b;
    assign b = a[25:0];
endmodule
//когда выполнил shl_2 для адреса jump, то нужно еще добавить 31-28 биты из PC + 4 (Реализую jumpAddress).
module jump_addr_create(extend_toJump, jumpAdress);
    input [25:0] extend_toJump;
    // input [31:0] pcPlus4;
    output reg [31:0] jumpAdress;
    integer i;
    integer j;
    always @(*) begin //не придумал как сделать через срезы для обоих.
        jumpAdress[0] = 0;
        jumpAdress[1] = 0;
        for (i = 2; i < 28; i = i + 1) begin
            jumpAdress[i] <= extend_toJump[i - 2];
            // $display(i);
        end
        jumpAdress[28] = 0;
        jumpAdress[29] = 0;
        jumpAdress[30] = 0;
        jumpAdress[31] = 0;
        #5;
        // $monitor("jmpAddr=%b, pc_4=%b, ex=%b", jumpAdress, pcPlus4, extend_toJump);
        // $monitor("pc_4=%b", pcPlus4);
        // $monitor("extend=%b", extend_toJump); 
    end
endmodule
//инвертируем бит (для BNE)
module invert(a, out);
  input a;
  output out;
  assign out = ~a;
endmodule

module or_real(a, b, out);
  
endmodule