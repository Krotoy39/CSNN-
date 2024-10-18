module coding(
    input               clk                     ,
    input               rst_n                   ,
    input               key_state               ,
    output  reg[63:0]   code             
);

parameter
    RAW1 = 5'b11011 ,
    RAW2 = 5'b00100 ,
    RAW3 = 5'b00100 ,
    RAW4 = 5'b00100 ,  
    RAW5 = 5'b00100 ;

reg[4:0]    raw[4:0]    ;
always@ (posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        raw[0]<=5'd0    ;
        raw[1]<=5'd0    ;   
        raw[2]<=5'd0    ;
        raw[3]<=5'd0    ;   
        raw[4]<=5'd0    ;
    end
    else begin
        raw[0]<=RAW1    ;
        raw[1]<=RAW2    ;
        raw[2]<=RAW3    ;
        raw[3]<=RAW4    ;
        raw[4]<=RAW5    ;
    end
end

integer     i,j         ;
reg[3:0]    field[15:0] ;
always @(*)begin
    if(!rst_n)begin
        for(i=0;i<4;i=i+1)begin
            for(j=0;j<4;j=j+1) field[4*i+j] = 4'b0000;
        end
    end
    else if(key_state) begin
        for(i=0;i<4;i=i+1)begin
            for(j=0;j<4;j=j+1) field[4*i+j] = {raw[i][4-j],raw[i][3-j],raw[i+1][4-j],raw[i+1][3-j]};
        end
    end
    else begin
        for(i=0;i<4;i=i+1)begin
            for(j=0;j<4;j=j+1) field[4*i+j] = field[4*i+j];
        end
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) code<=64'd0      ;
    else if(key_state) begin
        code<={field[0],field[1],field[2],field[3],field[4],field[5],field[6],field[7],field[8],field[9],field[10],field[11],field[12],field[13],field[14],field[15]};
    end
end

endmodule
