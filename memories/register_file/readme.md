A simple multiport register file design with synchronous writes and asynchronous reads. The specification is fully behavioural.
The provided testbench performs two different tests (a "value = address" one and a MATS+ march test), moreover it performs the binding to the register file of an assertion module which can be used to formally verify some properties of the design.
Simulations have been performed with Xilinx Vivado and Cadence Xcelium, formal verification has been performed with Cadence JasperGold (scripts included).
