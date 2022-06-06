/*
File name:      full_tree_carry_generator.sv
Author:         Walter Ruggeri
Description:    valence-2 Brent-Kung carry generator

17.04.2022      Initial release
04.05.2022      Added output p, pruned algorithm
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
    
    
    localparam N_GROUPS = int'($ceil($clog2(N_BIT)));
    localparam N_LEVELS  = 2 * N_GROUPS - 1;
    logic [N_BIT - 1 : 0] g_matrix [-1 : N_LEVELS], p_matrix [-1 : N_LEVELS];
    genvar j, k;
    
    
    pg_network 
    #(
        .N_BIT(N_BIT)
    ) pgnetwork 
    (
        .operand_1(operand_1),
        .operand_2(operand_2),
        .p(p_matrix[-1]),
        .g(g_matrix[-1])
    );
    
    assign p_matrix[0] = p_matrix[-1];
    assign g_matrix[0][N_BIT - 1 : 1] = {g_matrix[-1][N_BIT - 1 : 1]};
    g_block gblock_carryin
    (
        .Gik(g_matrix[-1][0]), 
        .Pik(p_matrix[-1][0]), 
        .Gk1j(carry_in), 
        .Gij(g_matrix[0][0])
    );
    
    generate
        for (j = 1; j <= N_LEVELS; j++)
        begin: levels
            if (j <= N_GROUPS)
            begin
                for (k = 0; k < N_BIT; k++)
                begin: lanes
                    if (k == 2 ** j - 1)
                    begin
                        g_block gblock
                        (
                            .Gik(g_matrix[j - 1][k]), 
                            .Pik(p_matrix[j - 1][k]), 
                            .Gk1j(g_matrix[j - 1][k - 2 ** (j - 1)]), 
                            .Gij(g_matrix[j][k])
                        );
                    end
                    else if ((k + 1) % (2 ** j) == 0)
                    begin
                        pg_block pgblock
                        (
                            .Gik(g_matrix[j - 1][k]), 
                            .Pik(p_matrix[j - 1][k]), 
                            .Gk1j(g_matrix[j - 1][k - 2 ** (j - 1)]),
                            .Pk1j(p_matrix[j - 1][k - 2 ** (j - 1)]), 
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
                    if (((k + 1) % (2 ** (2 * N_GROUPS - j)) == 2 ** (2 * N_GROUPS - 1 - j)) && ((k & (k + 1)) != 0))
                    begin
                        g_block gblock
                        (
                            .Gik(g_matrix[j - 1][k]), 
                            .Pik(p_matrix[j - 1][k]), 
                            .Gk1j(g_matrix[j - 1][k - 2 ** (2 * N_GROUPS - 1 - j)]), 
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
    endgenerate
    
	assign carry_out = {g_matrix[N_LEVELS], carry_in};	
	assign p = p_matrix[0];
endmodule
