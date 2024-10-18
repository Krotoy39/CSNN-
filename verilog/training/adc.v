module adc(clk,rst_n,key_state,en_adc,din,dout,cs,eoc,ioclk,din_address,adc_out,adc_state);

input               clk         ;
input               rst_n       ;
input               key_state   ;
input               en_adc      ;
input               dout        ;
input               eoc         ;
input[7:0]          din_address ;
output          reg din         ;
output          reg cs          ;
output          reg ioclk       ;
output    reg[11:0] adc_out     ;
output    reg       adc_state   ;

//ioclk
reg[3:0]        cnt_clk   ;//adcÊ±ÖÓÉú³É
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)  cnt_clk<=0;
    else if(key_state&&en_adc)begin
        if(cnt_clk==14) cnt_clk<=0;
        else cnt_clk <= cnt_clk + 1;
    end
    else cnt_clk <= 0;
end

reg[6:0]        cnt_2us     ;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) cnt_2us<=0;
    else if(key_state&&en_adc&&!cs&&eoc)begin 
        if(cnt_2us==100) cnt_2us<=cnt_2us;
        else cnt_2us<=cnt_2us+1;
    end
    else cnt_2us<=0;
end

reg[3:0]        cnt_ioclk       ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) ioclk<=0;
    else if(key_state&&en_adc)begin
        if(cnt_ioclk==12) ioclk<=0;
        else if(!cs&&eoc&&cnt_2us==100)begin
            if(cnt_clk==0) ioclk<=1;
            else if(cnt_clk==8-1) ioclk<=0;
        end
    end
    else ioclk<=0;
end

reg             ioclk1,ioclk2   ;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) begin 
        ioclk1<=0;
        ioclk2<=0;
    end
    else  if(key_state&&en_adc)begin 
        ioclk1<=ioclk;
        ioclk2<=ioclk1;
    end
    else begin 
        ioclk1<=0;
        ioclk2<=0;
    end 
end

//eoc ±ßÔµ¼ì²â 
reg     eoc1,eoc2,eoc3;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) begin 
        eoc1<=0;
        eoc2<=0;
        eoc3<=0;
    end
    else if(key_state&&en_adc)begin 
        eoc1<=eoc;
        eoc2<=eoc1;
        eoc3<=eoc2;
    end
    else begin 
        eoc1<=0;
        eoc2<=0;
        eoc3<=0;
    end 
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) cnt_ioclk<=0;
    else if(key_state&&en_adc)begin
        if(!cs&&cnt_2us==100)begin
            if(cnt_ioclk==12) cnt_ioclk<=cnt_ioclk;
            else if(!ioclk1&&ioclk2) cnt_ioclk<=cnt_ioclk+1;
            else cnt_ioclk<=cnt_ioclk;
        end
        else if(eoc2&&!eoc3) cnt_ioclk<=0;
        else cnt_ioclk<=cnt_ioclk;
    end
    else cnt_ioclk<=0;
end 

//cs
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) cs<=1;
    else if(key_state&&en_adc)begin 
        if(eoc2&&!eoc3) cs<=0;
        else if(cnt_ioclk==12&&!eoc2&&eoc3) cs<=1;
        else cs<=cs;
    end
    else cs<=0;
end

reg             cs1,cs2         ;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin 
        cs1<=1;
        cs2<=1;
    end
    else if(key_state&&en_adc)begin 
        cs1<=cs;
        cs2<=cs1;
    end 
    else begin 
        cs1<=1;
        cs2<=1;
    end 
end

//din
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) din<=0;
    else if(key_state&&en_adc)begin 
        if(!cs&&eoc)begin 
            if(cnt_ioclk==0) din<=din_address[7];
            else if(cnt_ioclk==1) din<=din_address[6];
            else if(cnt_ioclk==2) din<=din_address[5];
            else if(cnt_ioclk==3) din<=din_address[4];
            else if(cnt_ioclk==4) din<=din_address[3];
            else if(cnt_ioclk==5) din<=din_address[2];
            else if(cnt_ioclk==6) din<=din_address[1];
            else if(cnt_ioclk==7) din<=din_address[0];
            else din<=din;
        end
        else din<=0;
    end
    else din<=0;
end
//adc_out
reg[11:0]           dout_reg        ;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) dout_reg<=0;
    else if(key_state&&en_adc)begin
        if(ioclk1&&!ioclk2)begin 
            case(cnt_ioclk)
                0:dout_reg[11]<=dout;
                1:dout_reg[10]<=dout;
                2:dout_reg[9]<=dout;
                3:dout_reg[8]<=dout;
                4:dout_reg[7]<=dout;
                5:dout_reg[6]<=dout;
                6:dout_reg[5]<=dout;
                7:dout_reg[4]<=dout;
                8:dout_reg[3]<=dout;
                9:dout_reg[2]<=dout;
                10:dout_reg[1]<=dout;
                11:dout_reg[0]<=dout;
                12:dout_reg<=dout_reg;
                default:dout_reg<=dout_reg;
            endcase
        end
        else if(eoc2&&!eoc3) dout_reg<=0;
        else dout_reg<=dout_reg;
    end
    else dout_reg<=0;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) adc_out<=0;
    else if(key_state&&en_adc)begin
        if(adc_state) adc_out<=dout_reg;
        else adc_out<=adc_out;
    end
    else adc_out<=0;
end
//adc_state
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) adc_state<=0;
    else if(key_state&&en_adc)begin 
        if(!eoc2&&eoc3) adc_state<=1;
        else if(eoc2&&!eoc3) adc_state<=0;
        else adc_state<=adc_state;
    end
    else adc_state<=0;
end
endmodule 
