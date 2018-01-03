vlib work
vlog "*.v"
vsim -c -novopt work.test -do "run -all"
pause
