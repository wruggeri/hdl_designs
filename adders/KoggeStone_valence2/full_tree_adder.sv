/*
File name:      full_tree_adder.sv
Author:         Walter Ruggeri
Description:    full tree adder

17.04.2022      Initial release
04.05.2022      Replaced carry-select adders with a XOR layer
*/


module full_tree_adder
#(
    parameter N_BIT = 32
)
(
    input [N_BIT - 1 : 0] operand_1, operand_2,
	input carry_in,
    output [N_BIT - 1 : 0] sum,
    output carry_out, overflow
);

    
    timeunit 1ns/1ps;
    
    
    logic [N_BIT : 0] carries;
    logic [N_BIT - 1 : 0] p;
    genvar i;
    
    
    full_tree_carry_generator
    #(
        .N_BIT(N_BIT)
    ) carrygen
    (
        .operand_1(operand_1),
        .operand_2(operand_2),
        .carry_in(carry_in),
        .carry_out(carries),
        .p(p)
    );
    
    generate
        for (i = 0; i < N_BIT; i++)
        begin
            assign sum[i] = p[i] ^ carries[i];
        end
    endgenerate
    
    assign carry_out = carries[N_BIT];
    assign overflow = carries[N_BIT] ^ carries[N_BIT - 1];
endmodule
