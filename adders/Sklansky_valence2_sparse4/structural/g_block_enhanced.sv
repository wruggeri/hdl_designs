/*
File name:      g_block_enhanced.sv
Author:         Walter Ruggeri
Description:    generalized generator terms calculator with carry in

04.05.2022      Initial release
*/


module g_block_enhanced
(
    input Gik, Pik, Gk1j, Pk1j, carry_in,
    output Gij
);
    
    timeunit 1ns/1ps;
 
    
    assign Gij = Gik | (Pik & (Gk1j | (Pk1j & carry_in)));
    
endmodule 