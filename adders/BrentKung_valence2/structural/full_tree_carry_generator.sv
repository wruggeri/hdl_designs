/*
File name:      full_tree_carry_generator.sv
Author:         Walter Ruggeri
Description:    valence-2 Brent-Kung carry generator

17.04.2022      Initial release
*/


module full_tree_carry_generator
#(
    parameter N_BIT = 32
)
(
    input [N_BIT - 1 : 0] operand_1, operand_2,
	input carry_in,
    output [N_BIT - 1 : 0] carry_out
);
    
    
    timeunit 1ns/1ps;
    
    
    localparam N_GROUPS = int'($ceil($clog2(N_BIT)));
    localparam N_LEVELS  = 2 * N_GROUPS - 1;
    logic [N_BIT - 1 : 0] p, g;
    logic [N_BIT - 1 : 0] g_matrix [0 : N_LEVELS - 1], p_matrix [0 : N_LEVELS - 1];
    genvar j, k;
    
    
    pg_network 
    #(
        .N_BIT(N_BIT)
    ) pgnetwork (.*);
    
    generate
        for (j = 0; j < N_LEVELS; j++)
        begin: levels
            if (j == 0)
            begin
                assign g_matrix[0][0] = g[0];
                assign p_matrix[0][0] = p[0];
                
                g_block_enhanced gblock 
                (
                    .Gik(g[1]), 
                    .Pik(p[1]), 
                    .Gk1j(g[0]), 
                    .Pk1j(p[0]), 
                    .carry_in(carry_in), 
                    .Gij(g_matrix[0][1])
                );
            
                for (k = 2; k < N_BIT; k ++)
                begin: lanes
                    if ((k + 1) % 2 == 0)
                    begin
                        pg_block pgblock
                        (
                           .Gik(g[k]), 
                           .Pik(p[k]), 
	                       .Gk1j(g[k - 1]), 
	                       .Pk1j(p[k - 1]), 
	                       .Gij(g_matrix[0][k]), 
	                       .Pij(p_matrix[0][k])
                        );
                    end
                    else
                    begin
                        assign g_matrix[0][k] = g[k];
                        assign p_matrix[0][k] = p[k];
                    end
                end
            end
            else
            begin
                if (j < N_GROUPS)
                begin
                    for (k = 0; k < N_BIT; k++)
                    begin: lanes
                        if (k == 2 ** (j + 1) - 1)
                        begin
                           g_block gblock
                           (
                               .Gik(g_matrix[j - 1][k]), 
                               .Pik(p_matrix[j - 1][k]), 
                               .Gk1j(g_matrix[j - 1][k - 2 ** j]), 
                               .Gij(g_matrix[j][k])
                           );
                        end
                        else if ((k + 1) % (2 ** (j + 1)) == 0)
                        begin
                           pg_block pgblock
                           (
                               .Gik(g_matrix[j - 1][k]), 
                               .Pik(p_matrix[j - 1][k]), 
                               .Gk1j(g_matrix[j - 1][k - 2 ** j]),
                               .Pk1j(p_matrix[j - 1][k - 2 ** j]), 
                               .Gij(g_matrix[j][k]),
                               .Pij(p_matrix[j][k])
                           );
                        end
                        else
                        begin
                            assign g_matrix[j][k] = g_matrix[j - 1][k];
                            assign p_matrix[j][k] = p_matrix[j - 1][k];
                        end
                    end
                end
                else
                begin
                    for (k = 0; k < N_BIT; k++)
                    begin: lanes
                        if (((k + 1) % (2 ** (2 * N_GROUPS - 1 - j)) == 2 ** (2 * N_GROUPS - 2 - j)) && ((k & (k + 1)) != 0))
                        begin
                            g_block gblock
                            (
                                .Gik(g_matrix[j - 1][k]), 
                                .Pik(p_matrix[j - 1][k]), 
                                .Gk1j(g_matrix[j - 1][k - 2 ** (2 * N_GROUPS - 2 - j)]), 
                                .Gij(g_matrix[j][k])
                            );
                        end
                        else
                        begin
                            assign g_matrix[j][k] = g_matrix[j - 1][k];
                            assign p_matrix[j][k] = p_matrix[j - 1][k];
                        end
                    end
                end
            end
        end
    endgenerate
    
    generate
	   for (j = 0; j < N_BIT; j++)
	   begin: outputs
	       assign carry_out[j] = g_matrix[N_LEVELS - 1][j];
	   end
	endgenerate
endmodule
