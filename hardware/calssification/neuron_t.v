module neuron_t(
    input           clk             ,
    input           rst_n           ,
    input           en_t            ,
    input           spike1          ,
    input           spike2          ,
    output  reg[2:0]potential1_t    ,
    output  reg[2:0]potential2_t
);

reg         neuron1                 ;
always @(*)begin
    if(!rst_n) neuron1 = 0          ;
    else if(spike1&&en_t) neuron1=1 ;
    else neuron1 = 0                ;
end

reg         neuron2                 ;
always @(*)begin
    if(!rst_n) neuron2 = 0          ;
    else if(spike2&&en_t) neuron2=1 ;
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
    if(!rst_n) potential1_t<=0;
    else if(neuron1_1&&!neuron1_2) potential1_t<=potential1_t+1;
    else potential1_t<=potential1_t;
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n) potential2_t<=0;
    else if(neuron2_1&&!neuron2_2) potentia2_t<=potential2_t+1;
    else potential2_t<=potential2_t;
end

endmodule
