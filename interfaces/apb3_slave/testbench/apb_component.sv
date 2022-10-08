/*
File name:      apb_component.sv
Author:         Walter Ruggeri
Description:    UVM component for an APB slave

28/08/2022      Initial release
*/


class apb_component extends uvm_env;
    `uvm_component_utils(apb_component)
    
    
    apb_component_agent agent;
    
    
    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = apb_component_agent::type_id::create("agent", this);
    endfunction
    
    
    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "The simulation is starting", UVM_LOW)
    endfunction
endclass