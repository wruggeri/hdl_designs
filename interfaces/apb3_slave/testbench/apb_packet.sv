/*
File name:      apb_packet.sv
Author:         Walter Ruggeri
Description:    description of an APB test pattern packet content; the following types of packets are implemented:
                    - Single write: perform a write transaction and read the result
                    - Single read: perform a read transaction
                    - Burst write: perform two write transactions and read the results (in a variable order)
                    - Burst read: perform two read transactions

28/08/2022      Initial release
04/09/2022      Added support for burst transactions
*/


class apb_packet extends uvm_sequence_item;
    `include "apb_parameters.svh"
    

    /*
    The first five fields are exactly mapped on APB signals
    is_burst ->                 will the packet feature one (R, W + R) or two (R + R, 2W + 2R) transactions
    alternate_burst ->          in case of a burst write packet, will the sequence be WWRR or WRWR
    data_burst_value ->         offset that must be applied to the generated data to obtain the second pattern in a burst
    address_burst_ value ->     offset that must be applied to the generated address to obtain the second pattern in a burst
    */
    rand bit [N_BIT_DATA - 1 : 0] pwdata;
    rand bit [N_BIT_ADDRESS - 1 : 0] paddr;
    rand bit pwrite;
    rand bit psel;
    rand bit penable;
    rand bit is_burst;
    rand bit alternate_burst;
    rand int data_burst_value;
    rand int address_burst_value;
    
    
    `uvm_object_utils_begin(apb_packet)
        `uvm_field_int(pwdata, UVM_ALL_ON)
        `uvm_field_int(paddr, UVM_ALL_ON)
        `uvm_field_int(pwrite, UVM_ALL_ON)
        `uvm_field_int(psel, UVM_ALL_ON)
        `uvm_field_int(penable, UVM_ALL_ON)
        `uvm_field_int(is_burst, UVM_ALL_ON)
        `uvm_field_int(alternate_burst, UVM_ALL_ON)
        `uvm_field_int(data_burst_value, UVM_ALL_ON)
        `uvm_field_int(address_burst_value, UVM_ALL_ON)
    `uvm_object_utils_end
    
    
    constraint data_before_burst {solve pwdata before data_burst_value;}
    constraint addr_before_burst {solve paddr before address_burst_value;}
    constraint burst_valid_data {data_burst_value < (2 ** N_BIT_DATA);}
    constraint burst_valid_addr {address_burst_value < (2 ** N_BIT_ADDRESS);}
    
    
    function new(string name = "apb_packet");
        super.new(name);
    endfunction
endclass