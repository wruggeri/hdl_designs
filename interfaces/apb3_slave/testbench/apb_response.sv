/*
File name:      apb_response.sv
Author:         Walter Ruggeri
Description:    description of an APB transaction response

28/08/2022      Initial release
*/

class apb_response extends uvm_sequence_item;
    `include "apb_parameters.svh"
    
 
    logic [N_BIT_DATA - 1 : 0] prdata;
    bit pready;
    bit pslverr;
    
    
    `uvm_object_utils_begin(apb_response)
        `uvm_field_int(prdata, UVM_ALL_ON)
        `uvm_field_int(pready, UVM_ALL_ON)
        `uvm_field_int(pslverr, UVM_ALL_ON)
    `uvm_object_utils_end
    
    
    function new(string name = "apb_response");
        super.new(name);
    endfunction
    
   
    function bit compute_from_packet(bit psel, bit penable, bit pwrite, bit [N_BIT_DATA - 1 : 0] memory_content);
        if (psel == 1'b0 || penable == 1'b0 || pwrite == 1'b1)
        begin
            this.prdata = 'bZ;
            this.pready = 1'b1;
            this.pslverr = 1'b0;
        end
        else
        begin
            this.prdata = memory_content;
            this.pready = 1'b1;
            this.pslverr = 1'b0;
        end
    endfunction
endclass