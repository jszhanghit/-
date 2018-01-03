// +FHDR------------------------------------------------------------
//                 Copyright (c) 2018 JSZHANG .
//                     ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Project       ：Flag_Read.v
// Author        ：JSZHANG
// Version       : 01
// Date          : 2018-01-02 16:03
// Last Modified : 
// -----------------------------------------------------------------
// Abstract      : 产生TDC读使能
//              
// -FHDR------------------------------------------------------------
module Flag_Read(
    input clk,
    input reset_n,
    input TDC_stop,
    output reg read
);

reg TDC_stop_r1,TDC_stop_r2;
wire pulse;
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
        begin
            TDC_stop_r1 <= 1'b0;
            TDC_stop_r2 <= 1'b0;
        end
      else
        begin
            TDC_stop_r1 <= TDC_stop;
            TDC_stop_r2 <= TDC_stop_r1;
        end
  end
assign pulse = TDC_stop_r1 & !TDC_stop_r2;

always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          read <= 1'b0;
      else
          if(pulse)
              read <= 1'b1;
          else
              read <= 1'b0;
  end
endmodule
