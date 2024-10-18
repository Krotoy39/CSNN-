`include "F:/FPGA_program/cnn_edge/key.v"
`include "F:/FPGA_program/cnn_edge/adc_top.v"
`include "F:/FPGA_program/cnn_edge/dac_top.v"
`include "F:/FPGA_program/cnn_edge/sw1.v"
`include "F:/FPGA_program/cnn_edge/sw2.v"
`include "F:/FPGA_program/cnn_edge/sw3.v"
`include "F:/FPGA_program/cnn_edge/sw4.v"
`include "F:/FPGA_program/cnn_edge/uart_tx.v"
`include "F:/FPGA_program/cnn_edge/code.v"
`include "F:/FPGA_program/cnn_edge/neuron_h.v"
`include "F:/FPGA_program/cnn_edge/neuron_u.v"
`include "F:/FPGA_program/cnn_edge/neuron_s.v"
`include "F:/FPGA_program/cnn_edge/neuron_t.v"

module       cnn_edge(
    input           clk             ,
    input           rst_n           ,
//按钮输入
    input           key_in          ,
//adc信号    
    input           dout            ,
    input           eoc             ,
    output  wire    din             ,
    output  wire    adc_cs          ,
    output  wire    ioclk           ,
//dac信号
    output  wire    sdi1            ,
    output  wire    sdi2            ,
    output  wire    sdi3            ,
    output  wire    sdi4            ,
    output  wire    ldac1           ,
    output  wire    ldac2           ,
    output  wire    ldac3           ,
    output  wire    ldac4           ,
    output  wire    sck             ,
    output  wire    dac_cs          ,
//开关控制
    output  wire    in1             ,
    output  wire    in2             ,
    output  wire    in3             ,
    output  wire    in4             ,
//串口
    output  wire    tx              ,
//神经元输出
    output  reg     spike1          ,
    output  reg     spike2          ,
    output  reg     ref_spike       ,
//分类结果
    output  reg[3:0]output_hust
);

parameter   IDLE=2'b00,SAMPLE=2'b01,UART=2'b11,COMPLETE=2'b10;
reg[1:0]    state_c,state_n     ;
wire        key_state           ;

key             key(
    .clk                (clk),
    .rst_n              (rst_n),
    .key_in             (key_in),
    .key_state          (key_state)
);

sw1             sw1(
    .clk                (clk),
    .rst_n              (rst_n),
    .key_state          (key_state),
    .in1                (in1)
);

sw2             sw2(
    .clk                (clk),
    .rst_n              (rst_n),
    .key_state          (key_state),
    .in2                (in2)
);

sw3             sw3(
    .clk                (clk),
    .rst_n              (rst_n),
    .key_state          (key_state),
    .in3                (in3)
);

sw4             sw4(
    .clk                (clk),
    .rst_n              (rst_n),
    .key_state          (key_state),
    .in4                (in4)
);

wire            sample_end          ;
wire[15:0]      ain_ave             ;
adc_top         adc_top(
    .clk                (clk),
    .rst_n              (rst_n),
    .key_state          (key_state),
    .system_state       (state_c),
    .dout               (dout),
    .eoc                (eoc),
    .din                (din),
    .cs                 (adc_cs),
    .ioclk              (ioclk),
    .sample_end         (sample_end),
    .ain_ave            (ain_ave)
);

reg             uart_en             ;
reg[15:0]       data2uart           ;
wire            tx_done             ;
wire            uart_state          ;
reg             cnt_uart            ;//在串口状态中要发送两个数据，数到第二个数据时从串口状态跳到采样状态
uart_tx         uart_tx(
    .clk                (clk),
    .rst_n              (rst_n),
    .send_en            (uart_en),
    .data               (data2uart),
    .baud_set           (3'd4),
    .tx                 (tx),
    .tx_done            (tx_done),
    .uart_state         (uart_state)
);

reg[4:0]            cnt_RF          ;//感受野计数器
reg[3:0]            field2dac_top   ;//感受野
dac_top         dac_top(
    .clk            (clk),
    .rst_n          (rst_n),
    .key_state      (key_state),
    .system_state   (state_c),
    .cs             (dac_cs),
    .sck            (sck),
    .sdi1           (sdi1),
    .sdi2           (sdi2),
    .sdi3           (sdi3),
    .sdi4           (sdi4),
    .ldac1          (ldac1),
    .ldac2          (ldac2),
    .ldac3          (ldac3),
    .ldac4          (ldac4),
    .cnt_RF         (cnt_RF),
    .field          (field2dac_top),
    .data_sdi1      (),
    .data_sdi2      (),
    .data_sdi3      (),
    .data_sdi4      (),
    .cnt_sck        ()
);

wire[63:0]          code;
coding           coding(
    .clk            (clk),
    .rst_n          (rst_n),
    .key_state      (key_state),
    .code           (code)
);

reg     en_h,en_u,en_s,en_t ;
wire[2:0]
    potential1_h , potential2_h,
    potential1_u , potential2_u,
    potential1_s , potential2_s,
    potential1_t , potential2_t;

neuron_h            neuron_h(
    .clk            (clk),
    .rst_n          (rst_n),
    .en_h           (en_h),
    .spike1         (spike1),
    .spike2         (spike2),
    .potential1_h   (potential1_h),
    .potential2_h   (potential2_h)
);

neuron_u            neuron_u(
    .clk            (clk),
    .rst_n          (rst_n),
    .en_u           (en_u),
    .spike1         (spike1),
    .spike2         (spike2),
    .potential1_u   (potential1_u),
    .potential2_u   (potential2_u)
);

neuron_s            neuron_s(
    .clk            (clk),
    .rst_n          (rst_n),
    .en_s           (en_s),
    .spike1         (spike1),
    .spike2         (spike2),
    .potential1_s   (potential1_s),
    .potential2_s   (potential2_s)
);

neuron_t            neuron_t(
    .clk            (clk),
    .rst_n          (rst_n),
    .en_t           (en_t),
    .spike1         (spike1),
    .spike2         (spike2),
    .potential1_t   (potential1_t),
    .potential2_t   (potential2_t)
);

//输入的像素点
parameter
    WEIGHT1 = 8'h30             ,
    WEIGHT2 = 8'h31             ,
    WEIGHT3 = 8'h32             ,
    WEIGHT4 = 8'h31             ;

genvar          i               ;
reg[3:0]        field[15:0]     ;
generate
    for(i=0;i<16;i=i+1)begin:reception_field
        always @(posedge clk or negedge rst_n)begin
            if(!rst_n) field[i] = 0;
            else if(key_state) field[i]=code[4*i+3:4*i];
            else field[i]=0;
        end
    end
endgenerate

always @(*)begin
    if(!rst_n) field2dac_top=0;
    else if(key_state&&state_c==COMPLETE) field2dac_top<=0;
    else if(key_state&&state_c==SAMPLE&&!cnt_RF[4]) field2dac_top=field[15-cnt_RF];
    else field2dac_top=field2dac_top;
end

//感受野计数器
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_RF<=0;
    else if(key_state)begin
        if(cnt_RF==17) cnt_RF<=cnt_RF;
        else if(sample_end&&state_c==SAMPLE) cnt_RF<=cnt_RF+1;
    end
    else cnt_RF<=cnt_RF;
end
//卷积
reg[15:0]       conv        ;
always @(*)begin
    if(!rst_n) conv=16'd0;
    else if(key_state)begin
        if(state_c==SAMPLE) conv=field2dac_top[3]*WEIGHT1+field2dac_top[2]*WEIGHT2+field2dac_top[1]*WEIGHT3+field2dac_top[0]*WEIGHT4;
        else conv=conv;
    end
    else conv=16'd0;
end

//状态机
reg[5:0]    cnt_tx_done             ;//数串口发送的数据次数，发送偶数次给前半段数据，发送奇数次给后半段数据
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_tx_done<=0;
    else if(key_state)begin
        if(cnt_tx_done==32) cnt_tx_done<=cnt_tx_done;
        else if(tx_done) cnt_tx_done<=cnt_tx_done+1;
        else cnt_tx_done<=cnt_tx_done;
    end
    else cnt_tx_done<=cnt_tx_done;
end

always @(*)begin
    if(!rst_n) data2uart=8'd0;
    else if(key_state&&state_c==UART)begin
        if(cnt_tx_done==32) data2uart=8'b0;
        else if(!cnt_tx_done[0]) data2uart=conv[15:8];
        else if(cnt_tx_done[0]) data2uart=conv[7:0];
        else data2uart=data2uart;
    end
    else data2uart=data2uart;
end
        
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) state_c<=IDLE;
    else state_c<=state_n;
end

always @(*)begin
    case(state_c)
        IDLE:state_n = key_state?SAMPLE:state_c;
        SAMPLE:state_n = (sample_end)?UART:state_c;
        UART:begin
            if(cnt_tx_done==0) state_n = state_c;
            else if(cnt_RF==17) state_n = COMPLETE;
            else if(cnt_uart&&tx_done) state_n = SAMPLE;
            else state_n = state_c;
        end
        COMPLETE:state_n = state_c;
         default:state_n = IDLE;
    endcase
end

//串口输出
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_uart<=0;
    else if(key_state&&state_c==UART)begin
        if(cnt_uart) cnt_uart<=cnt_uart;
        else if(tx_done) cnt_uart<=cnt_uart+1;
    end
    else cnt_uart<=0;
end

reg         state_c11,state_c12 ;//状态机跳转的边沿检测，检测从SAMPLE跳到UART的时刻;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_c11<=0;
        state_c12<=0;
    end
    else begin
        state_c11<=state_c[1];
        state_c12<=state_c11;
    end
end

assign sample2uart = state_c11&&!state_c12;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) uart_en<=0;
    else if(key_state&&state_c==UART)begin
        if(sample2uart) uart_en<=1;
        else if(tx_done&&cnt_uart==0) uart_en<=1;
        else uart_en<=0;
    end
    else uart_en<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) spike1<=0;
    else if(state_c==UART)begin
        if(conv>16'h80) spike1<=1;
        else spike1<=0;
    end
    else spike1<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) spike2<=0;
    else if(state_c==UART)begin
        if(conv<20) spike2<=1;
        else spike2<=0;
    end
    else spike2<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) ref_spike<=0;
    else if(key_state)begin
        if(state_c==UART) ref_spike<=1;
        else ref_spike<=0;
    end
    else ref_spike<=0;
end

//字母h神经元
reg neuron_h1,neuron_h2,neuron_h3,neuron_h4;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_h1<=0;
    else if(key_state)begin
        if(cnt_RF==5&&spike1) neuron_h1<=1;
        else neuron_h1<=neuron_h1;
    end
    else neuron_h1<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_h2<=0;
    else if(key_state)begin
        if(cnt_RF==8&&spike1) neuron_h2<=1;
        else neuron_h2<=neuron_h2;
    end
    else neuron_h2<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_h3<=0;
    else if(key_state)begin
        if(cnt_RF==9&&spike1) neuron_h3<=1;
        else neuron_h3<=neuron_h3;
    end
    else neuron_h3<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_h4<=0;
    else if(key_state)begin
        if(cnt_RF==12&&spike1) neuron_h4<=1;
        else neuron_h4<=neuron_h4;
    end
    else neuron_h4<=0;
end

//字母u神经元
reg     neuron_u1,neuron_h2 ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_u1<=0;
    else if(key_state)begin
        if(cnt_RF==13&&spike1) neuron_u1<=1;
        else neuron_u1<=neuron_u1;
    end
    else neuron_u1<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_u2<=0;
    else if(key_state)begin
        if(cnt_RF==16&&spike1) neuron_u2<=1;
        else neuron_u2<=neuron_u2;
    end
    else neuron_u2<=0;
end

//字母s神经元
reg     neuron_s1,neuron_s2,neuron_s3,neuron_s4;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_s1<=0;
    else if(key_state)begin
        if(cnt_RF==1&&spike1) neuron_s1<=1;
        else neuron_s1<=neuron_s1;
    end
    else neuron_s1<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_s2<=0;
    else if(key_state)begin
        if(cnt_RF==5&&spike1) neuron_s2<=1;
        else neuron_s2<=neuron_s2;
    end
    else neuron_s2<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_s3<=0;
    else if(key_state)begin
        if(cnt_RF==12&&spike1) neuron_s3<=1;
        else neuron_s3<=neuron_s3;
    end
    else neuron_s3<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_s4<=0;
    else if(key_state)begin
        if(cnt_RF=16&&spike1) neuron_s4<=1;
        else neuron_s4<=neuron_s4;
    end
    else neuron_s4<=0;
end

//字母t神经元
reg     neuron_t1,neuron_t2;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_t1<=0;
    else if(key_state)begin
        if(cnt_RF==2&&spike1) neuron_t1<=1;
        else neuron_t1<=neuron_t1;
    end
    else neuron_t1<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) neuron_t2<=0;
    else if(key_state)begin
        if(cnt_RF==3&&spike1) neuron_t2<=1;
        else neuron_t2<=neuron_t2;
    end
    else neuron_t2<=0;
end

//spike2计数器
reg[3:0]            cnt_spike2          ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_spike2<=0;
    else if(key_state)begin
        if(tx_done)begin
            if(spike2) cnt_spike2<=cnt_spike2+1;
            else cnt_spike2<=cnt_spike2;
        end
        else cnt_spike2<=cnt_spike2;
    end
    else cnt_spike2<=0;
end

endmodule
