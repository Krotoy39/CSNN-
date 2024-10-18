module sw15(
    input           clk             ,
    input           rst_n           ,
    input[2:0]      system_state    ,
    input[1:0]      pulse17_state   ,
    input[1:0]      pulse27_state   ,
    input           key_state       ,
    input[3:0]      dac_top_state   ,
    output  reg     in15
);
localparam  IDLE=4'd0,V1_2=4'd1,CNT_1_2=4'd2,V2_2=4'd3,CNT_2_2=4'd4,V_READ=4'd5,V0=4'd7,COMPLETE=4'd6,V1_1=4'd7,V2_1=4'd8,CNT_1_1=4'd9,CNT_2_1=4'd10;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) in15<=0;
    else if(key_state)begin
        if(system_state==3'd1) in15<=1;
        else if(system_state==3'd2)begin
            case(dac_top_state)
                IDLE:in15<=0;
                V1_1:begin
                    if(pulse17_state==1||pulse17_state==2) in15<=1;
                    else if(pulse17_state==3) in15<=0;
                end
                CNT_1_1:in15<=in15;
                V2_1:in15<=in15;
                CNT_2_1:in15<=in15;
                V1_2:begin
                    if(pulse27_state==1||pulse27_state==2) in15<=1;
                    else if(pulse27_state==3) in15<=0;
                end
                CNT_1_2:in15<=in15;
                V2_2:in15<=in15;
                CNT_2_2:in15<=in15;
                default:in15<=0;
            endcase
        end
        else if(system_state==3'd3) in15<=0;
        else if(system_state==3'd4) in15<=0;
    end        
    else in15<=0;
end

endmodule 
