`include "E:/Users/LK/FPGA_PROGRAM/system_22/adc_top.v"
`include "E:/Users/LK/FPGA_PROGRAM/system_22/key.v"
`include "E:/Users/LK/FPGA_PROGRAM/system_22/dac_top.v"
`include "E:/Users/LK/FPGA_PROGRAM/system_22/sw1.v"
`include "E:/Users/LK/FPGA_PROGRAM/system_22/sw2.v"
`include "E:/Users/LK/FPGA_PROGRAM/system_22/sw15.v"
`include "E:/Users/LK/FPGA_PROGRAM/system_22/sw16.v"
`include "E:/Users/LK/FPGA_PROGRAM/system_22/uart_tx.v"
module system_top_22(
    //系统信号
    input           clk             ,
    input           rst_n           ,
    //adc信号
    input           eoc             ,
    input           dout            ,
    output  wire    din             ,
    output  wire    adc_cs          ,
    output  wire    ioclk           ,
    //dac信号
    output  wire    sdi1            ,
    output  wire    sdi2            ,
    output  wire    sdi15           ,
    output  wire    sdi16           ,
    output  wire    ldac1           ,
    output  wire    ldac2           ,
    output  wire    ldac15          ,
    output  wire    ldac16          ,
    output  wire    sck             ,
    output  wire    dac_cs          ,
    //按键输入
    input           key_in          ,
    //开关控制
    output  wire    in1             ,
    output  wire    in2             ,
    output  wire    in15            ,
    output  wire    in16            ,
    //串口
    output  wire    tx              ,
    //led灯
    output  reg     led
);

parameter   IDLE=0,READ=1,WRITE=2,COMPARE=3,COMPLETE=4;
reg[2:0]            system_state    ;
wire                key_state       ;
wire[11:0]          ain_ave         ;
reg[1:0]            pulse17_state   ;
reg[1:0]            pulse18_state   ;
reg[1:0]            pulse27_state   ;
reg[1:0]            pulse28_state   ;
wire                pulse_complete  ;
wire                en_adc          ;
wire                en_dac          ;
wire[3:0]           ain_state       ;
wire                all_complete    ;
wire[3:0]           dac_top_state   ;
adc_top     adc_top(
    .clk            (clk),
    .rst_n          (rst_n),
    .key_state      (key_state),
    .ain_state      (ain_state),
    .system_state   (system_state),
    .ain_ave        (ain_ave),
    .dout           (dout),
    .eoc            (eoc),
    .din            (din),
    .cs             (adc_cs),
    .ioclk          (ioclk),
    .en_adc         (en_adc),
    .din_address    ()
);

dac_top     dac_top(
    .clk            (clk),
    .rst_n          (rst_n),
    .system_state   (system_state),
    .key_state      (key_state),
    .en_dac         (en_dac),
    .sdi1           (sdi1),
    .sdi2           (sdi2),
    .sdi15          (sdi15),
    .sdi16          (sdi16),
    .ldac1          (ldac1),
    .ldac2          (ldac2),
    .ldac15         (ldac15),
    .ldac16         (ldac16),
    .cs             (dac_cs),
    .sck            (sck),
    .pulse17_state  (pulse17_state),
    .pulse18_state  (pulse18_state),
    .pulse27_state  (pulse27_state),
    .pulse28_state  (pulse28_state),
    .pulse_complete (pulse_complete),
    .state_c        (dac_top_state),
    .data_sdi1      (),
    .data_sdi2      (),
    .data_sdi15     (),
    .data_sdi16     ()
);

key     key(
    .clk            (clk),
    .rst_n          (rst_n),
    .key_in         (key_in),
    .key_state      (key_state)
);

