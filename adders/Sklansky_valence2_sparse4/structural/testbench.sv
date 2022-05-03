/*
File name:      testbench.sv
Author:         Walter Ruggeri
Description:    adder testbench based on a golden model and verification assertions

14.04.2022      Initial release
*/


module testbench();


    timeunit 1ns/1ps;
    
    localparam longint N_BIT = 128, N_TESTS = 2 ** 25, CLK_PERIOD_NS = 10;
    longint i;
    logic clk, carry_in, carry_out, overflow, golden_cout, golden_ovf;
    logic [N_BIT - 1 : 0] operand_1, operand_2, sum, golden_sum;
    
    
    sparse_tree_adder
    #(
        .N_BIT(N_BIT)
    ) dut (.*);
    
    
    always
    begin
        clk = 0;
        #(CLK_PERIOD_NS / 2);
        clk = 1;
        #(CLK_PERIOD_NS / 2);
    end
    
    assign {golden_cout, golden_sum} = operand_1 + operand_2 + carry_in;
    assign golden_ovf = !(operand_1[N_BIT - 1] ^ operand_2[N_BIT - 1]) & (golden_sum[N_BIT - 1] != operand_1[N_BIT - 1]);
    
    initial
    begin
        for (i = 0; i < N_TESTS; i++)
        begin
            randomize(carry_in, operand_1, operand_2);
            #CLK_PERIOD_NS;
        end
        $finish;
    end
    
    
    equal_sums: assert property (@(posedge clk) (sum === golden_sum))
        else $error("Sums error for %d + %d: expected %d, got %d.\n", operand_1, operand_2, golden_sum, sum);
        
    equal_couts: assert property (@(posedge clk) (carry_out === golden_cout))
        else $error("Carries error for %d + %d: expected %d, got %d.\n", operand_1, operand_2, golden_cout, carry_out);
        
    equal_ovfs: assert property (@(posedge clk) (overflow === golden_ovf))
        else $error("Overflows error for %d + %d: expected %d, got %d.\n", operand_1, operand_2, golden_ovf, overflow); 
endmodule
