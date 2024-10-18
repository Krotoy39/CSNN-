`include "E:/Users/LK/FPGA_PROGRAM/system_22/adc.v"
module adc_top(
    input               clk         ,
    input               rst_n       ,
    input               key_state   ,
    input               dout        ,
    input               eoc         ,
    output  wire        din         ,
    output  wire        cs          ,
    output  wire        ioclk       ,
    output  reg         en_adc      ,
    output  reg[7:0]    din_address ,
    input[2:0]          system_state,
    output  reg[3:0]    ain_state   ,
    output  reg[11:0]   ain_ave            
);

wire            adc_state   ;
wire[11:0]      adc_out     ;
adc         uut(
    .clk            (clk),
    .rst_n          (rst_n),
    .adc_state      (adc_state),
    .adc_out        (adc_out),
    .en_adc         (en_adc),
    .key_state      (key_state),
    .din_address    (din_address),
    .dout           (dout),
    .eoc            (eoc),
    .din            (din),
    .cs             (cs),
    .ioclk          (ioclk)
);

//adc使能信号
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) en_adc<=0;
    else if(system_state==3'd1&&key_state) en_adc<=1;
    else en_adc<=0;
end
//adc_state边沿检测
reg     adc_state1,adc_state2;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin 
        adc_state1<=0;
        adc_state2<=0;
    end
    else if(key_state)begin 
        adc_state1<=adc_state;
        adc_state2<=adc_state1;
    end
    else begin 
        adc_state1<=0;
        adc_state2<=0;
    end
end

assign nedge = !adc_state1&&adc_state2;
//din_address
reg[5:0]            cnt_read;//数adc的每一个通道读了多少次
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) cnt_read<=0;
    else if(key_state&&system_state==1)begin
        if(ain_state==5) cnt_read<=0;
        else begin
            if(cnt_read == 34) cnt_read<=0;
            else if(!adc_state1&&adc_state2) cnt_read<=cnt_read+1;
            else cnt_read<=cnt_read;
        end
    end
    else cnt_read<=0;
end

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) ain_state<=0;
    else if(key_state&&system_state==1)begin
        if(!adc_state1&&adc_state2)begin 
            if(ain_state==5) ain_state<=ain_state;
            else if(cnt_read==33) ain_state<=ain_state + 1;
            else ain_state<=ain_state;
        end
        else ain_state<=ain_state;
    end
    else ain_state<=0;
end

//adc_out加和
reg[17:0]     ain_add;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) ain_add<=0;
    else if(key_state&&system_state==1)begin
        if(adc_state1&&!adc_state2)begin
            case(cnt_read)
                0,1:ain_add<=0;
                2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33:ain_add<=ain_add+adc_out;
                default:ain_add<=ain_add;
            endcase
        end
        else ain_add<=ain_add;
    end
    else ain_add<=0;
end
//adc平均
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) ain_ave<=0;
    else if(key_state&&system_state==1)begin
        if(cnt_read==33&&!adc_state1&&adc_state2) ain_ave<=ain_add[17:6];
        else ain_ave<=ain_ave;
    end
    else ain_ave<=0;
end
//din_address
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) din_address<=8'b11111111;
    else if(key_state&&system_state==1)begin 
        case(ain_state)
            0:din_address<=8'b1111_1111;
            1:din_address<=8'b0101_1000;
            2:din_address<=8'b0110_1000;
            3:din_address<=8'b0101_1000;
            4:din_address<=8'b0110_1000;
            5:din_address<=8'b1111_1111;
            default:din_address<=8'b1111_1111;
        endcase
    end
    else din_address<=8'b1111_1111;
end
endmodule
