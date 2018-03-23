module fifo_ctrl(
    input clk,
    input reset_n,
    input done,
    input read_in,             // come from SDK
    output full_one,           // to SDK
    input [63:0]datain_TDC,    // come from TDC
    input [63:0]datain_FIFO1,  // come from FIFO1 dout
    input [63:0]datain_FIFO2,  // come from FIFO2 dout
    output[63:0]dataout_FIFO1, // to FIFO1 din
    output[63:0]dataout_FIFO2, // to FIFO2 din
    output[63:0]dataout_SDK,   // to SDK
    input full1,               // the flag of FIFO1
    input full2,               // the flag of FIFO2
    output reg write1,         // FIFO1 write enable
    output reg write2,         // FIFO2 write enable
    input empty1,              // the flag of fifo1
    input empty2,              // the flag of fifo2
    output reg read1           // FIFO1 read enable
    output reg read2           // FIFO2 read enable
);
reg ID_fifo_w;
reg ID_fifo_r;
reg read_in_r1,read_in_r2;
wire pose_read;
// generate the full_one
// when anyone FIFO is full set the full_one entil the fifo is readed
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          full_one <= 1'b0;
      else
          if(full1 || full2)
              full_one <= 1'b1;
          else
              full_one <= 1'b0;
  end
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          ID_fifo_r <= 1'b0;
      else
          if(full1)
              ID_fifo_r <= 1'b0;
          else if(full2)
              ID_fifo_r <= 1'b1;
          else
              ID_fifo_r <= ID_fifo_r;
  end
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          ID_fifo_w <= 1'b0;
      else
          if(full1)
              ID_fifo_w <= 1'b1;
          else if(full2)
              ID_fifo_w <= 1'b0;
          else
              ID_fifo_w <= ID_fifo_w;
  end

always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
        begin
            write1 <= 1'b0;
            write2 <= 1'b0;
        end
      else
        begin
            if(ID_fifo_w==0)
                if(done)
                  begin
                      write1 <= 1'b1;
                      write2 <= 1'b0;
                  end
                else
                  begin
                      write1 <= 1'b0;
                      write2 <= 1'b0;
                  end
            else
                if(done)
                  begin
                      write1 <= 1'b0;
                      write2 <= 1'b1;
                  end
                else
                  begin
                      write1 <= 1'b0;
                      write2 <= 1'b0;
                  end
        end
  end

// check the posedge of read_in
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
        begin
            read_in_r1 <= 1'b0;
            read_in_r2 <= 1'b0;
        end
      else
        begin
            read_in_r1 <= read_in;
            read_in_r2 <= read_in_r1;
        end
  end
assign pose_read = read_in_r1 & (!read_in_r2);
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
        begin
            read1 <= 1'b0;
            read2 <= 1'b0;
        end
      else
        begin
            case({pose_read,ID_fifo_r})
                2'b10:
                    read1 <= 1'b1;
                2'b11:
                    read2 <= 1'b1;
                default:
                  begin
                      read1 <= 1'b0;
                      read2 <= 1'b0;
                  end
            endcase
        end
  end

assign dataout_SDK   = (ID_fifo_r==1'b0) ? datain_FIFO1 : datain_FIFO2;
assign dataout_FIFO1 = (ID_fifo_w==1'b0) ? datain_TDC: 64'd0;
assign dataout_FIFO2 = (ID_fifo_w==1'b1) ? datain_TDC: 64'd0;
endmodule
