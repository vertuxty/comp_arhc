module alu(a, b,ALUControl, ALUresult, Zero);
    input [31:0] a;
    input [31:0] b;
    input [2:0] ALUControl;
    output reg Zero;
    output reg [31:0] ALUresult;
    always @(*)
    begin
        if (a - b == 0) begin
            #1;
            // $display("res a=%d, b=%d", a, b);
            Zero = 1;
        end
        else begin
            Zero = 0;
        end
        case(ALUControl)
        3'b010:
           ALUresult = a + b; 
        3'b001:
           ALUresult = a | b;
        3'b000:
           ALUresult = a & b;
        3'b111: // Division
           if (a < b) begin
            ALUresult = 1;
           end
           else begin
            ALUresult = 0;
           end
        3'b110:
           ALUresult = a - b;
        endcase
    end
endmodule