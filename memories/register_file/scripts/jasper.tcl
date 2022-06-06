##########################################################################################################
#File name:      jasper.tcl
#Author:         Walter Ruggeri
#Description:    JasperGold formal verification command script
#
#07.06.2022      Initial release
##########################################################################################################


clear -all
analyze -sv -f jasper.f
elaborate -triple_equal -loop_limit 70000
clock clock
reset -formal {!reset_n} -bound 10
prove -all
