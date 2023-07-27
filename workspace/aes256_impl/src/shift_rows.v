`timescale 1ns / 1ps

/*          
            Initial Matrix
    127:120 | 95:88 |  63:56  |  31:24
    119:112 | 87:80 |  55:48  |  23:16
    111:104 | 79:72 |  47:40  |  15:8
    103:96  | 71:64 |  39:32  |   7:0
    
            After Shift Rows
    127:120 |  95:88 |  63:56  |  31:24
     87:80  |  55:48 |  23:16  | 119:112
     47:40  |  15:8  | 111:104 |  79:72
      7:0   | 103:96 |  71:64  |  39:32
    
*/

// ---------- SHIFT ROWS and OUTPUT ----------

module shift_rows  (
                    clk,
                    reset_n,
                    rnd_cnt,
                    step,
                    sub_out,
                    mix_out,
                    block_1,            // output
                    block_2             // output
                    );


// ---------- MODULE INTERFACE ----------

input               clk;                // global clock
input               reset_n;            // global negative edge reset
input       [3:0]   rnd_cnt;            // round counter [0 to 14]
input       [2:0]   step;               // step counter [0 to 4]
input       [31:0]  sub_out;            // processed column after substitution bytes operation
input       [31:0]  mix_out;            // processed column after mix operation
output reg  [127:0] block_1;            // storage block used after first shift rows operation and to store final output(data_out)
output reg  [127:0] block_2;            // storage block used after second shift rows operation


// ---------- MODULE IMPLEMENTATION ----------

always @ (posedge clk or negedge reset_n)
  begin: SHIFT_ROWS
  
    if (!reset_n)                       // reset blocks registers
      begin
        block_1 <= 128'b0;
        block_2 <= 128'b0;
      end
      
    else
        case (step)
        
          0:  begin                         // Shift_3
                if(rnd_cnt[0] != 1'b0)      // for rounds 1,3...13
                  {block_1[31:24],block_1[55:48],block_1[79:72],block_1[103:96]} <= sub_out;
                else                        // for rounds 2,4...14
                  {block_2[31:24],block_2[55:48],block_2[79:72],block_2[103:96]} <= sub_out;
              end
                                            // data_out first column
          1:  if(rnd_cnt == 4'd14) block_1[127:96] <= mix_out;

          2:  begin                     
                if(rnd_cnt == 4'd14)        // data_out second column
                  block_1[95:64] <= mix_out;
                else
                  begin                     // Shift_0
                    if(rnd_cnt[0] == 1'b0)  // for rounds 0,2...12
                      {block_1[127:120],block_1[23:16],block_1[47:40],block_1[71:64]} <= sub_out;
                    else                    // for rounds 1,3..13
                      {block_2[127:120],block_2[23:16],block_2[47:40],block_2[71:64]} <= sub_out;
                  end    
              end

          3:  begin                     
                if(rnd_cnt == 4'd14)        // data_out third column
                block_1[63:32] <= mix_out;
                else
                  begin                     // Shift_1
                    if(rnd_cnt[0] == 1'b0)  // for rounds 0,2...12
                      {block_1[95:88],block_1[119:112],block_1[15:8],block_1[39:32]} <= sub_out;
                    else                    // for rounds 1,3..13
                      {block_2[95:88],block_2[119:112],block_2[15:8],block_2[39:32]} <= sub_out;
                  end
              end

          4:  begin                     
                if(rnd_cnt == 4'd0)         // data_out fourth column
                  block_1[31:0] <= mix_out;
                else
                  begin                     // Shift_2
                    if(rnd_cnt[0] == 1'b1)  // for rounds 0,2...12
                      {block_1[63:56],block_1[87:80],block_1[111:104],block_1[7:0]} <= sub_out;
                    else                    // for rounds 1,3..13
                      {block_2[63:56],block_2[87:80],block_2[111:104],block_2[7:0]} <= sub_out;
                  end                
              end

        endcase

  end


endmodule