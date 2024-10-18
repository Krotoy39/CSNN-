`timescale 1 ns/ 1 ns 



module tb_system_top        ;
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
wire            sdi15           ;
wire            sdi16           ;
wire            ldac1           ;
wire            ldac2           ;
wire            ldac15          ;
wire            ldac16          ;
wire            dac_cs          ;
wire            sck             ;

reg             key_in          ;

wire            in1             ;
wire            in2             ;
wire            in15            ;
wire            in16            ;
wire            tx              ;
wire            led             ;

system_top_22                  uut(
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
    .sdi15              (sdi15),
    .sdi16              (sdi16),
    .ldac1              (ldac1),
    .ldac2              (ldac2),
    .ldac15             (ldac15),
    .ldac16             (ldac16),
    .dac_cs             (dac_cs),
    .sck                (sck),
    .key_in             (key_in),
    .in1                (in1),
    .in2                (in2),
    .in15               (in15),
    .in16               (in16),
    .tx                 (tx),
    .led                (led)
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
    forever #280 dout=~dout;
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
    #100_000_000;
    #0;
    begin
        repeat(5000) begin 
            #6000 eoc=0;
            #2500 eoc=1;
        end
    end
    #100_000_000;
    $stop;
end
endmodule 

