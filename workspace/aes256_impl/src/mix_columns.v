`timescale 1ns / 1ps

// ---------- MIX COLUMNS ----------

module mix_columns (
                    clk,
                    reset_n,
                    rnd_cnt,
                    step,
                    data_in,
                    block_1,
                    block_2,
                    sub_out,
                    rnd_key,
                    mix_out             // output
                    );


// ---------- MODULE INTERFACE ----------

input               clk;                // global clock
input               reset_n;            // global negative edge reset
input       [3:0]   rnd_cnt;            // round counter [0 to 14]
input       [2:0]   step;               // step counter [0 to 4]
input       [127:0] data_in;            // 128-bit plaintext
input       [127:0] block_1, block_2;   // storage blocks for shift rows operation
input       [31:0]  sub_out;            // processed column after sub bytes operation
input       [31:0]  rnd_key;            // round key for add round key operation
output wire [31:0]  mix_out;            // processed column after mix operation


// ---------- MODULE REGISTERS AND SIGNALS ----------

reg     [3:0]       rnd_cnt_mix;        // round counter used as input for mix column unit
reg     [31:0]      mix_in;             // column as input for mix operation


// ---------- MODULE IMPLEMENTATION ----------

always @ (posedge clk or negedge reset_n)
  begin: MIX_COLUMNS
  
    if (!reset_n)
      begin
        mix_in <= 32'b0;      // reset of mix_in register
        rnd_cnt_mix <= 4'b0;
      end
    
    else
      begin
        rnd_cnt_mix <= rnd_cnt;         // syncrhonize to use correct round counter along with mix_in
        case (step)
          0:  begin                     // Mix_0
                mix_in <= (rnd_cnt == 0) ? data_in[127:96]:                         // round 0
                          (rnd_cnt[0] != 1'b0) ? {block_1[127:104],sub_out[7:0]}:   // rounds 1,3...13
                                                 {block_2[127:104],sub_out[7:0]};   // rounds 2,4...14
              end                       // sub_out[7:0] is the last elemtent for first column
                                        // already considering shift rows after sub bytes

          1:  begin                     // Mix_1
                mix_in <= (rnd_cnt == 0) ? data_in[95:64]:          // round 0
                          (rnd_cnt[0] != 1'b0) ? block_1[95:64]:    // rounds 1,3...13
                                                 block_2[95:64];    // rounds 2,4...14
              end            
        
          2:  begin                     // Mix_2
                mix_in <= (rnd_cnt == 0) ? data_in[63:32]:          // round 0
                          (rnd_cnt[0] != 1'b0) ? block_1[63:32]:    // rounds 1,3...13
                                                 block_2[63:32];    // rounds 2,4...14
              end
              
          3:  begin                     // Mix_3
                mix_in <= (rnd_cnt == 0) ? data_in[31:0]:           // round 0
                          (rnd_cnt[0] != 1'b0) ? block_1[31:0]:     // rounds 1,3...13
                                                 block_2[31:0];     // rounds 2,4...14
              end
              
          
        endcase
      end    
  end


// ---------- MIX OPERATION BY WORD UNIT ----------

mix_w       mix_w_u    (
                        .round      (rnd_cnt_mix),      // round counter as condition to mix column operation
                        .round_key  (rnd_key),          // round key for add round key operation
                        .in         (mix_in),           // column as input for mix operation
                        .out        (mix_out)           // processed column after mix operation
                        );


endmodule