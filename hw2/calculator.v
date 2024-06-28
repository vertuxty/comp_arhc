module alu(a, b, control, res); //за что такие лабы на 600+ строк... интересно конечно делать, прикольно, но больно...
  input [3:0] a, b; // Операнды
  input [2:0] control; // Управляющие сигналы для выбора операции

  output[3:0] res; // Результат

  wire [3:0] suma;
  wire [3:0] diff;
  wire [3:0] andOfAB;
  wire [3:0] orOfAB;
  wire [3:0] AorNotB;
  wire [3:0] AandNotB;
  wire [3:0] sltRes;
  wire Cout1;
  wire Cout2;

  and_4_byte and_4_byte1(a, b, andOfAB); // a & b
  or_4_byte or_4_byte1(a, b, orOfAB);// a | b
  summator_of_4_bytes sm1(a, b, 1'b0, suma, Cout1); // a + b
  Subtractor Subtractor1(a, b, 1'b0, diff, Cout2); // a - b
  and_with_one_not and_with_one_not1(a, b, AandNotB); // a & !b
  or_with_one_not or_with_one_not1(a, b, AorNotB); // a | !b
  slt slt1(a, b, sltRes); // if a < b: 1 else: 0

  mux_8_1 mux(andOfAB, orOfAB, suma, 4'b0000, AandNotB, AorNotB, diff, sltRes, control, res); //мультиплексор
  // TODO: implementation
endmodule

module d_latch(clk, d, we, q);
  input clk; // Сигнал синхронизации
  input d; // Бит для записи в ячейку
  input we; // Необходимо ли перезаписать содержимое ячейки

  output reg q; // Сама ячейка
  // Изначально в ячейке хранится 0
  initial begin
    q <= 0;
  end
  // Значение изменяется на переданное на спаде сигнала синхронизации
  always @ (negedge clk) begin
    if (we) begin
      q <= d;
    end
  end
endmodule

module register_file(clk, rd_addr, we_addr, we_data, rd_data);
  input clk; // Сигнал синхронизации
  input [1:0] rd_addr, we_addr; // Номера регистров для чтения и записи
  input [3:0] we_data; // Данные для записи в регистровый файл
  output [3:0] rd_data; // Данные, полученные в результате чтения из регистрового файла
//номера регистров
  wire [1:0] register1 = 2'b00; //первый
  wire [1:0] register2 = 2'b01; //второй и тд
  wire [1:0] register3 = 2'b10; 
  wire [1:0] register4 = 2'b11;

  wire w1; // значение 0/1 записывать или нет в фаил
  wire w2;
  wire w3;
  wire w4;

  //данные считаные из регистров
  wire [3:0] read1;
  wire [3:0] read2;
  wire [3:0] read3;
  wire [3:0] read4;

  //ищем w_i
  w_in_register w1r(register1, we_addr, w1);
  w_in_register w2r(register2, we_addr, w2);
  w_in_register w3r(register3, we_addr, w3);
  w_in_register w4r(register4, we_addr, w4);

  register r1(clk, w1, we_data, read1); //первый регистр
  register r2(clk, w2, we_data, read2); //второй регистр
  register r3(clk, w3, we_data, read3); //третий регистр
  register r4(clk, w4, we_data, read4); //четвертый регистр

  mux4_1 mux4_1(rd_addr, read1, read2, read3, read4, rd_data); //мультиплексор для вывода считаных данных

  // TODO: implementation
endmodule

module calculator(clk, rd_addr, immediate, we_addr, control, rd_data);
  input clk; // Сигнал синхронизации
  input [1:0] rd_addr; // Номер регистра, из которого берется значение первого операнда
  input [3:0] immediate; // Целочисленная константа, выступающая вторым операндом
  input [1:0] we_addr; // Номер регистра, куда производится запись результата операции
  input [2:0] control; // Управляющие сигналы для выбора операции
  output signed [3:0] rd_data; // Данные из регистра c номером 'rd_addr', подающиеся на выход
  wire signed [3:0] res1;
  wire signed [3:0] res;
  // assign rd_data = 4'b0000;
  alu alu1(res1, immediate, control, res);
  register_file rg1(clk, rd_addr, we_addr, res, res1);
  assign rd_data = res1;
  // TODO: implementation
endmodule

module register(clk, we, we_data, rd_data); //регистр в размере одной штуки
  input clk;
  input we;
  input signed [3:0] we_data;
  input [1:0] rd_addr;
  output signed [3:0] rd_data;
  wire q1;
  wire q2;
  wire q3;
  wire q4;
  d_latch d_latch5(clk, we_data[0], we, q1); //1 бит
  d_latch d_latch6(clk, we_data[1], we, q2); //2 бит
  d_latch d_latch7(clk, we_data[2], we, q3); //3 бит
  d_latch d_latch8(clk, we_data[3], we, q4); //4 бит
  assign rd_data[0] = q1;
  assign rd_data[1] = q2;
  assign rd_data[2] = q3;
  assign rd_data[3] = q4;
endmodule

module w_in_register(a, b, out); //для нахождения w1 в регистре
  input signed [1:0] a;
  input signed [1:0] b;
  output out;
  wire Cout1;
  wire Cout2;
  wire or1;
  wire [1:0] c;
  wire [1:0] d;
  wire [1:0] f;
  wire not_b0;
  wire not_b1;

  not_gate not_gate1(b[0], not_b0);
  not_gate not_gate2(b[1], not_b1);

  assign c[0] = not_b0;
  assign c[1] = not_b1;

  summator_of_2_bytes sum1(c, 2'b01, 1'b0, d, Cout1);
  summator_of_2_bytes sum2(a, d, 1'b0, f, Cout2);

  or_gate or_gate3(f[0], f[1], or1);
  not_gate not_gate3(or1, out);
endmodule

module mux4_1(control, s0, s1, s2, s3, out); //для регистров сделал отдельный мультиплексор... ну а что, главное работает)
  input [1:0] control;
  input signed [3:0] s0;
  input signed [3:0] s1;
  input signed [3:0] s2;
  input signed [3:0] s3;

  output signed [3:0] out;
  wire [3:0] first_control_bit;
  wire [3:0] second_control_bit;
  wire [3:0] negativeFirst;
  wire [3:0] negativeSecond;

  wire [3:0] and_1;
  wire [3:0] and_2;
  wire [3:0] and_3;
  wire [3:0] and_4;

  wire [3:0] s0_;
  wire [3:0] s1_;
  wire [3:0] s2_;
  wire [3:0] s3_;

  wire [3:0] or1;
  wire [3:0] or2;

  assign first_control_bit[0] = control[0];
  assign first_control_bit[1] = control[0];
  assign first_control_bit[2] = control[0];
  assign first_control_bit[3] = control[0];

  assign second_control_bit[0] = control[1];
  assign second_control_bit[1] = control[1];
  assign second_control_bit[2] = control[1];
  assign second_control_bit[3] = control[1];

  not_4_byte not1(first_control_bit, negativeFirst);
  not_4_byte not2(second_control_bit, negativeSecond);

  and_4_byte and00(negativeFirst, negativeSecond, and_1);
  and_4_byte and00_(and_1, s0, s0_);

  and_4_byte and01(negativeSecond, first_control_bit, and_2);
  and_4_byte and01_(and_2, s1, s1_);

  and_4_byte and10(second_control_bit, negativeFirst, and_3);
  and_4_byte and10_(and_3, s2, s2_);

  and_4_byte and11(first_control_bit, second_control_bit, and_4);
  and_4_byte and11_(and_4, s3, s3_);

  or_4_byte or_4_byte1(s0_, s1_, or1);
  or_4_byte or_4_byte2(s2_, s3_, or2);
  or_4_byte or_4_byte3(or1, or2, out);

endmodule

module not_gate(in, out);

  input wire in;
  output wire out;

  supply1 vdd;
  supply0 gnd; 

  pmos pmos1(out, vdd, in);
  nmos nmos1(out, gnd, in);
endmodule

module nand_gate(in1, in2, out);
  input wire in1;
  input wire in2;
  output wire out;

  supply0 gnd;
  supply1 pwr;

  wire nmos1_out;

  pmos pmos1(out, pwr, in1);
  pmos pmos2(out, pwr, in2);
  nmos nmos1(nmos1_out, gnd, in1);
  nmos nmos2(out, nmos1_out, in2);
endmodule

module nor_gate(in1, in2, out);
  input wire in1;
  input wire in2;
  output wire out;

  supply0 gnd;
  supply1 pwr;

  wire pmos1_out;

  pmos pmos1(pmos1_out, pwr, in1);
  pmos pmos2(out, pmos1_out, in2);
  nmos nmos1(out, gnd, in1);
  nmos nmos2(out, gnd, in2);
endmodule

module and_gate(in1, in2, out);
  input wire in1;
  input wire in2;
  output wire out;

  wire nand_out;

  nand_gate nand_gate1(in1, in2, nand_out);
  not_gate not_gate1(nand_out, out);
endmodule

module or_gate(in1, in2, out);
  input wire in1;
  input wire in2;
  output wire out;

  wire nor_out;

  nor_gate nor_gate1(in1, in2, nor_out);
  not_gate not_gate1(nor_out, out);
endmodule

module xor_gate(in1, in2, out);
  input wire in1;
  input wire in2;
  output wire out;

  wire not_in1;
  wire not_in2;

  wire and_out1;
  wire and_out2;

  wire or_out1;

  not_gate not_gate1(in1, not_in1);
  not_gate not_gate2(in2, not_in2);

  and_gate and_gate1(in1, not_in2, and_out1);
  and_gate and_gate2(not_in1, in2, and_out2);

  or_gate or_gate1(and_out1, and_out2, out);
endmodule

module and_4_byte(a, b, out); //Реализация AND для 4-х битных чисел;
  input signed [3:0] a;
  input signed [3:0] b;
  output wire signed [3:0] out;
  reg c = 1;
  reg e = 0;
  wire o1;
  wire o2;
  wire o3;
  wire o4;

  wire a0;
  wire a1;
  wire a2;
  wire a3;

  and_gate and_gate0(c, e, i);
  and_gate and_gate1(a[0], b[0], o1);
  and_gate and_gate2(a[1], b[1], o2);
  and_gate and_gate3(a[2], b[2], o3);
  and_gate and_gate4(a[3], b[3], o4);
  assign out[0] = o1;
  assign out[1] = o2;
  assign out[2] = o3;
  assign out[3] = o4;

endmodule

module or_4_byte(a, b, out); //Реализация OR для 4-х битных чисел;
  input signed [3:0] a;
  input signed [3:0] b;
  output signed [3:0] out;

  wire out_or_1;
  wire out_or_2;
  wire out_or_3;
  wire out_or_4;
  
  or_gate or_gate1(a[0], b[0], out_or_1);
  or_gate or_gate2(a[1], b[1], out_or_2);
  or_gate or_gate3(a[2], b[2], out_or_3);
  or_gate or_gate4(a[3], b[3], out_or_4);

  assign out[0] = out_or_1;
  assign out[1] = out_or_2;
  assign out[2] = out_or_3;
  assign out[3] = out_or_4;
endmodule

module not_4_byte(a, out); //Реализация !a для 4-х битных чисел;
  input signed [3:0] a;
  output signed [3:0] out;
  wire out_not_1;
  wire out_not_2;
  wire out_not_3;
  wire out_not_4;
  not_gate not_gate1(a[0], out_not_1);
  not_gate not_gate2(a[1], out_not_2);
  not_gate not_gate3(a[2], out_not_3);
  not_gate not_gate4(a[3], out_not_4);

  assign out[0] = out_not_1;
  assign out[1] = out_not_2;
  assign out[2] = out_not_3;
  assign out[3] = out_not_4;

endmodule

module and_with_one_not(a, b, out); //Реализация a & !b для 4-х битных чисел;
  input signed [3:0] a;
  input signed [3:0] b;
  output signed [3:0] out;

  wire [3:0] not_b;

  not_4_byte not_4_byte1(b, not_b);
  and_4_byte and_4_byte1(a, not_b, out);
endmodule

module or_with_one_not(a, b, out); //Реализация a | !b для 4-х битных чисел;
  input signed [3:0] a;
  input signed [3:0] b;
  output signed [3:0] out;

  wire [3:0] not_b;

  not_4_byte not_4_byte1(b, not_b);
  or_4_byte or_4_byte1(a, not_b, out);
endmodule

module summator_of_2_bytes(a, b, Cin, s, Cout);
  input signed [1:0] a;
  input signed [1:0] b;
  input Cin;
  output signed [1:0] s;
  output Cout;

  wire Cout1;
  wire Cout2;

  wire out0;
  wire out1;

  fullSummator f1(a[0], b[0], Cin, out0, Cout1);
  fullSummator f2(a[1], b[1], Cout1, out1, Cout2);

  assign s[0] = out0;
  assign s[1] = out1;
endmodule

module summator_of_4_bytes(a, b, Cin, s, Cout); //Реализация сумматора для 4-х битных чисел.
  input signed [3:0] a;
  input signed [3:0] b;
  input Cin;
  output signed [3:0] s;
  output Cout;
  wire Cout1;
  wire Cout2;
  wire Cout3;

  wire out0;
  wire out1;
  wire out2;
  wire out3;

  fullSummator f1(a[0], b[0], Cin, out0, Cout1);
  fullSummator f2(a[1], b[1], Cout1, out1, Cout2);
  fullSummator f3(a[2], b[2], Cout2, out2, Cout3);
  fullSummator f4(a[3], b[3], Cout3, out3, Cout);

  assign s[0] = out0;
  assign s[1] = out1;
  assign s[2] = out2;
  assign s[3] = out3;

endmodule

module fullSummator(a, b, Cin, s, Cout); //Реализация полного сумматора.
  input a;
  input b;
  input Cin;

  output s;
  output Cout;

  wire xor_out_1;
  wire and_out_1;
  wire and_out_2;

  xor_gate xor_gate1(a, b, xor_out_1);

  and_gate and_gate1(a, b, and_out_1);
  and_gate and_gate2(xor_out_1, Cin, and_out_2);
  or_gate or_gate1(and_out_1, and_out_2, Cout);
  xor_gate xor_gate2(Cin, xor_out_1, s);
endmodule

module Subtractor(a, b, Cin, s, Cout); //Реализация вычетателя на основе сумматора.
  input signed [3:0] a;
  input signed [3:0] b;
  input Cin;

  output signed [3:0] s;
  output Cout;

  wire signed [3:0] not_b;
  wire signed [3:0] dSum;
  wire dCout;

  not_4_byte not_4_byte1(b, not_b);

  summator_of_4_bytes f1(not_b, 4'b0001, 1'b0, dSum, dCout);
  summator_of_4_bytes f2(a, dSum, 1'b0, s, Cout);
endmodule

module slt(a, b, out); //Реализация SLT:)));
  input signed [3:0] a;
  input signed [3:0] b;
  output wire [3:0] out;

  output wire [3:0] s;
  wire signed [4:0] A_5b = 5'b00000;
  wire signed [4:0] B_5b = 5'b00000;
  wire nb0;
  wire nb1;
  wire nb2;
  wire nb3;
  wire a3=a[3];
  wire a4=a[3];
  assign A_5b[0] = a[0];
  assign A_5b[1] = a[1];
  assign A_5b[2] = a[2];
  assign A_5b[3] = a3;
  assign A_5b[4] = a4;
  not_gate n1(b[0], nb0);
  not_gate n2(b[1], nb1);
  not_gate n3(b[2], nb2);
  not_gate n4(b[3], nb3);
  assign B_5b[0] = nb0;
  assign B_5b[1] = nb1;
  assign B_5b[2] = nb2;
  assign B_5b[3] = nb3;
  assign B_5b[4] = nb3;

  wire out0;
  wire out1;
  wire out2;
  wire out3;
  wire out4;

  fullSummator f1(nb0, 1'b1, 1'b0, out0, Cout1);
  fullSummator f2(nb1, 1'b0, Cout1, out1, Cout2);
  fullSummator f3(nb2, 1'b0, Cout2, out2, Cout3);
  fullSummator f4(nb3, 1'b0, Cout3, out3, Cout4);
  fullSummator f4_(nb3, 1'b0, Cout4, out4, Cout);

  fullSummator f5(a[0], out0, 1'b0, out_0, Cout_1);
  fullSummator f6(a[1], out1, Cout_1, out_1, Cout_2);
  fullSummator f7(a[2], out2, Cout_2, out_2, Cout_3);
  fullSummator f8(a[3], out3, Cout_3, out_3, Cout_4);
  fullSummator f9(a[3], out4, Cout_4, out_4, Cout_);

  assign out[0] = out_4;
  assign out[1] = 1'b0;
  assign out[2] = 1'b0;
  assign out[3] = 1'b0;
endmodule

module mux_8_1(s0, s1, s2, s3, s4, s5, s6, s7, control, out); //Мультиплексор для АЛУ) Правда круто?)
  input [3:0] s0;
  input [3:0] s1;
  input [3:0] s2;
  input [3:0] s3;
  input [3:0] s4;
  input [3:0] s5;
  input [3:0] s6;
  input [3:0] s7;
  input [2:0] control;

  output [3:0] out;

  wire [3:0] first_control_bit;
  wire [3:0] second_control_bit;
  wire [3:0] third_control_bit;

  wire [3:0] negative_first_bit;
  wire [3:0] negative_second_bit;
  wire [3:0] negative_third_bit;

  wire [3:0] tempAnd000;
  wire [3:0] tempAnd001;
  wire [3:0] tempAnd010;
  wire [3:0] tempAnd011;
  wire [3:0] tempAnd100;
  wire [3:0] tempAnd101;
  wire [3:0] tempAnd110;
  wire [3:0] tempAnd111;

  wire [3:0] out_and_000;
  wire [3:0] out_and_001;
  wire [3:0] out_and_010;
  wire [3:0] out_and_100;
  wire [3:0] out_and_101;
  wire [3:0] out_and_110;
  wire [3:0] out_and_111;
  wire [3:0] out_and_011;

  wire [3:0] and_000;
  wire [3:0] and_001;
  wire [3:0] and_010;
  wire [3:0] and_011;
  wire [3:0] and_100;
  wire [3:0] and_101;
  wire [3:0] and_110;
  wire [3:0] and_111;

  wire [3:0] or_1;
  wire [3:0] or_2;
  wire [3:0] or_3;
  wire [3:0] or_4;
  wire [3:0] or_5;
  wire [3:0] or_6;

  assign first_control_bit[0] = control[0]; //Представляю control[0] в виде 4-х 
  assign first_control_bit[1] = control[0]; //битного числа, что бы потом при использовании AND, нам выдавался нужный ответ.
  assign first_control_bit[2] = control[0];
  assign first_control_bit[3] = control[0];

  assign second_control_bit[0] = control[1];
  assign second_control_bit[1] = control[1];
  assign second_control_bit[2] = control[1];
  assign second_control_bit[3] = control[1];

  assign third_control_bit[0] = control[2];
  assign third_control_bit[1] = control[2];
  assign third_control_bit[2] = control[2];
  assign third_control_bit[3] = control[2];

  not_4_byte not_4_byte1(first_control_bit, negative_first_bit);
  not_4_byte not_4_byte2(second_control_bit, negative_second_bit);
  not_4_byte not_4_byte3(third_control_bit, negative_third_bit);

  and_4_byte oper_1_000(negative_first_bit, negative_second_bit, tempAnd000);
  and_4_byte oper_2_000(tempAnd000, negative_third_bit, out_and_000);
  and_4_byte oper_3_000(out_and_000, s0, and_000);

  and_4_byte oper_1_001(negative_third_bit, negative_second_bit, tempAnd001);
  and_4_byte oper_2_001(tempAnd001, first_control_bit, out_and_001);
  and_4_byte oper_3_001(out_and_001, s1, and_001);
  
  and_4_byte oper_1_010(negative_first_bit, negative_third_bit, tempAnd010);
  and_4_byte oper_2_010(tempAnd010, second_control_bit, out_and_010);
  and_4_byte oper_3_010(out_and_010, s2, and_010);

  and_4_byte oper_1_011(negative_third_bit, second_control_bit, tempAnd011);
  and_4_byte oper_2_011(tempAnd011, first_control_bit, out_and_011);
  and_4_byte oper_3_011(out_and_011, s3, and_011);

  
  and_4_byte oper_1_100(negative_first_bit, negative_second_bit, tempAnd100);
  and_4_byte oper_2_100(tempAnd100, third_control_bit, out_and_100);
  and_4_byte oper_3_100(out_and_100, s4, and_100);

  and_4_byte oper_1_101(first_control_bit, third_control_bit, tempAnd101);
  and_4_byte oper_2_101(tempAnd101, negative_second_bit, out_and_101);
  and_4_byte oper_3_101(out_and_101, s5, and_101);

  and_4_byte oper_1_110(negative_first_bit, second_control_bit, tempAnd110);
  and_4_byte oper_2_110(tempAnd110, third_control_bit, out_and_110);
  and_4_byte oper_3_110(out_and_110, s6, and_110);

  and_4_byte oper_1_111(first_control_bit, second_control_bit, tempAnd111);
  and_4_byte oper_2_111(tempAnd111, third_control_bit, out_and_111);
  and_4_byte oper_3_111(out_and_111, s7, and_111);

  or_4_byte or1(and_000, and_001, or_1);
  or_4_byte or2(and_010, and_011, or_2);
  or_4_byte or3(and_100, and_101, or_3);
  or_4_byte or4(and_110, and_111, or_4);
  or_4_byte or5(or_1, or_2, or_5);
  or_4_byte or6(or_3, or_4, or_6);
  or_4_byte or7(or_5, or_6, out); //вывод ответа)
endmodule

// module testbench();
//     reg[3:0] a, b;
//     reg[2:0] control;
//     wire[3:0] out;
//     reg[5:0] c1, c2, c3;

//     alu alu1(a, b, control, out);

//     initial begin
//         c1 = 0;
//         for (control = 3'b000; c1 < 8; control = control+1) begin
//             c1 = c1+1;
//             c2 = 0;
//             for (a = 4'b0000; c2 < 16; a = a+1) begin
//                 c2 = c2+1;
//                 c3 = 0;
//                 for (b = 4'b0000; c3 < 16; b = b+1) begin
//                     c3 = c3+1;
//                     #1
//                         $display("a = %b, b = %b, control = %b => out = %b", a, b, control, out);
//                 end
//             end
//         end
//     end
// endmodule
module calculator_test();
    reg[1:0] rd_addr, we_addr;
    reg[2:0] control;
    reg signed[3:0] immediate;
    wire signed[3:0] rd_data;
    reg clk;

    calculator calc(clk, rd_addr, immediate, we_addr, control, rd_data);

    initial begin
        $monitor("rd_data=%d", rd_data);
        // r0 = r0 + 2;
        #5;
        clk = 1;
        // r0 = r0 + 2;
        control = 3'b010;
        immediate = 2;
        rd_addr = 2'b00;
        we_addr = 2'b00;
        #5;
        clk = 0;
        // r1 = r0 - (-2);
        #5;
        clk = 1;
        control = 3'b110;
        rd_addr = 2'b00;
        we_addr = 2'b01;
        immediate = -2;
        #5;
        clk = 0;
        // r2 = r1 & 1
        #5;
        clk = 1;
        control = 3'b000;
        immediate = 1;
        rd_addr = 2'b01;
        we_addr = 2'b10;
        #5;
        clk = 0;
        // r2 = r2 + 0;
        #5;
        clk = 1;
        control = 3'b010;
        immediate = 0;
        rd_addr = 2'b10;
        we_addr = 2'b10;
        #5;
        clk = 0;
    end
endmodule

// module testbench();
//   reg [3:0] data_to_write;
//   reg clock;
//   reg [1:0] read_addr;
//   reg [1:0] write_addr;
//   wire [3:0] data_to_read;

//   reg [3:0] i;

//   register_file register1(clock, read_addr, write_addr, data_to_write, data_to_read);

//   initial begin
//     read_addr = 2'b00;
//     for (i = 3'b000; i < 4 ; i = i + 1) begin
//       #1
//       $display("Data in register %d = %b", i, data_to_read);
//       read_addr = read_addr + 1;
//     end

//   $display(" ");
//   write_addr = 2'b00;
//   data_to_write = 4'b1010;
//   clock = 1;
//   #1
//   clock = 0;
//   #1

//   read_addr = 2'b00;
//   for (i = 3'b000; i < 4 ; i = i + 1) begin
//     #1
//     $display("Data in register %d = %b", i, data_to_read);
//     read_addr = read_addr + 1;
//   end

//   $display(" ");


//   write_addr = 2'b01;
//   data_to_write = 4'b1111;
//   clock = 1;
//   #1
//   clock = 0;
//   #1

//   read_addr = 2'b00;
//   for (i = 3'b000; i < 4 ; i = i + 1) begin
//     #1
//     $display("Data in register %d = %b", i, data_to_read);
//     read_addr = read_addr + 1;
//   end

//   end

// endmodule
