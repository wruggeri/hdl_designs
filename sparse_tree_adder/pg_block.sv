/*
File name:      pg_block.sv
Author:         Walter Ruggeri
Description:    generalized propagator/generator terms calculator

14.04.2022      Initial release
*/


module pg_block
(
    input Gik, Pik, Gk1j, Pk1j,
	output Gij, Pij
);

    timeunit 1ns/1ps;


	assign Pij = Pik & Pk1j;
	assign Gij = Gik | (Pik & Gk1j);
endmodule