`timescale 1ns/100ps
module testbench;
reg clk=0;
reg reset_n=0;
reg clk_i=0;
reg start,stop;
wire TDC_stop,TDC_start;

First_pos First_pos_u1(
	.clk      (clk),
	.reset_n  (reset_n),
	.clk_i    (clk_i),
	.start    (start),
	.stop     (stop),
	.TDC_stop (TDC_stop),
	.TDC_start(TDC_start)
);
initial 
  begin
      $dumpfile("dump.vcd");
      $dumpvars();
  end
initial
  begin
      forever #10 clk=~clk;
  end
initial
  begin
      forever #45 clk_i=~clk_i;
  end

integer i=0;
initial
  begin:test
      start = 0;
      stop  = 0;
      #100;
      reset_n = 1;
      #200;
      repeat(100)
        begin
            $display("the %d time",i);
            i = i+1;
            #({$random} % 90 + 395);
            start = 1;
            #40;
            start = 0;
            #({$random} % 90 + 395);
            stop = 1;
            #40;
            stop = 0;
        end
      #200;
      $finish;

  end
endmodule
