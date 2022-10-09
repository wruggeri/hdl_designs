/*
File name:      assertions.sv
Author:         Walter Ruggeri
Description:    assertions module for an APB slave

09.10.2022      Initial release
*/


module assertions
#(
    parameter N_BIT_DATA = 32,
        N_BIT_ADDRESS = 4
)
(
    input [N_BIT_DATA - 1 : 0] PWDATA, PRDATA,
    input PCLK, PRESETn, PSEL, PENABLE, PWRITE, PSLVERR, PREADY,
    input [N_BIT_ADDRESS - 1 : 0] PADDR
);


    timeunit 1ns/1ps;
    
    
    /*
    Every transaction with a valid start sequence will be eventually (in no more than 20 cycles to limit the proof's complexity) generate a done/error response
    */
    property property_valid_start_receives_response (sel, enable, ready, err);
        ((sel === 1) ##1 ((sel === 1) and (enable === 1) and (ready === 1))) |-> ##[1:20] (((ready === 1) and (err === 0)) or (err === 1));
    endproperty
    valid_start_receives_response: assert property (@(posedge PCLK) disable iff (!PRESETn) property_valid_start_receives_response(PSEL, PENABLE, PREADY, PSLVERR));
    
    /*
    Every started transaction in which PSEL or PENABLE are deasserted too early (a 5 cycle timespan is considered to limit the proof's complexity) will produce an error
    (This assertion can be checked only if the design model includes some delay, otherwise the last part of the precondition is never true) 
    */
`ifdef SIMULATION_DELAY
    property property_early_deassertion_produces_error (sel, enable, ready, err);
        (((sel === 1) ##1 ((sel === 1) and (enable === 1) and (ready === 1))) ##[1:5] (((sel === 0) or (enable === 0)) and (ready === 0))) |-> (err === 1);     
    endproperty
    early_deassertion_produces_error: assert property (@(posedge PCLK) disable iff (!PRESETn) property_early_deassertion_produces_error(PSEL, PENABLE, PREADY, PSLVERR)); 
`endif

    /*
    Every valid read transaction will eventually (in no more than 20 cycles to limit the proof's complexity) produce valid data
    */
    property property_valid_read_data (sel, enable, readn, data);
        (sel === 1) ##1 ((enable === 1) and (readn === 0)) |->  ##[1:20] !$isunknown(data);
    endproperty
    valid_read_data: assert property (@(posedge PCLK) disable iff (!PRESETn) property_valid_read_data(PSEL, PENABLE, PWRITE, PRDATA));   
endmodule
