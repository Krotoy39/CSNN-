module neuron_u(
    input           clk             ,
    input           rst_n           ,
    input           en_u            ,
    input           spike1          ,
    input           spike2          ,
    output  reg[2:0]potential1_u    ,
    output  reg[2:0]potential2_u
);

reg         neuron1                 ;
always @(*)begin
    if(!rst_n) neuron1 = 0          ;
    else if(spike1&&en_u) neuron1=1 ;
    else neuron1 = 0                ;
end

reg         neuron2                 ;
always @(*)begin
    if(!rst_n) neuron2 = 0          ;
    else if(spike2&&en) neuron2 = 1 ;
    else neuron2 = 0                ;
end

reg         neuron1_1,neruon1_2     ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        neuron1_1<=0;
        neuron1_2<=0;
    end
    else begin
        neuron1_1<=neuron1;
        neuron1_2<=neuron1_1;
    end
end

reg         neuron2_1,neuron2_2     ;
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        neuron2_1<=0;
        neuron2_2<=0;
    end
    else begin
        neuron2_1<=neuron2;
        neuron2_2<=neuron2_1;
    end
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) potential1_u<=0;
    else if(neuron1_1&&!neuron1_2) potential1_u<=potential1_u+1;
    else potential1_u<=potential1_u;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) potential2_u<=0;
    else if(neuron2_1&&!neuron2_2) potentia2_u<=potential2_u+1;
    else potential2_u<=potential2_u;
end

endmodule
