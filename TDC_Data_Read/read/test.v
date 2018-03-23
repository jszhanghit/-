`timescale 1ns/100ps
module test;
reg clk =0;
reg reset_n = 0;
reg read = 0;
reg [3:0]addr_in;
reg [27:0]data_in;
wire [27:0]data_out;
wire [3:0]addr_out;
reg EF1;
wire RDN,CSN;
wire AluTrigger;
TDC_Data_Read u_TDC_Data_Read(
    .clk(clk),
    .reset_n(reset_n),
    .read(read),
    .addr_in(addr_in),
    .data_in(data_in),
    .data_out(data_out),
    .addr_out(addr_out),
    .EF1(EF1),
    .RDN(RDN),
    .CSN(CSN),
    .AluTrigger(AluTrigger)
);
always #10 clk = ~clk;
initial
  begin
      $dumpfile("dump.vcd");
      $dumpvars();
  end

initial
  begin
      EF1=1;
      forever 
          begin
            wait(read==1)
              begin
                  #93;
                  EF1=0;
              end
            wait(RDN==0)
              begin
                  #20;
                  EF1=1;
              end
          end
  end
initial
  begin
      #200;
      reset_n = 1;
      repeat(10)
        begin
            #20000;
            addr_in = {$random}%16;
            data_in = {$random}%10000;
            read = 1;
            #40;
            read = 0;
        end
      #200;
      $finish;
  end
endmodule
