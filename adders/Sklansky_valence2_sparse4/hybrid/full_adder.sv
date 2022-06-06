/*
File name:      full_adder.sv
Author:         Walter Ruggeri
Description:    full adder

14.04.2022      Initial release
06.06.2022      Corrected formatting
*/


module full_adder
(
    input operand_1, operand_2, carry_in,
    output sum, carry_out
);
    
    
    timeunit 1ns/1ps;
    
    
    assign sum = carry_in ^ operand_1 ^ operand_2;
    assign carry_out = (carry_in & (operand_1 ^ operand_2)) | (operand_1 & operand_2);
endmodule
