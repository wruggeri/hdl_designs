/*
File name:      ripple_carry_adder.sv
Author:         Walter Ruggeri
Description:    ripple carry adder

14.04.2022      Initial release
06.06.2022      Corrected formatting
*/


module ripple_carry_adder
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
    
    
    logic [N_BIT : 0] cin;
    genvar i;
    
    
    assign cin[0] = carry_in;
    
    generate
        for (i = 0; i < N_BIT; i++)
        begin: fadders
            full_adder fa
                (
                    .operand_1(operand_1[i]),
                    .operand_2(operand_2[i]),
                    .carry_in(cin[i]),
                    .sum(sum[i]),
                    .carry_out(cin[i + 1])
                );
        end
    endgenerate
    
    assign carry_out = cin[N_BIT];
    assign overflow = cin[N_BIT] ^ cin[N_BIT - 1];
endmodule
