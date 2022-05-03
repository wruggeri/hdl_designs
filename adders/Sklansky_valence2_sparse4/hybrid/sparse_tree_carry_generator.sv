/*
File name:      sparse_tree_carry_generator.sv
Author:         Walter Ruggeri
Description:    4-sparse valence-2 Sklansky carry generator

03.05.2022      Initial release
*/


module sparse_tree_carry_generator
#(
    parameter N_BIT = 32
)
(
    input [N_BIT - 1 : 0] operand_1, operand_2,
    input carry_in,
    output [N_BIT / 4 - 1 : 0] carry_out
);

    
    timeunit 1ns/1ps;
    
    
    localparam N_LEVELS  = int'($ceil($clog2(N_BIT)));
    logic [N_BIT : 0] g_matrix [0 : N_LEVELS], p_matrix [0 : N_LEVELS];
    genvar j, k;
    
    
    assign p_matrix[0] = {operand_1 ^ operand_2, ~carry_in};
    assign g_matrix[0] = {operand_1 & operand_2, carry_in};
    
    generate
        for (j = 1; j <= N_LEVELS; j++)
        begin
            for (k = 2; k <= N_BIT; k += 2)
            begin
                if (j == 1)
                begin
                    if (k == 2)
                    begin                    
                        assign g_matrix[j][k] = g_matrix[0][2] | (p_matrix[0][2] & (g_matrix[0][1] | (p_matrix[0][1] & g_matrix[0][0])));
                    end
                    else
                    begin
                        assign g_matrix[j][k] = g_matrix[j - 1][k] | (p_matrix[j - 1][k] & g_matrix[j - 1][(2 ** (j - 1)) * ((k - 1) / (2 ** (j - 1)))]);
                        assign p_matrix[j][k] = p_matrix[j - 1][k] & p_matrix[j - 1][(2 ** (j - 1)) * ((k - 1) / (2 ** (j - 1)))];
                    end
                end
                else
                begin
                    if (k % 4 == 0)
                    begin
                        if (((k - 1) & (2 ** (j - 1))) == 0)
                        begin
                            assign g_matrix[j][k] = g_matrix[j - 1][k];
                            assign p_matrix[j][k] = p_matrix[j - 1][k];
                        end
                        else
                        begin
                            if ((k > 2 ** (j - 1)) && (k <= 2 ** j))
                            begin
                                assign g_matrix[j][k] = g_matrix[j - 1][k] | (p_matrix[j - 1][k] & g_matrix[j - 1][(2 ** (j - 1)) * ((k - 1) / (2 ** (j - 1)))]);
                            end
                            else if (k + 1 > 2**j)
                            begin
                                assign g_matrix[j][k] = g_matrix[j - 1][k] | (p_matrix[j - 1][k] & g_matrix[j - 1][(2 ** (j - 1)) * ((k - 1) / (2 ** (j - 1)))]);
                                assign p_matrix[j][k] = p_matrix[j - 1][k] & p_matrix[j - 1][(2 ** (j - 1)) * ((k - 1) / (2 ** (j - 1)))];
                            end
                        end
                    end
                end
            end
        end
    endgenerate
    
    generate
	   for (j = 0; j < N_BIT / 4; j++)
	   begin: outputs
	       assign carry_out[j] = g_matrix[N_LEVELS][4 * (j + 1)];
	   end
	endgenerate
endmodule