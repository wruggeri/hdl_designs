/*
File name:      apb_component_monitor.sv
Author:         Walter Ruggeri
Description:    UVM monitor with scoreboard functionalities for an APB slave

28/08/2022      Initial release
*/


class apb_component_monitor extends uvm_monitor;
    `include "apb_parameters.svh"
    
    
    `uvm_component_utils(apb_component_monitor)
    
    
    virtual interface apb_interface apb_if;
    apb_packet pkt;
    apb_response rsp_exp, rsp_got;
    int collected_transactions, failed_transactions, read_transactions, write_transactions;
    bit [N_BIT_DATA - 1 : 0] memory_content[2 ** N_BIT_ADDRESS];
    
    
    function new(string name = "", uvm_component parent);
        super.new(name, parent);
        for (int j = 0; j < 2 ** N_BIT_ADDRESS; j++)
            memory_content[j] = 'b0;
    endfunction
    
    
    function void connect_phase(uvm_phase phase);
        if (!apb_interface_config::get(this, "", "apb_if", apb_if))
            `uvm_error("NOVIF", "Virtual interface could not be configured")
    endfunction
    
    
    function void update_memory_content(bit [N_BIT_DATA - 1 : 0] pwdata, bit psel, bit penable, bit pwrite, bit [N_BIT_ADDRESS - 1 : 0] paddr);
        `uvm_info(get_full_name(), "Updating the memory model to account for the captured transaction", UVM_LOW)
        if (psel == 1'b1 && penable == 1'b1 && pwrite == 1'b1)
            memory_content[paddr] = pwdata;
    endfunction
    
    
    virtual task run_phase(uvm_phase phase);
        @(negedge apb_if.PRESETn);
        `uvm_info(get_full_name(), "The reset sequence has been started", UVM_LOW)
        @(posedge apb_if.PRESETn);
        `uvm_info(get_full_name(), "The reset sequence has been completed", UVM_LOW)
        
        forever
        begin
            pkt = apb_packet::type_id::create("pkt", this);
            rsp_exp = apb_response::type_id::create("rsp_exp", this);
            rsp_got = apb_response::type_id::create("rsp_got", this);
            
            fork
                apb_if.capture_transaction(pkt.pwdata, pkt.paddr, pkt.pwrite, pkt.psel, pkt.penable, rsp_got.prdata, rsp_got.pready, rsp_got.pslverr);
                @(negedge apb_if.PCLK) void'(begin_tr(pkt, "Monitor_APB_transaction"));
            join
            
            end_tr(pkt);
            collected_transactions++;
            
            if (pkt.pwrite == 1'b1)
                write_transactions++;
            else
                read_transactions++;
            
            update_memory_content(pkt.pwdata, pkt.psel, pkt.penable, pkt.pwrite, pkt.paddr);
            rsp_exp.compute_from_packet(pkt.psel, pkt.penable, pkt.pwrite, memory_content[pkt.paddr]);
            if(!rsp_exp.compare(rsp_got))
            begin
                `uvm_error("WRONGTRNS", $sformatf("Transaction %0d failed, expected:\n%s\n but got:\n%s", collected_transactions, rsp_exp.sprint(), rsp_got.sprint()))
                failed_transactions++;
            end
            else
                `uvm_info(get_full_name(), $sformatf("Transaction %0d produced the expected response:\n%s", collected_transactions, rsp_got.sprint()), UVM_LOW)
 
        end
    endtask
    
    
    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "The simulation is starting", UVM_LOW)
    endfunction
    
    
    function void report_phase(uvm_phase phase);
        `uvm_info(get_full_name(), $sformatf("The test is over, the following monitoring data have been collected: \n\tcaptured transactions: \t\t%0d \n\tread transactions: \t\t\t%0d \n\twrite transactions: \t\t%0d \n\tfailed transactions: \t\t%0d", collected_transactions, read_transactions, write_transactions, failed_transactions), UVM_LOW)
    endfunction
endclass