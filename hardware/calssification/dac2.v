module  dac2(
    input           clk             ,
    input           rst_n           ,
    input           key_state       ,
    input[15:0]     data_sdi        ,
    input           en_dac          ,//en_dac是脉宽为一个系统时钟周期的高电平信号
    input           cs              ,
    input           sck             ,
    input[4:0]      cnt_sck         ,
    output  reg     sdi             ,
    output  reg     ldac            
);

reg[15:0]           data_reg        ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) data_reg<=0;
    else if(key_state) data_reg<=data_sdi;
    else data_reg<=0;
end

//ldac信号
reg[1:0]        cnt_40ns            ;//tls建立时间
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_40ns<=0;
    else if(key_state)begin
        if(en_dac) cnt_40ns<=0;
        else if(cs&&ldac)begin
            if(cnt_40ns==2'd3) cnt_40ns<=cnt_40ns;
            else cnt_40ns<=cnt_40ns+1;
        end
        else cnt_40ns<=cnt_40ns;
    end
    else cnt_40ns<=0;
end
 
reg[2:0]        cnt_100ns           ;//tlD保持时间
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_100ns<=0;
    else if(key_state)begin 
        if(en_dac) cnt_100ns<=0;
        else if(!ldac)begin
            if(cnt_100ns==3'd6) cnt_100ns<=cnt_100ns;
            else cnt_100ns<=cnt_100ns+1;
        end
        else cnt_100ns<=cnt_100ns;
    end
    else cnt_100ns<=0;
end

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) ldac<=1;
    else if(key_state)begin
        if(cnt_40ns==2'd2) ldac<=0;
        else if(cnt_100ns==3'd5) ldac<=1;
        else ldac<=ldac;
    end
    else ldac<=1;
end

//sdi输出
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) sdi<=0;
    else if(key_state)begin
        if(!cs&&ldac)begin
            case(cnt_sck)
                0:sdi<=data_reg[15];
                1:sdi<=data_reg[14];
                2:sdi<=data_reg[13];
                3:sdi<=data_reg[12];
                4:sdi<=data_reg[11];
                5:sdi<=data_reg[10];
                6:sdi<=data_reg[9];
                7:sdi<=data_reg[8];
                8:sdi<=data_reg[7];
                9:sdi<=data_reg[6];
                10:sdi<=data_reg[5];
                11:sdi<=data_reg[4];
                12:sdi<=data_reg[3];
                13:sdi<=data_reg[2];
                14:sdi<=data_reg[1];
                15:sdi<=data_reg[0];
                16:sdi<=0;
                default:sdi<=0;
            endcase
        end
        else sdi<=0;
    end
    else sdi<=0;
end
endmodule 
