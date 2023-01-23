A 4-sparse tree adder based on the Intel Pentium 4 version of the valence-2 Sklansky architecture. It features a propagator/generator calculation network, a 4-sparse valence-2 carry calculation network and an array of 4-bit carry-select adders. The carry-in is handled by means of an "enhanced" computation block at the first level of the tree. Two specifications are available: 

* A fully structural specification
* An hybrid specification mixing dataflow and structural information

The provided testbench is composed by a simple random values generator, a behavioural golden model and some assertion-based checkers. Simulations have been performed with Xilinx Vivado, Cadence Xcelium and Synopsys VCS.
