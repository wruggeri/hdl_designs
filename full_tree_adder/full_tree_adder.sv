/*
File name:      full_tree_adder.sv
Author:         Walter Ruggeri
Description:    full tree adder

17.04.2022      Initial release
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
    genvar i;
    
    
    assign carries[0] = carry_in;
    
    full_tree_carry_generator
    #(
        .N_BIT(N_BIT)
    ) carrygen
    (
        .operand_1(operand_1),
        .operand_2(operand_2),
        .carry_in(carry_in),
        .carry_out(carries[N_BIT : 1])
    );
    
    generate
        for (i = 0; i < N_BIT; i+= 4)
        begin: adders
            if (i >= N_BIT - 4)
            begin
                carry_select_adder
                #(
                    .N_BIT(4)
                ) adder
                (
                    .operand_1(operand_1[i + 3 : i]),
                    .operand_2(operand_2[i + 3 : i]),
                    .carry_in(carries[i]),
                    .sum(sum[i + 3 : i]),
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
                    .operand_1(operand_1[i + 3 : i]),
                    .operand_2(operand_2[i + 3 : i]),
                    .carry_in(carries[i]),
                    .sum(sum[i + 3 : i])  
                );
            end
        end
    endgenerate
    
    assign carry_out = carries[N_BIT];
endmodule
