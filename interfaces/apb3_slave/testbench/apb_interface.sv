/*
File name:      apb_interface.sv
Author:         Walter Ruggeri
Description:    interface for an APB slave

28/08/2022      Initial release
*/


interface apb_interface (input PCLK, input PRESETn);
    timeunit 1ns;
    timeprecision 1ps;


    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import apb_component_package::*;
    
    `include "apb_parameters.svh"


    //APB interface signals
    logic [N_BIT_DATA - 1 : 0] PWDATA, PRDATA;
    logic PSEL, PENABLE, PWRITE, PREADY, PSLVERR;
    logic [N_BIT_ADDRESS - 1 : 0] PADDR;

    //Internal management signals
    bit monitor_start, driver_start, packet_frame;


    task apb_reset();
        @(negedge PRESETn);
        PWDATA = 'bZ;
        PSEL = 1'b0;
        PENABLE = 1'b0;
        PWRITE = 1'b0;
        PADDR = 'bZ;
        disable send_to_dut;
    endtask


    task send_to_dut(input bit [N_BIT_DATA - 1 : 0] pwdata, bit [N_BIT_ADDRESS - 1 : 0] paddr, bit pwrite, bit psel, bit penable, bit is_burst);
        @(posedge PCLK);
        driver_start = 1'b1;
        packet_frame = 1'b1;
        PSEL = psel;
        PWRITE = pwrite;
        PWDATA = pwdata;
        PADDR = paddr;
        
        @(posedge PCLK);
        PENABLE = penable;
        
        @(posedge PCLK iff PREADY);
        packet_frame = 1'b0;
        driver_start = 1'b0;
        
        @(posedge PCLK);
        PENABLE = 1'b0;
        if(is_burst == 1'b0)
            PSEL = 1'b0;
    endtask
  
  
    task capture_transaction(output bit [N_BIT_DATA - 1 : 0] pwdata, bit [N_BIT_ADDRESS - 1 : 0] paddr, bit pwrite, bit psel, bit penable, logic [N_BIT_DATA - 1 : 0] prdata, bit pready, bit pslverr);
        @(negedge PCLK iff packet_frame);
        monitor_start = 1'b1;
        psel = PSEL;
        pwrite = PWRITE;
        pwdata = PWDATA;
        paddr = PADDR;
        
        @(negedge PCLK iff packet_frame);
        penable = PENABLE;
        
        @(negedge PCLK iff (PREADY && !packet_frame));
        pslverr = PSLVERR;
        pready = PREADY;
        prdata = PRDATA;
        monitor_start = 1'b0;
    endtask
endinterface