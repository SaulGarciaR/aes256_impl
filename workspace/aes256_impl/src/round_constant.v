`timescale 1ns / 1ps

/*
            Round Constant
        for K2  K4  K6  K8 K10 K12 K14
    i       1   2   3   4   5   6   7
    -----------------------------------
    RC[i]  01  02  04  08  10  20  40  

*/

// ---------- ROUND CONSTANT ----------

module round_constant  (
                        clk,
                        reset_n,
                        rnd_cnt,
                        step,
                        RC                  // output
                        );


// ---------- MODULE INTERFACE ----------

input               clk;                // global clock
input               reset_n;            // global negative edge reset   
input       [3:0]   rnd_cnt;            // round counter [0 to 14]
input       [2:0]   step;               // step counter [0 to 4]
output reg  [31:0]  RC;                 // round constant for key expansion


// ---------- MODULE IMPLEMENTATION ----------

always @ (posedge clk or negedge reset_n)
  begin: ROUND_CONSTANT
  
    if (!reset_n) RC <= 32'h0;          // reset RC register
                                        // rounds 1,3...13
    else if (step == 0 && rnd_cnt[0] != 0)  
                                        // RC[i] = RC[i-1] << 1
        RC <= (rnd_cnt == 1) ? 32'h01000000 : {RC[30:0],1'b0};
        
  end


endmodule