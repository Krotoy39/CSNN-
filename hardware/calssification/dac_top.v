`include "F:/FPGA_program/cnn_edge/dac1.v"
`include "F:/FPGA_program/cnn_edge/dac2.v"
`include "F:/FPGA_program/cnn_edge/dac3.v"
`include "F:/FPGA_program/cnn_edge/dac4.v"

module dac_top(
    input               clk                     ,   
    input               rst_n                   ,
    input               key_state               ,
    input[1:0]          system_state            ,
    input[3:0]          field                   ,
    output  reg         cs                      ,
    output  reg         sck                     ,
    output  reg[4:0]    cnt_sck                 ,
    output  reg[15:0]   data_sdi1               ,
    output  reg[15:0]   data_sdi2               ,
    output  reg[15:0]   data_sdi3               ,
    output  reg[15:0]   data_sdi4               ,
    output  wire        sdi1                    ,
    output  wire        sdi2                    ,
    output  wire        sdi3                    ,
    output  wire        sdi4                    ,
    output  wire        ldac1                   ,
    output  wire        ldac2                   ,
    output  wire        ldac3                   ,
    output  wire        ldac4                   ,
    input   [4:0]       cnt_RF
);

reg             en_dac              ;
dac1                dac1(
    .clk                (clk),
    .rst_n              (rst_n),
    .key_state          (key_state),
    .data_sdi           (data_sdi1),
    .en_dac             (en_dac),
    .cs                 (cs),
    .sck                (sck),
    .cnt_sck            (cnt_sck),
    .sdi                (sdi1),
    .ldac               (ldac1)
);

dac2                dac2(
    .clk                (clk),
    .rst_n              (rst_n),
    .key_state          (key_state),
    .en_dac             (en_dac),
    .data_sdi           (data_sdi2),
    .cs                 (cs),
    .sck                (sck),
    .cnt_sck            (cnt_sck),
    .sdi                (sdi2),
    .ldac               (ldac2)
);

dac3                dac3(
    .clk                (clk),
    .rst_n              (rst_n),
    .key_state          (key_state),
    .en_dac             (en_dac),
    .data_sdi           (data_sdi3),
    .cs                 (cs),
    .sck                (sck),
    .cnt_sck            (cnt_sck),
    .sdi                (sdi3),
    .ldac               (ldac3)
);

dac4                dac4(
    .clk                (clk),
    .rst_n              (rst_n),
    .key_state          (key_state),
    .en_dac             (en_dac),
    .data_sdi           (data_sdi4),
    .cs                 (cs),
    .sck                (sck),
    .cnt_sck            (cnt_sck),
    .sdi                (sdi4),
    .ldac               (ldac4)
);

parameter
    V_READ  = 16'b0011_0010_0101_1000,
    V_0V    = 16'b0011_0000_0000_0000,
    SHUTDOWN= 16'b0000_0000_0000_0000;
parameter
    IDLE = 2'b00,
    SAMPLE = 2'b01,
    UART = 2'b11,
    COMPLETE = 2'b10;

//12.5MHz时钟信号的生成
reg[2:0]        cnt_100ns           ;
reg[1:0]        cnt_clk             ;
reg             cs1,cs2,cs3         ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_clk<=0;
    else if(key_state&&system_state==SAMPLE) cnt_clk<=cnt_clk+1;
    else cnt_clk<=0;
end 

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_100ns<=0;
    else if(key_state&&system_state==SAMPLE&&!cs)begin
        if(cnt_100ns==3'd5) cnt_100ns<=cnt_100ns;
        else cnt_100ns<=cnt_100ns+1;
    end
    else cnt_100ns<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) sck<=0;
    else if(key_state&&system_state==SAMPLE)begin
        if(cnt_100ns==3'd5)begin
            if(!cnt_clk[1]) sck<=1;
            else if(cnt_clk[1]) sck<=0;
            else sck<=sck;
        end
        else sck<=0;
    end
    else sck<=0;
end

reg[4:0]        cnt_500ns           ;//500ns之后清空cnt_sck
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_500ns<=0;
    else if(key_state&&system_state==SAMPLE)begin
        if(en_dac) cnt_500ns<=0;
        else if(!en_dac&&cnt_500ns==5'd25) cnt_500ns<=cnt_500ns;
        else if(cnt_sck==5'd16) cnt_500ns<=cnt_500ns+1;
        else cnt_500ns<=cnt_500ns;
    end
    else cnt_500ns<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_sck<=0;
    else if(key_state&&system_state==SAMPLE&&cnt_100ns==3'd5)begin
        if(cnt_sck==5'd16) cnt_sck<=cnt_sck;
        else if(cnt_clk==2'd1) cnt_sck<=cnt_sck+1;
        else cnt_sck<=cnt_sck;
    end
    else if(en_dac) cnt_sck<=0;
    else cnt_sck<=cnt_sck;
end

//cs信号
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cs<=1;
    else if(key_state&&system_state==SAMPLE)begin
        if(en_dac) cs<=0;
        else if(cnt_sck==5'd16) cs<=1;
        else cs<=cs;
    end
    else cs<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cs1<=1;
        cs2<=1;
        cs3<=1;
    end
    else if(key_state&&system_state==SAMPLE)begin
        cs1<=cs;
        cs2<=cs1;
        cs3<=cs2;
    end
    else begin
        cs1<=1;
        cs2<=1;
        cs3<=1;
    end
end

//en_dac的信号
reg[7:0]    cnt_1600ns      ;//一个spi周期为1500ns，1600ns之后进行下一个spi动作
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_1600ns<=0;
    else if(key_state&&system_state==SAMPLE)begin
        if(cnt_RF==16) cnt_1600ns<=0;
        else if(cnt_1600ns==80) cnt_1600ns<=0;
        else cnt_1600ns<=cnt_1600ns+1;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) en_dac<=0;
    else if(key_state&&system_state==SAMPLE)begin
        if(cnt_RF==16) en_dac<=0;
        else if(cnt_1600ns==80) en_dac<=1;
        else en_dac<=0;
    end
    else en_dac<=0;
end

//dac行为
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) data_sdi1<=SHUTDOWN;
    else if(key_state&&system_state==SAMPLE)begin
        if(cnt_RF==16) data_sdi1<=SHUTDOWN;
        else data_sdi1<=field[3]?V_READ:V_0V;
    end
    else data_sdi1<=SHUTDOWN;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) data_sdi2<=SHUTDOWN;
    else if(key_state&&system_state==SAMPLE)begin
        if(cnt_RF==16) data_sdi2<=SHUTDOWN;
        else data_sdi2<=field[2]?V_READ:V_0V;
    end
    else data_sdi2<=SHUTDOWN;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) data_sdi3<=SHUTDOWN;
    else if(key_state&&system_state==SAMPLE)begin
        if(cnt_RF==16) data_sdi3<=SHUTDOWN;
        else data_sdi3<=field[1]?V_READ:V_0V;
    end
    else data_sdi3<=SHUTDOWN;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) data_sdi4<=SHUTDOWN;
    else if(key_state&&system_state==SAMPLE)begin
        if(cnt_RF==16) data_sdi4<=SHUTDOWN;
        else data_sdi4<=field[0]?V_READ:V_0V;
    end
    else data_sdi4<=SHUTDOWN;
end
endmodule 
