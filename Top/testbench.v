`timescale 1ns/100ps
module testbench;
reg clk,reset_n;
reg clk_i;
reg start,stop;
wire WRN_o,CSN_o,RDN_o;
wire StopDis1,StopDis2,StopDis3,StopDis4;
wire TDC_stop,TDC_start;
wire Alu;
wire [3:0]addr;
wire done;
wire flag;
wire [63:0]timedata;
wire [27:0]data;
reg  EF1;
TDC u_TDC(
 	.clk       (clk),
	.reset_n   (reset_n),
	.clk_i     (clk_i),
	.start     (start),
	.stop      (stop),
	.WRN_o     (WRN_o),
	.CSN_o     (CSN_o),
	.RDN_o     (RDN_o),
	.StopDis1  (StopDis1),
	.StopDis2  (StopDis2),
	.StopDis3  (StopDis3),
	.StopDis4  (StopDis4),
	.TDC_stop  (TDC_stop),
	.TDC_start (TDC_start),
	.addr      (addr),
	.done      (done),
	.timedata  (timedata),
	.data      (data),
    .AluTrigger(Alu),
    .EF1       (EF1),
    .flag      (flag)
);
assign data = !flag ? 28'd1203 :28'hZZZ_ZZZZ;
initial
  begin
      clk = 0;
      forever #10 clk = ~clk;
  end
initial
  begin
      clk_i = 0;
      forever #45 clk_i = ~clk_i;
  end
initial
  begin
      $dumpfile("dump.vcd");
      $dumpvars();
  end
initial
  begin
      start   = 0;
      stop    = 0;
      reset_n = 0;
      EF1     = 0;
      #200;
      reset_n = 1;
      #1000;
      repeat(10)
        begin
            #({$random}%30 + 120);
            start = 1;
            #({$random}%30 + 20);
            start = 0;
            #({$random}%1200 + 3002);
            stop = 1;
            #({$random}%30 + 20);
            stop = 0;
            #({$random}%30 + 420);
        end
      #204;
      $finish;
  end
endmodule
