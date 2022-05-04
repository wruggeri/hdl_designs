/*
File name:      g_block.sv
Author:         Walter Ruggeri
Description:    generalized generator terms calculator

14.04.2022      Initial release
04.05.2022      Removed enhanced block
*/


module g_block
(
    input Gik, Pik, Gk1j,
    output Gij
);
    
    timeunit 1ns/1ps;

   
    assign Gij = Gik | (Pik & Gk1j);
    
endmodule