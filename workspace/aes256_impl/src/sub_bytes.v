`timescale 1ns / 1ps

// ---------- SUB BYTES ----------

module sub_bytes   (
                    clk,
                    reset_n,
                    rnd_cnt,
                    step,
                    k3, k7_rot,
                    mix_out,
                    sub_out              // output
                    );


// ---------- MODULE INTERFACE ----------

input               clk;                // global clock
input               reset_n;            // global negative active reset
input       [3:0]   rnd_cnt;            // round counter [0 to 14]
input       [2:0]   step;               // step counter [0 to 4]
input       [31:0]  k3, k7_rot;         // word 3 and word 7 rotated used for key expansion
input       [31:0]  mix_out;            // processed column after mix operation
output wire [31:0]  sub_out;            // processed column after sub bytes operation

// ---------- MODULE REGISTERS AND SIGNALS ----------

reg     [31:0]      sub_in;             // column as input for S-Box


// ---------- MODULE IMPLEMENTATION ----------

always @ (posedge clk or negedge reset_n)
  begin: SUB_BYTES
  
    if (!reset_n) sub_in <= 32'b0;      // reset sub_in register
    
    else if (step == 0)                 // Key expansion in every step 0
                                        // K2,K4...K14 : K3,K5...K13
      sub_in <= (rnd_cnt[0] == 1) ? {k7_rot} : k3[31:0]; // rounds 1 to 13
      //Rotate to use as input for S-Box when j mod Nk = 0, j = 8,16...56

    else                                // Sub_0, Sub_1, Sub_2, Sub_3
      sub_in <= mix_out;                // steps 1,2,3 and 4
      
  end


// ---------- S-BOX UNITS ----------

sbox            sbox0_u        ( 
                                sub_in[31:24],
                                sub_out[31:24]
                                );
                                
sbox            sbox1_u        (
                                sub_in[23:16],
                                sub_out[23:16]
                                );
                                
sbox            sbox2_u        (
                                sub_in[15:8],
                                sub_out[15:8]
                                );
                                
sbox            sbox3_u        (
                                sub_in[7:0],
                                sub_out[7:0]
                                );

endmodule