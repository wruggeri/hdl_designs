/*
File name:      apb_component_driver.sv
Author:         Walter Ruggeri
Description:    UVM driver for an APB slave

28/08/2022      Initial release
04/09/2022      Added support for burst transactions
*/


class apb_component_driver extends uvm_driver #(apb_packet);  
    virtual interface apb_interface apb_if;
    int sent_packets, sent_bursts, sent_write, sent_read;
    
    
    `uvm_component_utils_begin(apb_component_driver)
        `uvm_field_int(sent_packets, UVM_ALL_ON)
    `uvm_component_utils_end
    
    
    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction
    
    
    function void connect_phase(uvm_phase phase);
        if (!apb_interface_config::get(this, "", "apb_if", apb_if))
            `uvm_error("NOVIF", "Virtual interface could not be configured")
    endfunction
    
    
    task drive_packet();
        @(negedge apb_if.PRESETn);
        `uvm_info(get_full_name(), "The reset sequence has been started", UVM_LOW)
        @(posedge apb_if.PRESETn);
        `uvm_info(get_full_name(), "The reset sequence has been completed", UVM_LOW)
        
        forever
        begin
            this.seq_item_port.get_next_item(req);
            
            fork
                begin
                    `uvm_info(get_full_name(), $sformatf("Sending packet %0d, which has the following structure: \n%s", sent_packets + 1, req.sprint()), UVM_LOW)
                    apb_if.send_to_dut(req.pwdata, req.paddr, req.pwrite, req.psel, req.penable, req.is_burst);
                end
                @(posedge apb_if.driver_start) void'(begin_tr(req, "Driver_APB_packet"));
            join
            
            if (req.is_burst == 1'b1)
            begin
                if (req.alternate_burst == 1'b0)
                begin
                    apb_if.send_to_dut(req.pwdata + req.data_burst_value, req.paddr + req.address_burst_value, req.pwrite, req.psel, req.penable, req.is_burst & req.pwrite);
                    if (req.pwrite == 1'b1)
                    begin
                        apb_if.send_to_dut(req.pwdata, req.paddr, 1'b0, req.psel, req.penable, req.is_burst);
                        apb_if.send_to_dut(req.pwdata, req.paddr + req.address_burst_value, 1'b0, req.psel, req.penable, 1'b0);
                    end
                end
                else
                begin
                    if (req.pwrite == 1'b1)
                        apb_if.send_to_dut(req.pwdata, req.paddr, 1'b0, req.psel, req.penable, req.is_burst);
                    apb_if.send_to_dut(req.pwdata + req.data_burst_value, req.paddr + req.address_burst_value, req.pwrite, req.psel, req.penable, req.is_burst & req.pwrite);
                    if (req.pwrite == 1'b1)
                        apb_if.send_to_dut(req.pwdata, req.paddr + req.address_burst_value, 1'b0, req.psel, req.penable, 1'b0);
                end
            end
            else
            begin
                if (req.pwrite == 1'b1)
                    apb_if.send_to_dut(req.pwdata, req.paddr, 1'b0, req.psel, req.penable, req.is_burst);
            end
            
            end_tr(req);
            sent_packets++;
            if (req.is_burst == 1'b1)
                sent_bursts++;
            if (req.pwrite == 1'b1)
                sent_write++;
            else
                sent_read++;
            this.seq_item_port.item_done();
        end
    endtask
    
    
    task reset_apb();
        forever
            apb_if.apb_reset();
    endtask
    
    
    task run_phase(uvm_phase phase);
        fork
            drive_packet();
            reset_apb();
        join
    endtask
    
    
    virtual function void start_of_simulation_phase(uvm_phase phase);
        `uvm_info(get_full_name(), "The simulation is starting", UVM_LOW)
    endfunction
    
    
    function void report_phase(uvm_phase phase);
        `uvm_info(get_full_name(), $sformatf("The test is over, the following driver data have been collected: \n\tsent packets: \t\t%0d \n\tread packets: \t\t%0d \n\twrite packets: \t\t%0d \n\tburst packets: \t\t%0d", sent_packets, sent_read, sent_write, sent_bursts), UVM_LOW)
    endfunction
endclass