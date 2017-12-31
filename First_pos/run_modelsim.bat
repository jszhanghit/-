vlib work
vlog "*.v"
vsim -c -novopt work.testbench -do "run -all"
pause

