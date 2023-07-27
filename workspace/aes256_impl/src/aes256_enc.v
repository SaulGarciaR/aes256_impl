`timescale 1ns / 1ps

// ---------- ADVANCED ENCRYPTION STANDARD --- AES-256 --- ENCRYPTION ----------

module aes256_enc  (
                    clk,
                    reset_n,
                    start,
                    key_in,
                    data_in,
                    data_out,
                    ready
                    );

    
// ---------- MODULE INTERFACE ----------

input               clk;                // global clock
input               reset_n;            // global async negative edge reset
input               start;              // start pulse
input       [255:0] key_in;             // 256-bit key
input       [127:0] data_in;            // 128-bit block size of plaintext
output wire [127:0] data_out;           // 128-bit ciphertext and also as storage block
output wire         ready;              // output ready


// ---------- MODULE REGISTERS AND SIGNALS ----------

wire    [3:0]       rnd_cnt;            // round counter [0 to 14]
wire    [2:0]       step;               // step counter [0 to 4]
wire    [31:0]      mix_out;            // processed column after mix operation
wire    [31:0]      sub_out;            // processed column after substitution bytes operation
wire    [127:0]     block_2;            // storage block for shift rows operation
wire    [31:0]      rnd_key;            // round key for add round key operation
wire    [31:0]      k3, k7_rot;         // word 3 and word 7 used for key expansion


// ---------- MODULES INSTANTIATION ----------

// ---------- ROUND AND STEP COUNTERS ----------

counters        counters_u     (
                                clk,
                                reset_n,
                                start,
                                rnd_cnt,    // output
                                step,       // output
                                ready       // output
                                );

// ---------- MIX COLUMNS UNIT ----------

mix_columns     mix_columns_u  (
                                clk,
                                reset_n,
                                rnd_cnt,
                                step,
                                data_in,
                                data_out,
                                block_2,
                                sub_out,
                                rnd_key,
                                mix_out     // output
                                );

// ---------- SUB BYTES UNIT ----------

sub_bytes       sub_bytes_u    (
                                clk,
                                reset_n,
                                rnd_cnt,
                                step,
                                k3, k7_rot,
                                mix_out,
                                sub_out      // output
                                );

// ---------- SHIFT ROWS UNIT ----------

shift_rows      shift_rows_u   (
                                clk,
                                reset_n,
                                rnd_cnt,
                                step,
                                sub_out,
                                mix_out,
                                data_out,   // output
                                block_2     // output
                                );
                                
// ---------- KEY EXPANSION UNIT ----------

key_exp         key_exp_u      (
                                clk,
                                reset_n,
                                rnd_cnt,
                                step,
                                key_in,
                                sub_out,
                                k3, k7_rot, // output
                                rnd_key     // output
                                );


endmodule
