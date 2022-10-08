/*
File name:      assertions.sv
Author:         Walter Ruggeri
Description:    assertions module for a register file

07.06.2022      Initial release
08.10.2022      Formatting corrections
*/


module assertions
#(
    parameter N_BIT_DATA = 32,
        N_BIT_ADDRESS = 32,
        N_WRITE = 4,
        N_READ = 16
)
(
    input [N_BIT_DATA - 1 : 0] data_in[N_WRITE], data_out[N_READ],
    input reset_n, clock, write[N_WRITE], read[N_READ],
    input [N_BIT_ADDRESS - 1 : 0] address_write[N_WRITE], address_read[N_READ]
);


    timeunit 1ns/1ps;


    genvar i;


    /*
    If a read is requested, then some valid data must appear at the data outputs
    */
    property property_data_when_request (rd, data);
        (rd === 1) |-> !$isunknown(data);
    endproperty
    generate
        for (i = 0; i < N_READ; i++)
        begin: generate_data_when_request
            data_when_request: assert property (@(posedge clock) disable iff (!reset_n) property_data_when_request(read[i], data_out[i]))
                else $error("Invalid data seen at data_out[%0d] when read[%0d] is asserted.\n", i, i);
        end
    endgenerate
    
    /*
    If no read is requested, then the data outputs must be in high impedance
    */
    property property_Z_when_no_request (rd, out);
        (rd !== 1) |-> (out === {N_BIT_DATA{1'bZ}});
    endproperty
    generate
        for (i = 0; i < N_READ; i++)
        begin: generate_Z_when_no_request
            Z_when_no_request: assert property (@(posedge clock) disable iff (!reset_n) property_Z_when_no_request(read[i], data_out[i]))
                else $error("Output out_data[%0d] is not in high impedance when read[%0d] is not asserted.\n", i, i);
        end
    endgenerate
    
    /*
    If the reset is active, then the read signal is ineffective
    */
    property property_no_read_when_reset (rd, rstn, out);
        ((rstn === 0) && (rd === 1)) |-> (out === {N_BIT_DATA{1'bZ}});
    endproperty
    generate
        for (i = 0; i < N_READ; i++)
        begin: generate_no_read_when_reset
            no_read_when_reset: assert property (@(posedge clock) property_no_read_when_reset(read[i], reset_n, data_out[i]))
                else $error("Signal read[%d] is able to trigger an operation when the reset is active.\n", i);
        end
    endgenerate
endmodule
