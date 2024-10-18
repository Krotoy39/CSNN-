module sw2(
    input           clk             ,
    input           rst_n           ,
    input           key_state       ,
    output  reg     in2
);

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) in2<=0;
    else if(key_state) in2<=1;
    else in2<=0;
end

endmodule
