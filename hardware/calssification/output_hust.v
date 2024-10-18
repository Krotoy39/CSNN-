module      hust(
    input           clk             ,
    input           rst_n           ,
    input[1:0]      system_state    ,
    input[2:0]      potential1_h    ,
    input[2:0]      potential2_h    ,
    input[2:0]      potential2_u    ,
    input[2:0]      potential2_u    ,
    input[2:0]      potential1_s    ,
    input[2:0]      potential2_s    ,
    input[2:0]      potential1_t    ,
    input[2:0]      potential2_t    ,
    output  reg[3:0]output_hust
);

localparam  IDLE=2'b00,SAMPLE=2'b01,UART=2'b11,COMPLETE=2'b10;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n) output_hust<=4'b1111;
    else if(system_state==COMPLETE)begin
        if(potential1_h[2]||potential1_u[2]||potential1_s[2]||potential1_t[2])begin
            if(potential1_h[2]) output_hust<=4'b0111;
            else if(potential1_u[2]) output_hust<=4'b1011;
            else if(potential1_s[2]) output_hust<=4'b1101;
            else if(potential1_t[2]) output_hust<=4'b1110;
            else output_hust<=4'b1111;
        end
        else 
