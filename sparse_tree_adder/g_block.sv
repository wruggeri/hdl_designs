/*
File name:      g_block.sv
Author:         Walter Ruggeri
Description:    generalized generator terms calculators

14.04.2022      Initial release
*/


module g_block
(
    input Gik, Pik, Gk1j,
    output Gij
);
    
    timeunit 1ns/1ps;

   
    assign Gij = Gik | (Pik & Gk1j);
    
endmodule 




module g_block_enhanced
(
    input Gik, Pik, Gk1j, Pk1j, carry_in,
    output Gij
);
    
    timeunit 1ns/1ps;
 
    
    assign Gij = Gik | (Pik & (Gk1j | (Pk1j & carry_in)));
    
endmodule 