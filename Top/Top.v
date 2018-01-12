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
    input start,stop,                           // 开始结束测量的标志
    output WRN_o,CSN_o,RDN_o,                   // 写、片选、读使能
    output StopDis1,StopDis2,StopDis3,StopDis4, // 端口disable
    output TDC_stop,TDC_start,                  // 控制TDC的开始结束测量
    output [3:0]addr,                           // 地址
    output done,                                // 完成一次数据
    output [63:0]timedata,                      // 一次测量的最终数据
    inout [27:0]data,                           // 数据
    output AluTrigger,
    input EF1,
    output flag                                 //初始化完成标志 
);
wire WRN;
wire CSN_1,CSN_2;
wire [27:0]data_initial;
wire [3:0]addr_init;
wire [3:0]addr_out;
wire [3:0]addr_in;
wire [27:0]data_out;

//片选当任何一个端口请求时都应该有效
assign CSN_o = CSN_1 & CSN_2;
assign addr = flag ? addr_init : addr_out;
assign data = flag ? data_initial : 28'hZZZ_ZZZZ;
assign addr_in = 4'h8;
//TDC初始化，配置内部工作方式寄存器
TDC_Initial TDC_Initial_i1(
    .clk      (clk),
    .reset_n  (reset_n),
    .WRN      (WRN_o),
    .CSN      (CSN_1),
    .flag     (flag),     //flag为0时完成初始化 
    .StopDis1 (StopDis1),
    .StopDis2 (StopDis2),
    .StopDis3 (StopDis3),
    .StopDis4 (StopDis4),
    .addr     (addr_init),   // 地址
    .data     (data_initial) // 数据
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

//读TDC中的数据
TDC_Data_Read u_TDC_Data_Read(
    .clk       (clk),
    .reset_n   (reset_n),
    .read      (read),
    .addr_in   (addr_in),  // 读地址
    .data_in   (data),
    .data_out  (data_out),
    .addr_out  (addr_out),
    .EF1       (EF1),
    .RDN       (RDN_o),
    .CSN       (CSN_2),
    .AluTrigger(AluTrigger)
);

//在合适的时间产生读使能
Flag_Read u_Flag_Read(
    .clk      (clk),
    .reset_n  (reset_n),
    .TDC_stop (TDC_stop),
    .read     (read)
);

Data_Handle u_Data_Handle(
	.clk       (clk),
	.reset_n   (reset_n),
	.clk_i     (clk_i),
	.TDC_stop  (TDC_stop),
	.start     (start),
	.stop      (stop),
	.AluTriger (AluTrigger),
	.data_in   (data_out),   //come from TDC_Data_Read
	.timedata  (timedata),
	.done      (done)
);
endmodule
