module sw4(
    input           clk             ,
    input           rst_n           ,
    input           key_state       ,
    output  reg     in4
);

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) in4<=0;
    else if(key_state) in4<=1;
    else in4<=0;
end

endmodule 
