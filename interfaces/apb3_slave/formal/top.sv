/*
File name:      top.sv
Author:         Walter Ruggeri
Description:    top module for the formal verification of an APB slave

09.10.2022      Initial release
*/


module top
#(
    parameter N_BIT_DATA = 32,
        DELAY_CYCLES = 5,
        N_BIT_ADDRESS = 4
)
(
    input [N_BIT_DATA - 1 : 0] PWDATA,
    input PCLK, PRESETn, PSEL, PENABLE, PWRITE,
    input [N_BIT_ADDRESS - 1 : 0] PADDR,
    output [N_BIT_DATA - 1 : 0] PRDATA,
    output PSLVERR, PREADY
);

    
    timeunit 1ns/1ps;    
  
  
    apb3_slave 
    #(
        .N_BIT_DATA(N_BIT_DATA),
        .DELAY_CYCLES(DELAY_CYCLES),
        .N_BIT_ADDRESS(N_BIT_ADDRESS)
    ) apbslave (.*);
    
    bind apb3_slave assertions
    #(
        .N_BIT_DATA(N_BIT_DATA),
        .N_BIT_ADDRESS(N_BIT_ADDRESS)
    ) apb3_slave_assertions (.*);
endmodule
