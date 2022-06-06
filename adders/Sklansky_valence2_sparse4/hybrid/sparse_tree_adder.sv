/*
File name:      sparse_tree_adder.sv
Author:         Walter Ruggeri
Description:    4-sparse tree adder

14.04.2022      Initial release
06.06.2022      Corrected formatting
*/


module sparse_tree_adder
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
    
    
    logic [N_BIT / 4 : 0] carries;
    genvar i;
    
    
    assign carries[0] = carry_in;
    
    sparse_tree_carry_generator
    #(
        .N_BIT(N_BIT)
    ) carrygen
    (
        .operand_1(operand_1),
        .operand_2(operand_2),
        .carry_in(carry_in),
        .carry_out(carries[N_BIT / 4 : 1])
    );
    
    generate
        for (i = 0; i < N_BIT / 4; i++)
        begin: adders
            if (i == N_BIT / 4 - 1)
            begin
                carry_select_adder
                #(
                    .N_BIT(4)
                ) adder
                (
                    .operand_1(operand_1[4 * i + 3 : 4  *i]),
                    .operand_2(operand_2[4 * i + 3 : 4 * i]),
                    .carry_in(carries[i]),
                    .sum(sum[4 * i + 3 : 4 * i]),
                    .overflow(overflow)  
                );
            end
            else
            begin
                carry_select_adder
                #(
                    .N_BIT(4)
                ) adder
                (
                    .operand_1(operand_1[4 * i + 3 : 4  *i]),
                    .operand_2(operand_2[4 * i + 3 : 4 * i]),
                    .carry_in(carries[i]),
                    .sum(sum[4 * i + 3 : 4 * i])  
                );
            end
        end
    endgenerate
    
    assign carry_out = carries[N_BIT / 4];
endmodule
