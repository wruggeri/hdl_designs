@echo off
REM ****************************************************************************
REM Vivado (TM) v2022.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Sat Oct 08 17:40:09 +0200 2022
REM SW Build 3526262 on Mon Apr 18 15:48:16 MDT 2022
REM
REM IP Build 3524634 on Mon Apr 18 20:55:01 MDT 2022
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim top_behav -key {Behavioral:sim_1:Functional:top} -tclbatch top.tcl -view C:/Users/Walter/Desktop/APB/project_1/top_behav.wcfg -log simulate.log -sv_seed 5000 -testplusarg UVM_TESTNAME=test_random_5000"
call xsim  top_behav -key {Behavioral:sim_1:Functional:top} -tclbatch top.tcl -view C:/Users/Walter/Desktop/APB/project_1/top_behav.wcfg -log simulate.log -sv_seed 5000 -testplusarg UVM_TESTNAME=test_random_5000
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0