/*
File name:      pg_network.sv
Author:         Walter Ruggeri
Description:    single-bit propagator and generator terms calculator

14.04.2022      Initial release
*/


module pg_network
#(
    parameter N_BIT = 32
)
(
    input [N_BIT - 1 : 0] operand_1, operand_2,
    output [N_BIT - 1 : 0] p, g
);
    
    timeunit 1ns/1ps;

    
    assign p = operand_1 ^ operand_2;
    assign g = operand_1 & operand_2;
endmodule
