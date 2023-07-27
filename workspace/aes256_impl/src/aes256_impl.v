`timescale 1ns / 1ps

// ---------- AES256 UART ----------

module aes256_impl  (
                    clk,
                    reset_n,
                    led           // output
                    );


// ---------- MODULE INTERFACE ----------

input               clk;                // global clock
input               reset_n;              // global negative edge reset
output wire [1:0]   led;           // output data bits from TX


// ---------- MODULE REGISTERS AND SIGNALS ----------

  // 10 MHz clock
  // Want to interface to 115200 baud UART
  // 10000000 / 115200 = 87 Clocks Per Bit.

reg             aes_start;
reg  [255:0]    key = 0;
reg  [127:0]    text_in = 0;
wire  [127:0]   text_out;
wire            aes_ready;

// ---------- STATE MACHINE ----------


always @ (posedge clk or negedge reset_n)
  begin: AES

    if (!reset_n)
        aes_start <= 1;
    else
        aes_start <= 0;

  end


assign led[0] = aes_ready;
assign led[1] = text_out[0];



// ---------- MODULES INSTANTIATION ----------

aes256_enc  aes256_enc      (
                            .clk(clk),
                            .reset_n(reset_n),
                            .start(aes_start),
                            .key_in(key),
                            .data_in(text_in),
                            .data_out(text_out),    // output
                            .ready(aes_ready)       // output
                            );
        

endmodule
