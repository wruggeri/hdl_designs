/*
File name:      apb_component_package.sv
Author:         Walter Ruggeri
Description:    package for an APB slave UVM component libraries

28/08/2022      Initial release
*/


package apb_component_package;
    import uvm_pkg::*; 
    `include "uvm_macros.svh"
    
    typedef uvm_config_db#(virtual apb_interface) apb_interface_config;
    
    `include "apb_response.sv"
    `include "apb_packet.sv"
    `include "apb_component_monitor.sv"
    `include "apb_component_sequencer.sv"
    `include "apb_component_sequence_library.sv"
    `include "apb_component_driver.sv"
    `include "apb_component_agent.sv"
    `include "apb_component.sv"
endpackage