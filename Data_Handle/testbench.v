// +FHDR------------------------------------------------------------
//                 Copyright (c) 2018 JSZHANG .
//                     ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Project       ：testbench.v
// Author        ：JSZHANG
// Version       : 01
// Date          : 2018-01-05 23:38
// Last Modified : 
// -----------------------------------------------------------------
// Abstract      : 测时代码
//              
// -FHDR------------------------------------------------------------
`timescale 1ns/100ps
module testbench;
reg clk,reset_n;
reg clk_i;
wire TDC_stop;
reg start,stop;
reg AluTriger;
reg [27:0]data_in;
wire [63:0]timedata;
wire done;

Data_Handle u_Data_Handle(
	.clk(clk),
	.reset_n(reset_n),
	.clk_i(clk_i),
	.TDC_stop(TDC_stop),
	.start(start),
	.stop(stop),
	.AluTriger(AluTriger),
	.data_in(data_in),
	.timedata(timedata),
	.done(done)
);
First_pos u_First_pos(
	.clk(clk),
	.reset_n(reset_n),
	.clk_i(clk_i),
	.start(start),
	.stop(stop),
	.TDC_start(TDC_start),
	.TDC_stop(TDC_stop)
);

initial
  begin
      clk = 0;
      forever #10 clk = ~clk;
  end
initial
  begin
      $dumpfile("dump.vcd");
      $dumpvars();
  end
initial
  begin
      clk_i = 0;
      forever #45 clk_i = ~clk_i;
  end
initial
  begin
      reset_n   = 0;
      start     = 0;
      stop      = 0;
      AluTriger = 0;
      data_in   = 28'd1203;
      #103;
      reset_n = 1;
      repeat(10)
        begin
            #({$random}%50 + 23);
            start = 1;
            #({$random}%30 + 20);
            start = 0;
            wait(TDC_stop == 1);
            repeat(5)
                @(posedge clk);
            AluTriger = 1;
            @(posedge clk);
            AluTriger = 0;
            #({$random}%4000 + 2002);
            stop = 1;
            #({$random}%30 +20);
            stop = 0;
            wait(TDC_stop == 1);
            repeat(5)
                @(posedge clk);
            AluTriger = 1;
            @(posedge clk);
            AluTriger = 0;
            #203;
        end
      #200;
      $finish;
  end
endmodule
