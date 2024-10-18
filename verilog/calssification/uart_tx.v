module uart_tx(
    input           clk             ,
    input           rst_n           ,
    input           send_en         ,
    input[7:0]      data            ,
    input[2:0]      baud_set        ,
    output  reg     tx              ,
    output  reg     tx_done         ,
    output  reg     uart_state
);

reg[15:0]   bps_DR;//分频计数器最大值
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) bps_DR<=5207;//bps==9600
    else begin 
        case(baud_set)
            0:bps_DR<=5207;//bps==9600
            1:bps_DR<=2603;//bps==19200
            2:bps_DR<=1301;//bps==38400
            3:bps_DR<=867;//bps==57600
            4:bps_DR<=433;//bps==115200
            default:bps_DR<=5207;
        endcase
    end
end

reg         bps_clk;//波特率时钟
reg[15:0]   div_cnt;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) div_cnt<=0;
    else if(uart_state) begin
        if(div_cnt==bps_DR) div_cnt<=0;
        else div_cnt<=div_cnt+1;
    end
    else div_cnt<=0;
end

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) bps_clk<=0;
    else if(div_cnt==1) bps_clk<=1;
    else bps_clk<=0;
end
//数据输出模块设计
reg[3:0]    bps_cnt;//波特率时钟计数器
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) bps_cnt<=0;
    else if(bps_cnt==11) bps_cnt<=0;
    else if(bps_clk) bps_cnt<=bps_cnt+1;
    else bps_cnt<=bps_cnt;
end

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) tx_done<=0;
    else if(bps_cnt==11) tx_done<=1;
    else tx_done<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) uart_state<=0;
    else if(send_en) uart_state<=1;
    else if(bps_cnt==11) uart_state<=0;
    else uart_state<=uart_state;
end

reg[7:0]    r_data_byte;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) r_data_byte<=0;
    else if(send_en) r_data_byte<=data;
    else r_data_byte<=r_data_byte;
end
//数据传输状态控制模块设计
localparam  START_BIT=0,STOP_BIT=1;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) tx<=1;
    else begin
        case(bps_cnt)
            0:tx<=1;
            1:tx<=START_BIT;
            2:tx<=r_data_byte[0];
            3:tx<=r_data_byte[1];
            4:tx<=r_data_byte[2];
            5:tx<=r_data_byte[3];
            6:tx<=r_data_byte[4];
            7:tx<=r_data_byte[5];
            8:tx<=r_data_byte[6];
            9:tx<=r_data_byte[7];
            10:tx<=STOP_BIT;
            default:tx<=1;
        endcase
    end
end
endmodule 
