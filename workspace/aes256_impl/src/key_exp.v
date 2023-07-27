`timescale 1ns / 1ps

// ---------- KEY EXPANSION ----------

module key_exp     (
                    clk,
                    reset_n,
                    rnd_cnt,
                    step,
                    key_in,
                    sub_out,
                    k3,k7_rot,
                    rnd_key
                    );


// ---------- MODULE INTERFACE ----------

input               clk;                // global clock
input               reset_n;            // global negative edge reset
input       [3:0]   rnd_cnt;            // round counter [0 to 14]
input       [2:0]   step;               // step counter [0 to 4]
input       [255:0] key_in;             // 256-bit key
input       [31:0]  sub_out;            // processed column after substitution bytes operation
output reg  [31:0]  k3,k7_rot;         // word 3 and word 7 rotated used for key expansion
output wire [31:0]  rnd_key;            // round key for add round key operation


// ---------- MODULE REGISTERS AND SIGNALS ----------

reg     [31:0]      k0_next, k1_next, k2_next, k3_next; // words used for first part of key expansion
reg     [31:0]      k4_next, k5_next, k6_next, k7_next; // words used for second part of key expansion
reg     [31:0]      k0, k1, k2;         // words used for first part of key expansion
reg     [31:0]      k4, k5, k6;         // words used for second part of key expansion
wire    [31:0]      RC;                 // round constant for key expansion


// ---------- MODULE IMPLEMENTATION ----------

always @ (posedge clk or negedge reset_n)
  begin: KEY_EXPANSION
  
    if (!reset_n)                       // reset words registers
      begin
        k0 <= 31'b0;
        k1 <= 31'b0;
        k2 <= 31'b0;
        k3 <= 31'b0;
        k4 <= 31'b0;
        k5 <= 31'b0;
        k6 <= 31'b0;
        k7_rot <= 31'b0;
        k0_next <= 31'b0;
        k1_next <= 31'b0;
        k2_next <= 31'b0;
        k3_next <= 31'b0;
        k4_next <= 31'b0;
        k5_next <= 31'b0;
        k6_next <= 31'b0;
        k7_next <= 31'b0;
      end
      
    else
        case (step)
                                        // round 0
          0:  if (rnd_cnt == 0)
                begin                   // last column of key_in is k7
                  {k0,k1,k2,k3,k4,k5,k6,{k7_rot[7:0],k7_rot[31:8]}} <= key_in;
                end
                

          1:  begin                     // First Part                           
                                        // when j mod Nk = 0, (j = 8,16...56)
                k0_next = k0 ^ sub_out ^ RC;  
                k1_next = k0_next ^ k1;
                k2_next = k1_next ^ k2;
                k3_next = k2_next ^ k3;                                       
                                        // Second Part
                k4_next = sub_out ^ k4; // when j mod Nk = 4, (j = 12,20...52)
                k5_next = k4_next ^ k5;
                k6_next = k5_next ^ k6;
                k7_next = k6_next ^ {k7_rot[7:0],k7_rot[31:8]}; // k7 NOT rotated
              end

          4:  begin                     // 2,4...12 for Mix_0 in 2,4...14
                if (rnd_cnt[0] == 0 && rnd_cnt > 1)
                  begin
                    k0 <= k0_next;      // update key columns for first part
                    k1 <= k1_next;
                    k2 <= k2_next;
                    k3 <= k3_next;
                  end                   // 3,5...13 for Mix_0 in 3,5...13
                if (rnd_cnt[0] == 1 && rnd_cnt > 2)
                  begin
                    k4 <= k4_next;      // update key columns for second part
                    k5 <= k5_next;
                    k6 <= k6_next;
                    k7_rot <= {k7_next[23:0],k7_next[31:24]};
                  end
              end

        endcase
      
  end


round_constant  round_constant_u   (
                                    clk,
                                    reset_n,
                                    rnd_cnt,
                                    step,
                                    RC          // output
                                    );

round_key       round_key_u        (
                                    clk,
                                    reset_n,
                                    rnd_cnt,
                                    step,
                                    key_in[255:224],
                                    k0,k1,k2,k3,
                                    k4,k5,k6,{k7_rot[7:0],k7_rot[31:8]},
                                    rnd_key     // output
                                    );
                                    
endmodule