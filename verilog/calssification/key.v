module key(
    input       clk         ,
    input       rst_n       ,
    input       key_in      ,
    output  reg key_state        
);

reg             key_in1,key_in2   ;
wire            nedge,pedge ;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin 
        key_in1<=1;
        key_in2<=1;
    end
    else begin 
        key_in1<=key_in;
        key_in2<=key_in1;
    end
end

assign          nedge = !key_in1&&key_in2;
assign          pedge = key_in1&&!key_in2;
reg[19:0]       cnt         ;
reg             en_cnt      ;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) cnt<=0;
    else if(en_cnt) cnt<=cnt+1;
    else cnt<=0;
end

reg             cnt_full    ;
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) cnt_full<=0;
    else if(cnt==999_999) cnt_full<=1;
    else cnt_full<=0;
end

localparam IDLE=0,FILTER0=1,DOWN=2,FILTER1=3;

reg[1:0]    state_c,state_n;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) state_c<=IDLE;
    else state_c<=state_n;
end

always @(*)begin
    case(state_c)
        IDLE:begin
            if(nedge) state_n = FILTER0;
            else state_n = state_c;
        end
        FILTER0:begin
            if(cnt_full) state_n = DOWN;
            else if(pedge) state_n = FILTER0;
            else state_n = state_c;
        end
        DOWN:begin
            if(pedge) state_n = FILTER1;
            else state_n = state_c;
        end
        FILTER1:begin
            if(cnt_full) state_n = IDLE;
            else if(nedge) state_n = DOWN;
            else state_n = state_c;
        end
        default:begin
            state_n = state_c;
        end
    endcase
end

always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) en_cnt<=0;
    else if(state_c==FILTER0||state_c==FILTER1)en_cnt<=1;
    else en_cnt<=0;
end 

reg    state_c1,state_c2;//检测state_c从FILTER0跳DOWN的过程，故只需要对state_c[1]进行边沿检测
always @(posedge clk or negedge rst_n)begin 
    if(!rst_n)begin
        state_c1<=0;
        state_c2<=0;
    end
    else begin
        state_c1<=state_c[1];
        state_c2<=state_c1;
    end
end


always @(posedge clk or negedge rst_n)begin 
    if(!rst_n) key_state<=0;
    else if(state_c1&&!state_c2) key_state<=key_state+1;
    else key_state<=key_state;
end
endmodule 
