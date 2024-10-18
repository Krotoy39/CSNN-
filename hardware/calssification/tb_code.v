`timescale      1 ns/ 1 ns      

module  tb_code     ;

reg         clk             ;
reg         rst_n           ;
reg         key_state       ;
wire[63:0]  code            ;

code            uut(
    .clk            (clk),
    .rst_n          (rst_n),
    .key_state      (key_state),
    .code           (code)
);

initial begin
    #1;
    clk=0;
    forever #10 clk=~clk;
end

initial begin
    #1;
    rst_n=0;
    key_state=0;
    #1000;
    rst_n=1;
    #1000;
    key_state=1;
end

endmodule
