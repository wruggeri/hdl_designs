/*
File name:      hardware_top.sv
Author:         Walter Ruggeri
Description:    top module containing the design-under-test, its interface and the clock/reset generator

28/08/2022      Initial release
*/


module hardware_top;
    `include "apb_parameters.svh"


    logic clock, reset;


    always
    begin
        #(CLOCK_PERIOD_NS / 2);
        clock = ~clock;
    end
    
    apb_interface apb_if(clock, reset);
    
    apb3_slave 
    #(
        .N_BIT_DATA(N_BIT_DATA),
        .DELAY_NS(DELAY_NS),
        .N_BIT_ADDRESS(N_BIT_ADDRESS)
    ) dut
    (
        .PWDATA(apb_if.PWDATA),
        .PCLK(clock),
        .PRESETn(reset),
        .PSEL(apb_if.PSEL),
        .PENABLE(apb_if.PENABLE),
        .PWRITE(apb_if.PWRITE),
        .PADDR(apb_if.PADDR),
        .PRDATA(apb_if.PRDATA),
        .PSLVERR(apb_if.PSLVERR),
        .PREADY(apb_if.PREADY)
    );
    
    initial
    begin
        reset = 1'b1;
        clock = 1'b0;
        @(posedge clock);
        #1 reset = 1'b0;
        @(posedge clock);
        #1 reset = 1'b1;
    end
endmodule