/*
File name:      apb_component_sequencer.sv
Author:         Walter Ruggeri
Description:    UVM sequencer for an APB slave

28/08/2022      Initial release
*/


class apb_component_sequencer extends uvm_sequencer #(apb_packet);
    `uvm_component_utils(apb_component_sequencer)
    
    
    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    
    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "The simulation is starting", UVM_LOW)
    endfunction
endclass