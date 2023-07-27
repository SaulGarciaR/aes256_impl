`timescale 1ns / 1ps

// ---------- ROUND KEY ----------

module round_key   (
                    clk,
                    reset_n,
                    rnd_cnt,
                    step,
                    key_in,
                    k0,k1,k2,k3,
                    k4,k5,k6,k7,
                    rnd_key             // output
                    );


// ---------- MODULE INTERFACE ----------

input               clk;                // global clock
input               reset_n;            // global negative edge reset
input       [3:0]   rnd_cnt;            // round counter [0 to 14]
input       [2:0]   step;               // step counter [0 to 4]
input       [31:0]  key_in;             // 256-bit key
input       [31:0]  k0, k1, k2, k3;     // words used for first part of key expansion
input       [31:0]  k4, k5, k6, k7;     // words used for second part of key expansion
output reg  [31:0]  rnd_key;            // round key for add round key operation


// ---------- MODULE IMPLEMENTATION ----------

always @ (posedge clk or negedge reset_n)
  begin: ROUND_KEY
  
    if (!reset_n) rnd_key <= 32'h0;     // reset round_key register
    
    else
        case (step) 
                                        // w0 for Mix_0 in round 0 (key_in[255:224])
          0:  rnd_key <= (rnd_cnt == 0) ? key_in:
                                        // for Mix_0 in 2,4...14 : 1,3...13
                         (rnd_cnt[0] == 0) ? k0 : k4;
                                        // for Mix_1 in 2,4...14 : 1,3...13
          1:  rnd_key <= (rnd_cnt[0] == 0) ? k1 : k5;
                                        // for Mix_2 in 2,4...14 : 1,3...13
          2:  rnd_key <= (rnd_cnt[0] == 0) ? k2 : k6;
                                        // for Mix_3 in 2,4...14 : 1,3...13
          3:  rnd_key <= (rnd_cnt[0] == 0) ? k3 : k7;
          
        endcase

  end


endmodule