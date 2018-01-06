// +FHDR------------------------------------------------------------
//                 Copyright (c) 2018 JSZHANG .
//                     ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Project       ：Data_Handle.v
// Author        ：JSZHANG
// Version       : 01
// Date          : 2018-01-05 14:59
// Last Modified : 
// -----------------------------------------------------------------
// Abstract      : 数据处理模块，获得一次测量的整体时间
//
// -FHDR------------------------------------------------------------
module Data_Handle(
    input clk,
    input reset_n,
    input clk_i,
    input TDC_stop,           // TDC_stop信号，在该位置处开始进行clk_i上升沿检测
    input start,stop,         // 系统开始测量的标志位
    input AluTriger,          // 当AluTriger有效时表明读时序完成，可以获取数据了
    input [27:0]data_in,      // 测量数据,数据来自TDC_Data_Read的输出数据
    output reg[63:0]timedata, // 最终时间数据，输出给SDK，用于sd卡存储
    output reg done           // 当获得有效数据该标志位置位
);
localparam PRECISION = 40;
localparam CLKTIME   = 25000;

localparam IDLE      = 5'b00001,
           START     = 5'b00010,
           ST_STOP   = 5'b00100,
           STOP      = 5'b01000,
           SP_STOP   = 5'b10000;


reg [63:0]Time1,Time2;
reg start_r1,start_r2;
reg stop_r1,stop_r2;
wire pulse_start;
wire pulse_stop;
reg flag_start,flag_stop;
reg clk_r1,clk_r2;
wire pulse_clk;

always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
        begin
            start_r1 <= 1'b0;
            start_r2 <= 1'b0;
        end
      else
        begin
            start_r1 <= start;
            start_r2 <= start_r1;
        end
  end
assign pulse_start = start & !start_r2;

always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
        begin
            stop_r1 <= 1'b0;
            stop_r2 <= 1'b0;
        end
      else
        begin
            stop_r1 <= stop;
            stop_r2 <= stop_r1;
        end
  end
assign pulse_stop = stop & !start_r2;

//start上升沿至AluTriger有效flag_start为高
//主要用该标志位判断得到的数据应该存储到那个寄存器
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          flag_start <= 1'b0;
      else
          if(pulse_start)
               flag_start <= 1'b1;
          else if(AluTriger)
               flag_start <= 1'b0;
          else
               flag_start <= flag_start;
  end
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          flag_stop <= 1'b0;
      else
          if(pulse_stop)
              flag_stop <= 1'b1;
          else if(AluTriger)
              flag_stop <= 1'b0;
          else
              flag_stop <= flag_stop;
  end

//AluTriger时进行数据读取操作，并且根据flag_start与flag_stop判断数据的存储位置
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          Time1 <= 64'd0;
      else
          if(AluTriger && flag_start)
              Time1 <= data_in*PRECISION;
          else
              Time1 <= Time1;
  end
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          Time2 <= 64'd0;
      else
          if(AluTriger && flag_stop)
              Time2 <= data_in * PRECISION;
          else
              Time2 <= Time2;
  end

always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
        begin
            clk_r1 <= 1'b0;
            clk_r2 <= 1'b0;
        end
      else
        begin
            clk_r1 <= clk_i;
            clk_r2 <= clk_r1;
        end
  end
assign pulse_clk = clk_r1 & !clk_r2; // clk_i上升沿

//下面处理clk_i的计数状态位
reg [4:0]state_next,state_current;
reg flag_clk_i;
reg [63:0]cnt;
reg [63:0]cnt_r;
reg add;
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          state_current <= IDLE;
      else
          state_current <= state_next;
  end

always@(*)
  begin
      if(!reset_n)
        state_next = IDLE;
      else
          case(state_current)
              IDLE:
                  if(pulse_start)
                      state_next = START;
                  else
                      state_next = IDLE;
              START:
                  if(TDC_stop)
                      state_next = ST_STOP;
                  else
                      state_next = START;
              ST_STOP:
                  if(pulse_stop)
                      state_next = STOP;
                  else
                      state_next = ST_STOP;
              STOP:
                  if(TDC_stop)
                      state_next = SP_STOP;
                  else
                      state_next = STOP;
              SP_STOP:
                  state_next = IDLE;
              default:
                  state_next = IDLE;
          endcase
  end
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          flag_clk_i <= 1'b0;
      else
          if(state_current == ST_STOP)
              flag_clk_i <= 1'b1;
          else if(state_current == SP_STOP)
              flag_clk_i <= 1'b0;
          else
              flag_clk_i <= flag_clk_i;
  end

always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          cnt <= 64'd0;
      else
          if(flag_clk_i)
              if(pulse_clk)
                  cnt <= cnt + 1'b1;
              else
                  cnt <= cnt;
          else
              cnt <= 64'd1;
  end

always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
        begin
          cnt_r <= 64'd0;
          add   <= 1'b0;
        end
      else
          if(state_current == SP_STOP)
            begin
              cnt_r <= cnt;
              add   <= 1'b1;
            end
          else
            begin
                cnt_r <= cnt_r;
                add   <= 1'b0;
            end
  end
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
        begin
          timedata <= 64'd0;
          done     <= 1'b0;
        end
      else
          if(add)
            begin
                timedata <= Time1 + Time2 + cnt_r*CLKTIME;
                done     <= 1'b1;
            end
          else
            begin
                timedata <= timedata;
                done     <= 1'b0;
            end
  end

endmodule
