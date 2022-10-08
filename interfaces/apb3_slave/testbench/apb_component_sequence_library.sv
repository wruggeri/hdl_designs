/*
File name:      apb_component_sequence_library.sv
Author:         Walter Ruggeri
Description:    UVM sequences for an APB slave

28/08/2022      Initial release
*/


//This class is the base for all the actual sequences
class apb_component_base_sequence extends uvm_sequence #(apb_packet);
    `uvm_object_utils(apb_component_base_sequence)


    function new(string name="apb_component_base_sequence");
        super.new(name);
    endfunction


    task pre_body();
        uvm_phase phase;
        phase = get_starting_phase();
        if (phase != null) 
        begin
            phase.raise_objection(this, get_type_name());
            `uvm_info(get_type_name(), "Raising an objection", UVM_MEDIUM)
        end
    endtask


    task post_body();
        uvm_phase phase;
        phase = get_starting_phase();
        if (phase != null) 
        begin
            phase.drop_objection(this, get_type_name());
            `uvm_info(get_type_name(), "Dropping an objection", UVM_MEDIUM)
        end
    endtask

endclass


//This sequence sends 5000 fully random packets
class apb_component_random_5000_sequence extends apb_component_base_sequence;  
    `uvm_object_utils(apb_component_random_5000_sequence)


    function new(string name="apb_component_random_5000_sequence");
        super.new(name);
    endfunction


    virtual task body();
        `uvm_info(get_type_name(), "Starting the execution of the sequence apb_component_random_5000_sequence", UVM_LOW)
        repeat(5000)
            `uvm_do(req)
    endtask  
endclass


//This sequence sends 100 correct packets
class apb_component_correct_100_sequence extends apb_component_base_sequence;  
    `uvm_object_utils(apb_component_correct_100_sequence)


    function new(string name="apb_component_correct_100_sequence");
        super.new(name);
    endfunction


    virtual task body();
        `uvm_info(get_type_name(), "Starting the execution of the sequence apb_component_correct_100_sequence", UVM_LOW)
        repeat(100)
            `uvm_do_with(req, {psel == 1'b1; penable == 1'b1;})
    endtask  
endclass