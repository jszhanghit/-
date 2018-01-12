// +FHDR------------------------------------------------------------
//                 Copyright (c) 2017 JSZHANG .
//                     ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Project       ：TDC_Initial.v
// Author        ：JSZHANG
// Version       : 01
// Date          : 2017-11-01 10:01
// Last Modified : 2017-11-03 22:10:42 周五
// -----------------------------------------------------------------
// Abstract      : TDC初始化模块
//
// -FHDR------------------------------------------------------------
module TDC_Initial(
        input clk,
        input reset_n,
        output reg WRN,CSN,  // 读写使能位，低电平有效
        output reg flag,     // 初始化完成标志，如果flag=0,标志着初始化完成
        output reg StopDis1, // 关闭TStop1和TStop2 TTL的输入，高有效，表示不接受数据
        output reg StopDis2, // 关闭TStop3和TStop1 TTL的输入
        output reg StopDis3,
        output reg StopDis4,
        output reg[3:0]addr, //地址总线
        output reg[27:0]data //数据总线
);
localparam HIGH   = 1'b1,
           LOW    = 1'b0;

//寄存器配置值
//0-7、14写寄存器
//8-10读寄存器
//11、12读写寄存器
localparam REGISTER0  = 28'h007_FC81,
           REGISTER1  = 28'h000_0000,
           REGISTER2  = 28'h000_0002,
           REGISTER3  = 28'h000_0000,
           REGISTER4  = 28'h600_0000,
           REGISTER5  = 28'h0E0_04DA,
           REGISTER6  = 28'h000_0000,
           REGISTER7  = 28'h028_1FB4,
           REGISTER11 = 28'h7FF_0000,
           REGISTER12 = 28'h000_0000,
           REGISTER14 = 28'h000_0000;

//独热型编码
localparam IDLE          = 4'b0001;
localparam WRITE_PERIOD1 = 4'b0010;
localparam WRITE_PERIOD2 = 4'b0100;
localparam WRITE_PERIOD3 = 4'b1000;

reg[3:0]write_ns,write_cs;
reg[3:0]addr_r;
reg[27:0]data_r;
always@(posedge clk,negedge reset_n)
  begin //现态逻辑
      if(!reset_n) write_cs <= IDLE;
      else         write_cs <= write_ns;
  end

//当flag为1时，循环进行该状态，知道flag为0
always@(*)//次态逻辑
  begin
      if(!reset_n || !flag)
          write_ns = IDLE;
      else
          case(write_cs)
              IDLE          : write_ns = WRITE_PERIOD1;
              WRITE_PERIOD1 : write_ns = WRITE_PERIOD2;
              WRITE_PERIOD2 : write_ns = WRITE_PERIOD3;
              WRITE_PERIOD3 : write_ns = WRITE_PERIOD1;
          endcase
  end

always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n) addr_r <= 4'hf;
      else addr_r         <= addr;
  end
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n) data_r <= 28'h000_0000;
      else         data_r <= data;
  end
always@(*)//地址,数据,flag
  begin
      if(!reset_n)
        begin
            addr = 4'hf;
            data = 28'h000_0000;
            flag = 1'b1;
        end
      else if(write_cs == WRITE_PERIOD1)
          case(addr)
              4'hf    :
                begin
                    addr = 4'd0;
                    data = REGISTER0;
                    flag = 1'b1;
                end
              4'd0    :
                begin
                    addr = 4'd1;
                    data = REGISTER1;
                    flag = 1'b1;
                end
              4'd1    :
                begin
                    addr = 4'd2;
                    data = REGISTER2;
                    flag = 1'b1;
                end
              4'd2    :
                begin
                    addr = 4'd3;
                    data = REGISTER3;
                    flag = 1'b1;
                end
              4'd3    :
                begin
                    addr = 4'd4;
                    data = REGISTER4;
                    flag = 1'b1;
                end
              4'd4    :
                begin
                    addr = 4'd5;
                    data = REGISTER5;
                    flag = 1'b1;
                end
              4'd5    :
                begin
                    addr = 4'd6;
                    data = REGISTER6;
                    flag = 1'b1;
                end
              4'd6    :
                begin
                    addr = 4'd7;
                    data = REGISTER7;
                    flag = 1'b1;
                end
              4'd7    :
                begin
                    addr = 4'd11;
                    data = REGISTER11;
                    flag = 1'b1;
                end
              4'd11   :
                begin
                    addr = 4'd12;
                    data = REGISTER12;
                    flag = 1'b1;
                end
              4'd12   :
                begin
                    addr = 4'd14;
                    data = REGISTER14;
                    flag = 1'b1;
                end
              4'd14   :
                begin
                    addr = 4'he;
                    data = 28'd0;
                    flag = 1'b0;
                end
              default :
                begin
                    addr = 4'he;
                    data = 28'd0;
                end
            endcase
      else
        begin
            addr = addr_r;
            data = data_r;
        end
  end

always@(*)//配置寄存器过程中不接受测量信号
  begin
      if(!reset_n)
        begin
            StopDis1 = 1'b1;
            StopDis2 = 1'b1;
            StopDis3 = 1'b1;
            StopDis4 = 1'b1;
        end
      else if(flag)
        begin
            StopDis1 = 1'b1;
            StopDis2 = 1'b1;
            StopDis3 = 1'b1;
            StopDis4 = 1'b1;
        end
      else
        begin
            StopDis1 = 1'b0;
            StopDis2 = 1'b0;
            StopDis3 = 1'b0;
            StopDis4 = 1'b0;
        end
  end

//              1       2       3       4       5       6
//           +---+   +---+   +---+   +---+   +---+   +---+   +--
// clk       |   |   |   |   |   |   |   |   |   |   |   |   |
//           +   +---+   +---+   +---+   +---+   +---+   +---+
//                   +-------+               +-------+
// CSN               |       |               |       |
//          ---------+       +---------------+       +---------
//                   +-------+               +-------+
// WRN               |       |               |       |
//          ---------+       +---------------+       +---------
//          - ------- ------- ------- ------- ------- ------- -
// state     X   1   X   2   X   3   X  1    X   2   X   3   X
//          - ------- ------- ------- ------- ------- ------- -
always@(*)//写使能、片选
  begin
      if(!reset_n)
        begin
            CSN = 1'b1;
            WRN = 1'b1;
        end
      else
        begin
            if(write_cs == WRITE_PERIOD2)
              begin
                  CSN = 1'b0;
                  WRN = 1'b0;
              end
            else if(write_cs == WRITE_PERIOD3)
              begin
                  CSN = 1'b1;
                  WRN = 1'b1;
              end
            else
              begin
                  CSN = 1'b1;
                  WRN = 1'b1;
              end
        end
  end
endmodule
