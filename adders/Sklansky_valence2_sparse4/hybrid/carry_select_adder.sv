/*
File name:      carry_select_adder.sv
Author:         Walter Ruggeri
Description:    carry select adder

14.04.2022      Initial release
06.06.2022      Corrected formatting
*/


module carry_select_adder
#(
    parameter N_BIT = 32
)
(
    input [N_BIT - 1 : 0] operand_1, operand_2,
    input carry_in,
    output [N_BIT - 1 : 0] sum,
    output carr_out, overflow
);
    
    
    timeunit 1ns/1ps;
    
    
    logic [1 : 0] ovf, cout;
    logic [2 * N_BIT - 1 : 0] sums;
    genvar i;
    
    
    generate
        for (i = 0; i < 2; i++)
        begin: adders
            ripple_carry_adder 
            #(
                .N_BIT(N_BIT)
            ) rca
            (
                .operand_1(operand_1),
                .operand_2(operand_2),
                .carry_in(i),
                .sum(sums[(i + 1) * N_BIT - 1 : i * N_BIT]),
                .carry_out(cout[i]),
                .overflow(ovf[i])
            );
        end
    endgenerate
    
    assign sum = carry_in ? sums[2 * N_BIT - 1 : N_BIT] : sums[N_BIT - 1 : 0];
    assign carry_out = carry_in ? cout[1] : cout[0];
    assign overflow = carry_in ? ovf[1] : ovf[0];
endmodule