wire                tx_done         ;
wire                uart_state      ;
reg[7:0]            data2uart       ;
reg                 en_uart_tx      ;
uart_tx     uart_tx(
    .clk            (clk),
    .rst_n          (rst_n),
    .send_en        (en_uart_tx),
    .data           (data2uart),
    .baud_set       (3'd4),
    .tx             (tx),
    .tx_done        (tx_done),
    .uart_state     (uart_state)
);

sw1         sw1(
    .clk            (clk),
    .rst_n          (rst_n),
    .system_state   (system_state),
    .key_state      (key_state),
    .in1            (in1),
    .dac_top_state  (dac_top_state)
);

sw2         sw2(
    .clk            (clk),
    .rst_n          (rst_n),
    .system_state   (system_state),
    .key_state      (key_state),
    .in2            (in2),
    .dac_top_state  (dac_top_state)
);

sw15        sw15(
    .clk            (clk),
    .rst_n          (rst_n),
    .system_state   (system_state),
    .pulse17_state  (pulse17_state),
    .pulse27_state  (pulse27_state),
    .key_state      (key_state),
    .in15           (in15),
    .dac_top_state  (dac_top_state)
);

sw16        sw16(
    .clk            (clk),
    .rst_n          (rst_n),
    .system_state   (system_state),
    .key_state      (key_state),
    .pulse18_state  (pulse18_state),
    .pulse28_state  (pulse28_state),
    .in16           (in16),
    .dac_top_state  (dac_top_state)
);

reg         ain_state_0,ain_state_1;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        ain_state_0<=0;
        ain_state_1<=0;
    end
    else if(key_state)begin
        ain_state_0<=ain_state[0];
        ain_state_1<=ain_state_0;
    end
    else begin
        ain_state_0<=0;
        ain_state_1<=0;
    end
end

//通道权重
reg[11:0]   ain17_weight,ain18_weight,ain27_weight,ain28_weight;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) ain17_weight<=0;
    else if(key_state)begin
        if(ain_state==1&&(ain_state_0^ain_state_1)) ain17_weight<=ain_ave;
        else ain17_weight<=ain17_weight;
    end
    else ain17_weight<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) ain18_weight<=0;
    else if(key_state)begin
        if(ain_state==2&&(ain_state_0^ain_state_1)) ain18_weight<=ain_ave;
        else ain18_weight<=ain18_weight;
    end
    else ain18_weight<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) ain27_weight<=0;
    else if(key_state)begin
        if(ain_state==3&&(ain_state_0^ain_state_1)) ain27_weight<=ain_ave;
        else ain27_weight<=ain27_weight;
    end
    else ain27_weight<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) ain28_weight<=0;
    else if(key_state)begin
        if(ain_state==4&&(ain_state_0^ain_state_1)) ain28_weight<=ain_ave;
        else ain28_weight<=ain28_weight;
    end
    else ain28_weight<=0;
end

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) en_uart_tx<=0;
    else if(key_state&&system_state==COMPARE) en_uart_tx<=1;
    else en_uart_tx<=0;
end

reg[4:0]    cnt_tx_done ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)  cnt_tx_done<=0;
    else if(key_state&&system_state==COMPARE)begin
        if(cnt_tx_done==8) cnt_tx_done<=cnt_tx_done;
        else if(tx_done)    cnt_tx_done<=cnt_tx_done+1;
        else                cnt_tx_done<=cnt_tx_done;
    end
    else cnt_tx_done<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) data2uart<=0;
    else if(key_state&&system_state==COMPARE)begin
         if(en_uart_tx)begin
            case(cnt_tx_done)
                0:begin
                    data2uart[3:0]<=ain17_weight[11:8];
                    data2uart[7:4]<=4'b0000;
                end
                1:data2uart<=ain17_weight[7:0];
                2:begin
                    data2uart[3:0]<=ain18_weight[11:8];
                    data2uart[7:4]<=4'b0000;
                end
                3:data2uart<=ain18_weight[7:0];
                4:begin
                    data2uart[3:0]<=ain27_weight[11:8];
                    data2uart[7:4]<=4'b0000;
                end
                5:data2uart<=ain27_weight[7:0];
                6:begin
                    data2uart[3:0]<=ain28_weight[11:8];
                    data2uart[7:4]<=4'b0000;
                end
                7:data2uart<=ain28_weight[7:0];
                8:data2uart<=8'b0000_0000;
                default:data2uart<=ain17_weight[7:0];
            endcase
        end
        else data2uart<=data2uart;
    end
    else data2uart<=0;
