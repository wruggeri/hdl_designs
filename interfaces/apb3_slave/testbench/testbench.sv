/*
File name:      testbench.sv
Author:         Walter Ruggeri
Description:    UVM testbench component for an APB slave

28/08/2022      Initial release
*/

class testbench extends uvm_env;
    `uvm_component_utils(testbench)
    
    
    apb_component apb_cmp;
    
    
    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction
   
   
    virtual function void build_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "The testbench is going through the build phase", UVM_LOW)
        super.build_phase(phase);
        apb_cmp = apb_component::type_id::create("apb_cmp", this);
    endfunction


    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "The simulation is starting", UVM_LOW)
    endfunction
endclass