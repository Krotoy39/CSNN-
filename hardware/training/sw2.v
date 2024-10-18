module sw2(
    input           clk             ,
    input           rst_n           ,
    input[2:0]      system_state    ,
    input[3:0]      dac_top_state   ,
    input           key_state       ,
    output  reg     in2
);
localparam  IDLE=4'd0,V1_2=4'd1,CNT_1_2=4'd2,V2_2=4'd3,CNT_2_2=4'd4,V_READ=4'd5,V0=4'd7,COMPLETE=4'd6,V1_1=4'd7,V2_1=4'd8,CNT_1_1=4'd9,CNT_2_1=4'd10;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) in2<=0;
    else if(key_state)begin
        if(system_state==3'd1) in2<=1;
        else if(system_state==3'd2)begin
            if(dac_top_state==V1_2||dac_top_state==CNT_1_2||dac_top_state==V2_2||dac_top_state==CNT_2_2) in2<=1;
            else in2<=0;
        end
        else if(system_state==3'd3) in2<=0;
        else if(system_state==3'd4) in2<=0;
        else in2<=in2;
    end
    else in2<=0;
end

endmodule
