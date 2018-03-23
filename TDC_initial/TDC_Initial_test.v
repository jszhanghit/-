module TDC_Initial_test;
reg clk,reset_n;
wire WRN,CSN;
wire flag,StopDis1,StopDis2,StopDis3,StopDis4;
wire[3:0]addr;
wire[27:0]data;
TDC_Initial TDC_Initial_i1(
    .clk      (clk),
    .reset_n  (reset_n),
    .WRN      (WRN),
    .CSN      (CSN),
    .flag     (flag),
    .StopDis1 (StopDis1),
    .StopDis2 (StopDis2),
    .StopDis3 (StopDis3),
    .StopDis4 (StopDis4),
    .addr     (addr),
    .data     (data)
);
initial begin
    $dumpfile("dump.vcd");
    $dumpvars();
end
initial begin
    clk=0;
    forever #10 clk=~clk;
end
initial begin
    reset_n=0;
    #200;
    reset_n=1;
    #5000;
    $finish;
end
endmodule
