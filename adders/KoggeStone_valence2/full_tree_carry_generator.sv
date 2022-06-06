/*
File name:      full_tree_carry_generator.sv
Author:         Walter Ruggeri
Description:    valence-2 Kogge-Stone carry generator

04.05.2022      Initial release
06.06.2022      Corrected formatting
*/


module full_tree_carry_generator
#(
    parameter N_BIT = 32
)
(
    input [N_BIT - 1 : 0] operand_1, operand_2,
    input carry_in,
    output [N_BIT : 0] carry_out,
    output [N_BIT - 1 : 0] p
);
    
    
    timeunit 1ns/1ps;
    
    
    localparam N_LEVELS = int'($ceil($clog2(N_BIT))) + 1;
    logic [N_BIT : 0] g_matrix [0 : N_LEVELS], t_matrix [0 : N_LEVELS], p_matrix;
    genvar j, k;
    
    assign p_matrix = {operand_1 ^ operand_2, 1'b0};
    assign t_matrix[0] = {operand_1 | operand_2, 1'b1};
    assign g_matrix[0] = {operand_1 & operand_2, carry_in};
    
    generate
        for (j = 1; j <= N_LEVELS; j++)
        begin
            assign t_matrix[j][N_BIT : 2 ** (j - 1)] = t_matrix[j - 1][N_BIT : 2 ** (j - 1)] & t_matrix[j - 1][N_BIT - 2 ** (j - 1) : 0];
            assign t_matrix[j][2 ** (j - 1) - 1 : 0] = t_matrix[j - 1][2 ** (j - 1) - 1 : 0];
            
            assign g_matrix[j][N_BIT : 2 ** (j - 1)] = g_matrix[j - 1][N_BIT : 2 ** (j - 1)] | (t_matrix[j - 1][N_BIT : 2 ** (j - 1)] & g_matrix[j - 1][N_BIT - 2 ** (j - 1) : 0]);
            assign g_matrix[j][2 ** (j - 1) - 1 : 0] = g_matrix[j - 1][2 ** (j - 1) - 1 : 0];
        end
    endgenerate
    
    assign p = p_matrix[N_BIT : 1];
    assign carry_out = g_matrix[N_LEVELS];
endmodule
