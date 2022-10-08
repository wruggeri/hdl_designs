/*
File name:      apb_component_agent.sv
Author:         Walter Ruggeri
Description:    UVM agent for an APB slave

28/08/2022      Initial release
*/


class apb_component_agent extends uvm_agent;  
    apb_component_monitor monitor;
    apb_component_driver driver;
    apb_component_sequencer sequencer;
    
    
    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    
    `uvm_component_utils_begin(apb_component_agent)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
    `uvm_component_utils_end
    
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        monitor = apb_component_monitor::type_id::create("monitor", this);
        if (is_active == UVM_ACTIVE)
        begin
            driver = apb_component_driver::type_id::create("driver", this);
            sequencer = apb_component_sequencer::type_id::create("sequencer", this);
        end
    endfunction
    
    
    virtual function void connect_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction  
    
    
    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "The simulation is starting", UVM_LOW)
    endfunction 
    
    function void assign_vi(virtual interface apb_interface apb_if);
        monitor.apb_if = apb_if;
        if (is_active == UVM_ACTIVE) 
        driver.apb_if = apb_if;
    endfunction
endclass