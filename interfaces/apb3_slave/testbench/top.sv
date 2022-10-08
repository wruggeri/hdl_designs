/*
File name:      top.sv
Author:         Walter Ruggeri
Description:    top module of an APB slave's UVM testbench

28/08/2022      Initial release
*/


module top;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    
    import apb_component_package::*;
    
    
    `include "testbench.sv"
    `include "test_library.sv"
    
    
    hardware_top hw_top();
    
    
    initial
    begin
        apb_interface_config::set(null, "uvm_test_top.tb.*", "apb_if", hw_top.apb_if);
        run_test("base_test");
    end
endmodule