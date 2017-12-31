// +FHDR------------------------------------------------------------
//                 Copyright (c) 2017 JSZHANG .
//                     ALL RIGHTS RESERVED
// -----------------------------------------------------------------
// Project       ：TDC.v
// Author        ：JSZHANG
// Version       : 01
// Date          : 2017-12-19 15:03
// Last Modified :
// -----------------------------------------------------------------
// Abstract      : Top 用于例化其他功能模块
//
// -FHDR------------------------------------------------------------
module TDC(
    input clk,
    input reset_n,
    input clk_i,                                // 外部时钟晶振的输入
    input start,stop;                           // 开始结束测量的标志
    output WRN_o,CSN_o,RDN_o,                   // 写、片选、读使能
    output PuResN,                              // 上电复位，低电平有效
    output StopDis1,StopDis2,StopDis3,StopDis4, // 端口disable
    output TDC_stop,TDC_start;                  // 控制TDC的开始结束测量
    output [3:0]addr,                           // 地址
    inout[27:0]data                             // 数据
);
wire flag;
wire WRN;
wire CSN_1,CSN_2;

//片选当任何一个端口请求时都应该有效
assign CSN_o = CSN_1 | CSN_2;

//TDC初始化，配置内部工作方式寄存器
TDC_Initial TDC_Initial_i1(
    .clk      (clk),
    .reset_n  (reset_n),
    .WRN      (WRN),
    .CSN      (CSN_1),
    .flag     (flag),     //flag为0时完成初始化 
    .PuResN   (PuResN),
    .StopDis1 (StopDis1),
    .StopDis2 (StopDis2),
    .StopDis3 (StopDis3),
    .StopDis4 (StopDis4),
    .addr     (addr),
    .data     (data)
);
//根据start与stop控制tdc工作
First_pos first_pos(
    .clk       (clk),
    .reset_n   (reset_n),
    .clk_i     (clk_i),
    .start     (start),
    .stop      (stop),
    .TDC_stop  (TDC_stop),
    .TDC_start (TDC_start)
);
endmodule
