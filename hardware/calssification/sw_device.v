module sw_device(
    input           clk             ,
    input           rst_n           ,
    input           key_state       ,
    output   reg    device11        ,
    output   reg    device12        ,
    output   reg    device21        ,
    output   reg    device22        
);

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) device11<=0;
    else device11<=1;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) device12<=0;
    else device12<=1;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) device21<=0;
    else device21<=1;
end 

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) device22<=0;
    else device22<=1;
end

endmodule 
