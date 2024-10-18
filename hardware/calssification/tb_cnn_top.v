`timescale 1 ns/ 1 ns 



module tb_cnn_top               ;
//≤‚ ‘–≈∫≈
//≤‚ ‘–≈∫≈Ω· ¯
reg             clk             ;
reg             rst_n           ;
reg             eoc             ;
reg             dout            ;
wire            din             ;
wire            adc_cs          ;
wire            ioclk           ;
wire            sdi1            ;
wire            sdi2            ;
wire            sdi3            ;
wire            sdi4            ;
wire            ldac1           ;
wire            ldac2           ;
wire            ldac3           ;
wire            ldac4           ;
wire            dac_cs          ;
wire            sck             ;

reg             key_in          ;
wire            in1             ;
wire            in2             ;
wire            in3             ;
wire            in4             ;
wire            tx              ;
wire            spike           ;
wire            ref_spike       ;

cnn_edge                  uut(
    //≤‚ ‘–≈∫≈
    //≤‚ ‘–≈∫≈Ω· ¯
    .clk                (clk),
    .rst_n              (rst_n),
    .eoc                (eoc),
    .dout               (dout),
    .din                (din),
    .adc_cs             (adc_cs),
    .ioclk              (ioclk),
    .sdi1               (sdi1),
    .sdi2               (sdi2),
    .sdi3               (sdi3),
    .sdi4               (sdi4),
    .ldac1              (ldac1),
    .ldac2              (ldac2),
    .ldac3              (ldac3),
    .ldac4              (ldac4),
    .dac_cs             (dac_cs),
    .sck                (sck),
    .key_in             (key_in),
    .in1                (in1),
    .in2                (in2),
    .in3                (in3),
    .in4                (in4),
    .tx                 (tx),
    .spike              (spike),
    .ref_spike          (ref_spike)
);

parameter CYCLE=20  ;
initial begin 
    #1      ;
    clk=0   ;
    forever #(CYCLE/2)begin 
    clk=~clk    ;
    end
end

initial begin 
    #1000;
    dout=1;
    forever #197 dout=~dout;
end

initial begin 
    #1;
    rst_n=0;
    eoc=1;
    key_in=1;
    #1000;
    rst_n=1;
    #1000;
    key_in=0;
    #100_000;
    #0;
    begin
        repeat(5000) begin 
            #7600 eoc=0;
            #2600 eoc=1;
        end
    end
    #100_000_000;
    $stop;
end
endmodule 

