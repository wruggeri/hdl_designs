/*
File name:      register_file.sv
Author:         Walter Ruggeri
Description:    register file with multiple synchronous write ports and multiple asynchronous read ports

07.06.2022      Initial release
*/


module register_file
#(
    parameter N_BIT_DATA = 32,
        N_BIT_ADDRESS = 16,
        N_WRITE = 4,
        N_READ = 16
)
(
    input [N_BIT_DATA - 1 : 0] data_in[N_WRITE],
    input reset_n, clock, write[N_WRITE], read[N_READ],
    input [N_BIT_ADDRESS - 1 : 0] address_write[N_WRITE], address_read[N_READ],
    output [N_BIT_DATA - 1 : 0] data_out[N_READ]
);

    
    timeunit 1ns/1ps;
    
    
    localparam N_CELLS = 2 ** N_BIT_ADDRESS;
    logic [N_BIT_DATA - 1 : 0] out[N_READ];
    logic [N_BIT_DATA - 1 : 0] register_array [0 : N_CELLS];
    genvar i;
    
    
    always_ff @(posedge clock or negedge reset_n)
    begin
        if (reset_n == 0)
        begin
            for (int j = 0; j < N_CELLS; j++)
            begin
                register_array[j] <= 0;
            end
        end
        else
        begin
            for (int j = 0; j < N_WRITE; j++)
            begin
                if (write[j] == 1)
                    register_array[unsigned'(address_write[j])] <= data_in[j];
            end
        end
    end
    
    generate
        for (i = 0; i < N_READ; i++)
        begin
            assign out[i] = ((read[i] === 1) && (reset_n === 1)) ? register_array[unsigned'(address_read[i])] : 'bZ;
            assign data_out[i] = out[i];
        end
    endgenerate
endmodule
