/*
File name:      test_library.sv
Author:         Walter Ruggeri
Description:    UVM test library for an APB slave

28/08/2022      Initial release
*/


//This class is the base for all the actual tests
class base_test extends uvm_test;
    `uvm_component_utils(base_test)
    
    
    testbench tb;
    
    
    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    
    virtual function void build_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "The base test is going through the build phase", UVM_LOW)
        super.build_phase(phase);
        uvm_config_int::set(this, "*", "recording_detail", 1);
        tb = testbench::type_id::create("tb", this);
    endfunction
    
    
    virtual function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction
    
    
    virtual task run_phase(uvm_phase phase);
        uvm_objection obj = phase.get_objection();
        obj.set_drain_time(this, 200ns);
    endtask
    
    
    virtual function void check_phase(uvm_phase phase);
        check_config_usage();
    endfunction
endclass




//This class implements a test sending 5000 fully random transactions
class test_random_5000 extends base_test;
    `uvm_component_utils(test_random_5000)
    
    
    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    
    virtual function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.apb_cmp.agent.sequencer.run_phase", "default_sequence", apb_component_random_5000_sequence::get_type());
        super.build_phase(phase);
    endfunction 
endclass




//This class implements a test sending 100 correct transactions with random data
class test_correct_100 extends base_test;
    `uvm_component_utils(test_correct_100)
    
    
    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    
    virtual function void build_phase(uvm_phase phase);
        uvm_config_wrapper::set(this, "tb.apb_cmp.agent.sequencer.run_phase", "default_sequence", apb_component_correct_100_sequence::get_type());
        super.build_phase(phase);
    endfunction 
endclass