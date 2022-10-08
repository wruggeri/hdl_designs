/*
File name:      testbench.sv
Author:         Walter Ruggeri
Description:    testbench for a register file with formal-friendly conditional code inclusion

07.06.2022      Initial release
28.06.2022      Improved results reporting
08.10.2022      Improved formatting
*/


module testbench
`ifdef FORMAL_VERIFICATION
#(
    parameter N_BIT_DATA = 8,
        N_BIT_ADDRESS = 8,
        N_WRITE = 4,
        N_READ = 16
)
`endif
(
`ifdef FORMAL_VERIFICATION
    input [N_BIT_DATA - 1 : 0] data_in[N_WRITE],
    input reset_n, clock, write[N_WRITE], read[N_READ],
    input [N_BIT_ADDRESS - 1 : 0] address_write[N_WRITE], address_read[N_READ],
    output [N_BIT_DATA - 1 : 0] data_out[N_READ]
`endif
);

    
    timeunit 1ns/1ps;
    
`ifndef FORMAL_VERIFICATION
    localparam N_BIT_ADDRESS = 16, N_BIT_DATA = 16, N_WRITE = 4, N_READ = 16, N_CELLS = 2 ** N_BIT_ADDRESS, CLOCK_PERIOD_NS = 10;
    logic [N_BIT_DATA - 1 : 0] data_in[N_WRITE], data_out[N_READ];
    logic reset_n, clock, write[N_WRITE], read[N_READ];
    logic [N_BIT_ADDRESS - 1 : 0] address_write[N_WRITE], address_read[N_READ];
    byte wait_time;
    int unsigned channel, cnt_wr_channel[N_WRITE], cnt_rd_channel[N_READ];
`endif
    
    
    register_file 
    #(
        .N_BIT_ADDRESS(N_BIT_ADDRESS),
        .N_BIT_DATA(N_BIT_DATA),
        .N_WRITE(N_WRITE),
        .N_READ(N_READ)
    ) rf (.*);
    
    bind register_file assertions
    #(
        .N_BIT_ADDRESS(N_BIT_ADDRESS),
        .N_BIT_DATA(N_BIT_DATA),
        .N_WRITE(N_WRITE),
        .N_READ(N_READ)
    ) register_file_assertions (.*);
    
    
