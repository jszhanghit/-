// +FHDR------------------------------------------------------------
//                 Copyright (c) 2017 JSZHANG .
//                     ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Project       ：First_pos.v
// Author        ：JSZHANG
// Version       : 01
// Date          : 2017-12-23 20:42
// Last Modified : 2017-12-26 16:20:33 周二
// -----------------------------------------------------------------
// Abstract      : tdc开始结束信号
//                 该模块经过修改，暂时仿真好用
//                 这个模块的时序是最难处理的地方，许多地方的东西很难于理解，
//                 不过大量的时序都是经过深刻推敲的，是暂时处理比较好的一款内
//                 容了，主要思想是由于外部晶振沿里时钟沿比较近的时候难于处理
//                 时序，很难满足保持建立时间，所以经过一系列的处理将TDC_stop
//                 的时刻推迟到之后几个周期
// -FHDR------------------------------------------------------------
module First_pos(
    input clk,        // 时钟
    input reset_n,    // 复位
    input clk_i,      // 外部高精度晶振输入
    input start,      // 外部开始信号
    input stop,       // 外部结束信号
    output TDC_start, // TDC开始
    output TDC_stop   // TDC结束
    //output reg Done
);

reg flag;
reg [1:0]cnt;
wire pos_clk;
reg clk_r1,clk_r2;
reg [1:0]cnt_s;
reg [3:0]delay_time;
reg start_pos;

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
assign pos_clk = clk_i & !clk_r2; //外部晶振上升沿 

//flag是整个测试过程中的关键标志，TDC_start有效时flag置位，直到TDC_stop有效后
//的一个周期复位
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          flag <= 1'b0;
      else
          if(TDC_start)
              flag <= 1'b1;
          else if(cnt_s == 2'b01)
              flag <= 1'b0;
          else
              flag <= flag;
  end

//cnt_s用于延时TDC_stop有效后flag复位的时间，保证flag在TDC_stop有效后保持有效
//超过一个周期
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          cnt_s <= 2'b00;
      else
          if(TDC_stop)
              cnt_s <= cnt_s + 2'b01;
          else
              cnt_s <= 2'b00;
  end

//该模块主要用于控制TDC_start后的一段时间后才开始进行外部晶振的计数
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          delay_time <= 4'b0000;
      else
          if(flag)
              if(delay_time >= 4'b0100)
                  delay_time <= delay_time;
              else
                  delay_time <= delay_time + 4'b0001;
          else
              delay_time <= 4'b0000;
  end

//当TDC_start后的若干个时间段后并且满足pos_clk为低电平时控制外部晶振计数的标志
//位置位，如果不在pos_clk为低电平时就进行计数的话，可能会产生在pos_clk的中间时
//间进行计数，出现错误结果
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          start_pos <= 1'b0;
      else
          if(flag)
              if(delay_time >= 4'b0010 && !pos_clk)
                  start_pos <= 1'b1;
              else
                  start_pos <= start_pos;
          else
              start_pos <= 1'b0;
  end
//经过上面的过程，大功告成，进行最后的外部晶振上升沿计数
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          cnt <= 2'b00;
      else
          if(start_pos)
              if(pos_clk && delay_time >= 4'b0001)
                  if(cnt == 2'b11)
                      cnt <= 2'b00;
                  else
                      cnt <= cnt + 1'b1;
              else
                  cnt <= cnt;
          else
              cnt <= 2'b00;
  end

//TDC_stop有效后标志一次测量完成
//always@(posedge clk,negedge reset_n)
  //begin
      //if(!reset_n)
          //Done <= 1'b0;
      //else
          //if(TDC_stop)
              //Done <= 1'b1;
          //else
              //Done <= 1'b0;
  //end

assign TDC_stop = (cnt==2'b10 || cnt == 2'b11) ? pos_clk : 1'b0;
assign TDC_start = start | stop;

endmodule
