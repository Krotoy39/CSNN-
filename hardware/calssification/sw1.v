module sw1(
    input           clk             ,
    input           rst_n           ,
    input           key_state       ,
    output  reg     in1
);

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) in1<=0;
    else if(key_state) in1<=1;
    else in1<=0;
end

endmodule
