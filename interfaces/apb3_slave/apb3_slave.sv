/*
File name:      apb3_slave.sv
Author:         Walter Ruggeri
Description:    APB slave module compliant with the AMBA 3 specification version B; PSLVERR currently not used

26/08/2022      Initial release
*/


module apb3_slave
#(
    parameter N_BIT_DATA = 32,
`ifdef SIMULATION_DELAY
        DELAY_NS = 10,
`endif
        N_BIT_ADDRESS = 4
)
(
    input [N_BIT_DATA - 1 : 0] PWDATA,
    input PCLK, PRESETn, PSEL, PENABLE, PWRITE,
    input [N_BIT_ADDRESS - 1 : 0] PADDR,
    output [N_BIT_DATA - 1 : 0] PRDATA,
    output PSLVERR, PREADY
);


    timeunit 1ns/1ps;
    
    
    //Controller internals
    typedef enum {IDLE, SETUP, ACCESS} apb_state;
    apb_state current_state, next_state;
    logic read_or_write_reg;
    logic [N_BIT_DATA - 1 : 0] write_data_reg;
    logic [N_BIT_ADDRESS - 1: 0] address_reg;
    
    //Connections
    logic register_ready, read_or_write, register_enable;
    logic [N_BIT_DATA - 1 : 0] write_data, read_data;
    logic [N_BIT_ADDRESS - 1: 0] address;
    
    //Register set internals
    localparam N_CELLS = 2 ** N_BIT_ADDRESS;
    logic [N_BIT_DATA - 1 : 0] register_set [N_CELLS];


    assign PSLVERR = 1'b0; 
    assign PREADY = register_ready;
    assign PRDATA = (PSEL == 1'b1 && PENABLE == 1'b1) ? read_data : 'bZ;
    
    always_comb
    begin: controller_logic
        register_enable = 1'b0;
        
        case (current_state)
            IDLE: 
                if (PSEL === 1'b1) 
                    next_state = SETUP;
                else
                    next_state = IDLE;
            SETUP:
                if (PENABLE === 1'b1 && PSEL === 1'b1)
                begin
                    next_state = ACCESS;
                    register_enable = 1'b1;
                end
                else
                    next_state = IDLE;
            ACCESS:
            begin
                next_state = IDLE;
                register_enable = 1'b1;
                
                if (register_ready === 1'b0)
                begin
                    if (PSEL === 1'b1 || PENABLE === 1'b1)
                        next_state = ACCESS;
                    else
                        next_state = IDLE;
                end
            end
            default:
                next_state = IDLE;
        endcase
    end
    
    always_ff @(posedge PCLK or negedge PRESETn)
    begin: controller_registers
        if (PRESETn === 0)
        begin
            current_state <= IDLE;
            read_or_write_reg <= 1'b0;
            write_data_reg <= 'b0;
            address_reg <= 'b0;
        end
        else
        begin
            current_state <= next_state;
            read_or_write_reg <= (current_state == SETUP) ? PWRITE : read_or_write_reg;
            write_data_reg <= (current_state == SETUP) ? PWDATA : write_data_reg;
            address_reg <= (current_state == SETUP) ? PADDR : address_reg;
        end
    end
    
    assign read_or_write = (current_state == ACCESS) ? read_or_write_reg : 1'bZ;
    assign write_data = (current_state == ACCESS) ? write_data_reg : 'bZ;
    assign address = (current_state == ACCESS) ? address_reg : 'bZ;
    
`ifndef SIMULATION_DELAY   
    assign read_data = (register_enable === 1'b1) ? ((read_or_write === 1'b0) ? register_set[address] : 'bZ) : 'bZ;
    assign register_ready = (register_enable === 1'b0);
`else
    assign #DELAY_NS read_data = (register_enable === 1'b1) ? ((read_or_write === 1'b0) ? register_set[address] : 'bZ) : 'bZ;
    assign register_ready = (register_enable === 1'b0) || ((register_enable === 1'b1) && ((read_data !== 'bZ) || (read_or_write === 1'b1)));
`endif
    
    always_ff @(posedge PCLK or negedge PRESETn)
    begin: register_set_registers
        if (PRESETn === 1'b0)
            for (int j = 0; j < N_CELLS; j++)
                register_set[j] = 'b0;
        else
            if (read_or_write === 1'b1 && register_enable === 1'b1)
                register_set[address] = write_data;
    end
endmodule
