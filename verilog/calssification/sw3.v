module sw3(
    input           clk             ,
    input           rst_n           ,
    input           key_state       ,
    output  reg     in3
);

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) in3<=0;
    else if(key_state) in3<=1;
    else in3<=0;
end

endmodule 
