// +FHDR------------------------------------------------------------
//                 Copyright (c) 2017 JSZHANG .
//                     ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Project       ：TDC_Data_Read.v
// Author        ：JSZHANG
// Version       : 1
// Date          : 2017-11-06 17:18
// Last Modified :
// -----------------------------------------------------------------
// Abstract      : 读取TDC的数据，相应的时序根据TDC手册
//
// -FHDR------------------------------------------------------------
module TDC_Data_Read(
    input  clk,               // 时钟
    input  reset_n,           // 复位信号
    input  read,              // 外部的读请求,高有效，该信号应该是来自SDK端
    input  [3:0]addr_in,      // 外部读地址信号
    input  [27:0]data_in,     // 来自TDC的数据信号
    output reg[27:0]data_out, // 输出给别的模块
    output reg[3:0]addr_out,  // 输出给TDC的地址信号
    input  EF1,               // 至TDC，FIFO1空标志，高电平有效
    output reg RDN,           // 至TDC，读请求信号
    output reg CSN            // 至TDC，片选信号
);

reg rst_r1,rst_r2;
wire reset_n_o;                      // 异步复位，同步释放处理后的信号

always@(posedge clk,negedge reset_n) // 对复位信号进行同步置位异步释放处理
  begin
      if(!reset_n)
        begin
            rst_r1 <= 1'b0;
            rst_r2 <= 1'b0;
        end
      else
        begin
            rst_r1 <= 1'b1;
            rst_r2 <= rst_r1;
        end
  end
assign reset_n_o = rst_r2;

reg read_r1,read_r2;
wire read_flag;                        // read信号检测标志,该信号是一个脉冲
always@(posedge clk,negedge reset_n_o) // 检测read的上升沿,标志一次读请求
  begin
      if(!reset_n_o)
        begin
            read_r1 <= 1'b0;
            read_r2 <= 1'b0;
        end
      else
        begin
            read_r1 <= read;
            read_r2 <= read_r1;
        end
  end
assign read_flag = read_r1 & !read_r2;

reg[3:0]addr_r;
reg[27:0]data_r;
always@(posedge clk,negedge reset_n_o) //将地址信号锁存住 
  begin
      if(!reset_n_o)     addr_r <= 4'hz;
      else if(read_flag) addr_r <= addr_in;
      else               addr_r <= addr_r;
  end
always@(posedge clk,negedge reset_n_o)
  begin
      if(!reset_n_o)     data_r <= 4'hz;
      else if(read_flag) data_r <= data_in;
      else               data_r <= data_r;
  end
localparam IDLE   = 4'b0001, //数据读取的四个过程
           READY  = 4'b0010,
           READED = 4'b0100,
           DONE   = 4'b1000;

reg [3:0]read_cs,read_ns;
always@(posedge clk,negedge reset_n_o)
  begin
      if(!reset_n_o) read_cs <= IDLE;
      else           read_cs <= read_ns;
  end
always@(*)
begin
    if(!reset_n_o)
        read_ns = IDLE;
    else
        case(read_cs)
            IDLE   : if(read_flag && !EF1) read_ns = READY; //当read_flag有效时开始数据读取操作
                     else                  read_ns = IDLE;
            READY  : read_ns = READED;
            READED : read_ns = DONE;
            DONE   : read_ns = IDLE;
            default: read_ns = IDLE;
        endcase
end

always@(*)
  begin
      if(!reset_n_o)
        begin
            data_out <= 28'hZ;
            addr_out <= 4'hz;
        end
      else
        begin
            case(read_cs)
                READY:
                  begin
                      data_out <= data_r;
                      addr_out <= addr_r;
                  end
                READED:
                  begin
                      data_out <= data_r;
                      addr_out <= addr_r;
                  end
                DONE    :
                  begin
                      data_out <= data_r;
                      addr_out <= addr_r;
                  end
                default :
                  begin
                      data_out <= 28'hZ;
                      addr_out <= 4'hZ;
                  end
              endcase
        end
  end
always@(*)
  begin
      if(!reset_n_o)
        begin
            CSN = 1'b1;
            RDN = 1'b1;
        end
      else
        begin
            case(read_cs)
                READED:
                  begin
                      CSN = 1'b0;
                      RDN = 1'b0;
                  end
                DONE:
                  begin
                      CSN = 1'b1;
                      RDN = 1'b1;
                  end
                default:
                  begin
                      CSN = 1'b1;
                      RDN = 1'b1;
                  end
              endcase
        end
  end
endmodule
