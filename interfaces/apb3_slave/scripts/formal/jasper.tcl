##########################################################################################################
#File name:      jasper.tcl
#Author:         Walter Ruggeri
#Description:    JasperGold formal verification command script
#
#09.10.2022      Initial release
##########################################################################################################


clear -all
analyze -sv -f jasper.f
elaborate -triple_equal -loop_limit 20000
clock PCLK
reset -formal {!PRESETn} -bound 10
prove -all
