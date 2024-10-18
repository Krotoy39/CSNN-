`include    "F:/FPGA_program/cnn_edge/adc.v"

module      adc_top(
    input               clk                 ,
    input               rst_n               ,
    input               key_state           ,
    input[1:0]          system_state        ,     
    input               dout                ,
    input               eoc                 ,
    output   wire       din                 ,
    output   wire       cs                  ,
    output   wire       ioclk               ,
    output   reg[15:0]  ain_ave             ,
    output   reg        sample_end
);
wire[11:0]              adc_out             ;
reg[7:0]                din_address         ;
wire                    adc_state           ;
reg                     en_adc              ;
parameter   IDLE=2'b00,SAMPLE=2'b01,UART=2'b11,COMPLETE=2'b10;
parameter   CNT_READ = 32 , BIT_READ = 5 ;
adc             adc(
    .clk            (clk),
    .rst_n          (rst_n),
    .key_state      (key_state),
    .dout           (dout),
    .eoc            (eoc),
    .din            (din),
    .cs             (cs),
    .ioclk          (ioclk),
    .din_address    (din_address),
    .adc_state      (adc_state),
    .en_adc         (en_adc),
    .adc_out        (adc_out)
);

//adc使能信号
always @(*)begin
    if(!rst_n) en_adc = 0;
    else if(key_state&&system_state==SAMPLE) en_adc = 1;
    else en_adc=0;
end

//adc_state边沿检测
reg     adc_state1,adc_state2       ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        adc_state1<=0;
        adc_state2<=0;
    end
    else begin 
        adc_state1<=adc_state;
        adc_state2<=adc_state1;
    end
end
assign  nedge = !adc_state1&&adc_state2;
assign  pedge = adc_state1&&!adc_state2;

//数每一个通道读了多少次  
reg[5:0]    cnt_read        ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_read<=0;
    else if(key_state&&system_state==SAMPLE)begin
        if(cnt_read==(CNT_READ+1)) cnt_read<=cnt_read;
        else if(nedge) cnt_read<=cnt_read+1;
    end
    else cnt_read<=0;
end

reg         ain_end         ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) ain_end<=0;
    else if(key_state&&system_state==SAMPLE)begin
        if(cnt_read==CNT_READ+1) ain_end<=1;
        else ain_end<=0;
    end
end

//adc_out加和
reg[15:0]       ain_add         ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) ain_add<=0;
    else if(key_state&&system_state==SAMPLE)begin
        if(pedge)begin
           if(cnt_read==0) ain_add<=0;
           else if(cnt_read == CNT_READ+1) ain_add<=ain_add;
           else ain_add<=ain_add+adc_out;
       end
   end
   else ain_add<=ain_add;
end

//adc平均
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) ain_ave<=0;
    else if(key_state&&system_state==SAMPLE)begin
        if(cnt_read==CNT_READ+1) ain_ave<=(ain_add>>BIT_READ);
        else ain_ave<=ain_ave;
    end
end

//din_address
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) din_address<=8'b0010_1000;
    else if(key_state&&system_state==SAMPLE) din_address<=8'b0010_1000;
    else din_address<=8'b0011_1000;
end 

//sample_end信号，标志采样结束
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) sample_end<=0;
    else if(key_state)begin
        if(cnt_read==CNT_READ+1) sample_end<=1;
        else sample_end<=0;
    end
    else sample_end<=0;
end
endmodule 
