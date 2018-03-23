module First_pos(
    input clk,
    input reset_n,
    input clk_i,
    input start,
    input stop,
    output TDC_start,
    output reg TDC_stop
);
localparam IDLE       = 4'b0000,
           WAIT_FOR_L = 4'b0001,
           WAIT_FOR_H = 4'b0010,
           HOLD_ONE   = 4'b0100,
           RETURN     = 4'b1000;
reg TDC_start_r1,TDC_start_r2;
wire TDC_start_pos;
reg flag;
reg [3:0]cnt;
reg [3:0]state,state_next;
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
        begin
            TDC_start_r1 <= 1'b0;
            TDC_start_r2 <= 1'b0;
        end
      else
        begin
            TDC_start_r1 <= TDC_start;
            TDC_start_r2 <= TDC_start_r1;
        end
  end
assign TDC_start_pos = TDC_start_r1 & (!TDC_start_r2);
/***********************************************/
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          state <= IDLE;
      else
          state <= state_next;
  end
always@(*)
  begin
      if(!reset_n)
          state_next = IDLE;
      else
          case(state)
              IDLE:
                  if(cnt==4'h4)
                      state_next = WAIT_FOR_L;
                  else
                      state_next = IDLE;
              WAIT_FOR_L:
                  if(!clk_i) 
                      state_next = WAIT_FOR_H;
                  else
                      state_next = WAIT_FOR_L;
              WAIT_FOR_H:
                  if(clk_i)
                      state_next = HOLD_ONE;
                  else
                      state_next = WAIT_FOR_H;
              HOLD_ONE:
                  state_next = RETURN;
              RETURN:
                  state_next = IDLE;
              default:
                  state_next = IDLE;
          endcase
  end
always@(*)
  begin
      if(!reset_n)
          TDC_stop = 1'b0;
      else
          case(state_next)
              WAIT_FOR_H:
                  TDC_stop = clk_i;
              HOLD_ONE:
                  TDC_stop = 1'b1;
              RETURN:
                  TDC_stop = 1'b1;
              default:
                  TDC_stop = 1'b0;
          endcase
  end
/****************************************************/
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          flag <= 1'b0;
      else
          casez({TDC_start_pos,cnt})
              5'b1????:
                  flag <= 1'b1;
              5'b01110:
                  flag <= 1'b0;
              default:
                  flag <= flag;
          endcase
  end
always@(posedge clk,negedge reset_n)
  begin
      if(!reset_n)
          cnt <= 4'd0;
      else
          if(flag)
              cnt <= cnt + 1'b1;
          else
              cnt <= 4'd0;

  end
assign TDC_start = start | stop;
endmodule