`ifndef FORMAL_VERIFICATION
    function void print_statistics(int phase); 
        $display("Verification phase %0d completed with the following statistics:\n\n", phase);
        $display("\tChannel\t\t\tOperations\n");
        $display("----------------------------------------------------------------\n");
        for (int j = 0; j < N_WRITE; j++)
            $display("\twrite_%0d\t\t\t%0d\n", j, cnt_wr_channel[j]);
        for (int j = 0; j < N_READ; j++)
            $display("\tread_%0d\t\t\t%0d\n", j, cnt_rd_channel[j]);    
        $display("----------------------------------------------------------------\n\n\n\n");  
        return; 
    endfunction
    
    always
    begin
        clock = 0;
        #(CLOCK_PERIOD_NS / 2);
        clock = 1;
        #(CLOCK_PERIOD_NS / 2);
    end   

    initial
    begin
        //Initial registers and transaction counters reset
        for (int j = 0; j < N_WRITE; j++)
            cnt_wr_channel[j] = 0;
        for (int j = 0; j < N_READ; j++)
            cnt_rd_channel[j] = 0; 
        reset_n = 0;
        #(10 * CLOCK_PERIOD_NS);
        reset_n = 1;
        #(2 * CLOCK_PERIOD_NS);
    
        /*
        Test 1:
            1. Each cell is written with its address X through write channel X % N_WRITE
            2. Cells are read through multiple read channel in a pseudo-random sequence
        
        This test exercises parallel write and parallel read
        */       
        $display("Starting verification phase 1: data = address in random order.\n");
        for (int j = 0; j < N_WRITE; j++)
                write[j] = 1;
                
        for (longint i = 0; i < N_CELLS; i += N_WRITE)
        begin
            randomize(wait_time) with {wait_time > CLOCK_PERIOD_NS;};
            for (longint j = i; j < i + N_WRITE; j++)
            begin
                if (j >= N_CELLS) 
                    break;
                data_in[j % N_WRITE] = j;                  
                address_write[j % N_WRITE] = j;
                cnt_wr_channel[j % N_WRITE]++;
            end
            #wait_time;
        end
        
        for (int j = 0; j < N_WRITE; j++)
                write[j] = 0;
        for (int j = 0; j < N_READ; j++)
                read[j] = 1;     
                
        for (longint i = 0; i < N_CELLS; i++)
        begin
            randomize(address_read, wait_time) with {wait_time > CLOCK_PERIOD_NS;};
            #wait_time;
            for (int j = 0; j < N_READ; j++)
            begin
                cnt_rd_channel[j]++;
                assert (unsigned'(data_out[j]) == unsigned'(address_read[j]))
                    else $error("Read (%0d) error at %h: got %h, expected %h.\n", j, address_read[j], data_out[j], address_read[j]);
            end
            #wait_time;
        end                       
                    
        print_statistics(1);
        
        /*
        Test 2, march (MATS+) algorithm:
            1. Each cell is written with 1s in ascending order through a pseudo-random write channel
            2. Each cell is read in descending order through a pseudo-random read channel
            3. Each cell is written with 0s in descending order through a pseudo-random write channel
            4. Each cell is read in ascending order through a pseudo-random read channel
            
        This test exercises serial write and serial read
        */
        $display("Starting verification phase 2: MATS+ algorithm.\n");
        for (int j = 0; j < N_WRITE; j++)
            cnt_wr_channel[j] = 0;
        for (int j = 0; j < N_READ; j++)
            cnt_rd_channel[j] = 0;
        for (int j = 0; j < N_READ; j++)
                read[j] = 0;
                           
        for (longint i = 0; i < N_CELLS; i++)
        begin
            channel = $urandom % N_WRITE;
            randomize(wait_time) with {wait_time > CLOCK_PERIOD_NS;};
            data_in[channel] = (2 ** N_BIT_DATA) - 1;
            for (int j = 0; j < N_WRITE; j++)
                write[j] = 0;
            write[channel] = 1;
            address_write[channel] = i;
            cnt_wr_channel[channel]++;
            #wait_time;
        end
        
        for (int j = 0; j < N_WRITE; j++)
                write[j] = 0;
        
        for (longint i = N_CELLS - 1; i >= 0; i--)
        begin
            channel = $urandom % N_READ;
            randomize(wait_time) with {wait_time > CLOCK_PERIOD_NS;};
            address_read[channel] = i;
            read[channel] = 1;
            #wait_time;
            cnt_rd_channel[channel]++;
            assert (unsigned'(data_out[channel]) == (2 ** N_BIT_DATA) - 1)
                else $error("Read (%0d) error at %h: got %h, expected %h.\n", channel, address_read[channel], data_out[channel], (2 ** N_BIT_DATA) - 1);
            #wait_time;
            read[channel] = 0;
        end
       
        for (int j = 0; j < N_READ; j++)
                read[j] = 0;            
           
        for (longint i = N_CELLS - 1; i >= 0; i--)
        begin
            channel = $urandom % N_WRITE;
            randomize(wait_time) with {wait_time > CLOCK_PERIOD_NS;};
            data_in[channel] = 0;
            for (int j = 0; j < N_WRITE; j++)
                write[j] = 0;
            write[channel] = 1;
            address_write[channel] = i;
            cnt_wr_channel[channel]++;
            #wait_time;
        end
        
        for (int j = 0; j < N_WRITE; j++)
                write[j] = 0;
        
        for (longint i = 0; i < N_CELLS; i++)
        begin
            channel = $urandom % N_READ;
            randomize(wait_time) with {wait_time > CLOCK_PERIOD_NS;};
            address_read[channel] = i;
            read[channel] = 1;
            cnt_rd_channel[channel]++;
            #wait_time;
            assert (unsigned'(data_out[channel]) == 0)
                else $error("Read (%0d) error at %h: got %h, expected 0x0.\n", channel, address_read[channel], data_out[channel]);
            #wait_time;
            read[channel] = 0;
        end
        
        print_statistics(2);           
        
        $display("Verification completed.");
        $finish;
    end
`endif
endmodule