end

reg[6:0]        cnt_2us         ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_2us<=0;
    else if(key_state&&system_state==COMPARE)begin
        if(cnt_2us==100) cnt_2us<=cnt_2us;
        else cnt_2us<=cnt_2us+1;
    end
    else cnt_2us<=0;
end

assign all_complete=(pulse17_state==3)&&(pulse18_state==3)&&(pulse27_state==3)&&(pulse28_state==3);

reg[2:0]    system_state_n      ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) system_state<=IDLE;
    else if(key_state) system_state<=system_state_n;
    else system_state<=IDLE;
end

always @(*)begin
    case(system_state)
        IDLE:begin
            if(key_state) system_state_n=READ;
            else system_state_n<=system_state;
        end
        READ:begin
            if(key_state&&ain_state==5) system_state_n=COMPARE;
            else system_state_n<=system_state;
        end
        COMPARE:begin
            if(key_state&&cnt_tx_done==8)begin
                if(all_complete) system_state_n=COMPARE;
                else system_state_n=WRITE;
            end
            else system_state_n=system_state;
        end
        WRITE:begin
            if(key_state&&pulse_complete) system_state_n=READ;
            else system_state_n=system_state;
        end
        COMPLETE:system_state_n=system_state;
        default:system_state_n=IDLE;
    endcase
end

parameter   WEIGHT_MIN=12'd768, WEIGHT_MAX=12'd1024;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) pulse17_state<=0;
    else if(key_state&&system_state==3'd3)begin
        if(ain17_weight<=WEIGHT_MIN) pulse17_state<=1;//电压值小，电阻大，给正向脉冲
        else if(ain17_weight>=WEIGHT_MAX) pulse17_state<=2;//电压值大，电阻小，给负向脉冲
        else if(ain17_weight>WEIGHT_MIN&&ain17_weight<WEIGHT_MAX) pulse17_state<=3;
        else pulse17_state<=pulse17_state;
    end
    else pulse17_state<=pulse17_state;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) pulse18_state<=0;
    else if(key_state&&system_state==3'd3)begin
        if(ain18_weight<=WEIGHT_MIN) pulse18_state<=1;//电压值小，电阻大，给正向脉冲
        else if(ain18_weight>=WEIGHT_MAX) pulse18_state<=2;//电压值大，电阻小，给负向脉冲
        else if(ain18_weight>WEIGHT_MIN&&ain18_weight<WEIGHT_MAX) pulse18_state<=3;
        else pulse18_state<=pulse18_state;
    end
    else pulse18_state<=pulse18_state;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) pulse27_state<=0;
    else if(key_state&&system_state==3'd3)begin
        if(ain27_weight<=WEIGHT_MIN) pulse27_state<=1;//电压值小，电阻大，给正向脉冲
        else if(ain27_weight>=WEIGHT_MAX) pulse27_state<=2;//电压值大，电阻小，给负向脉冲
        else if(ain27_weight>WEIGHT_MIN&&ain27_weight<WEIGHT_MAX) pulse27_state<=3;
        else pulse27_state<=pulse27_state;
    end
    else pulse27_state<=pulse27_state;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) pulse28_state<=0;
    else if(key_state&&system_state==3'd3)begin
        if(ain28_weight<=WEIGHT_MIN) pulse28_state<=1;//电压值小，电阻大，给正向脉冲
        else if(ain28_weight>=WEIGHT_MAX) pulse28_state<=2;//电压值大，电阻小，给负向脉冲
        else if(ain28_weight>WEIGHT_MIN&&ain28_weight<WEIGHT_MAX) pulse28_state<=3;
        else pulse28_state<=pulse28_state;
    end
    else pulse28_state<=pulse28_state;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) led<=1;
    else if(key_state)begin
        if(system_state==3'd4) led<=0;
        else led<=1;
    end
    else led<=1;
end

endmodule 
