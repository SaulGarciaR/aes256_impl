`timescale 1ns / 1ps

// ---------- ROUND AND STEP COUNTERS ----------

module counters    (
                    clk,
                    reset_n,
                    start,
                    rnd_cnt,            // output
                    step,               // output
                    ready               // output
                    );


// ---------- MODULE INTERFACE ----------

input               clk;                // global clock
input               reset_n;            // global negative edge reset
input               start;              // start encryption
output reg  [3:0]   rnd_cnt;            // round counter [0 to 14]
output reg  [2:0]   step;               // step counter [0 to 4]
output reg          ready;              // encryption done


// ---------- MODULE REGISTERS AND SIGNALS ----------

parameter           max_rnd = 4'd14;    // AES-256 requires 14 rounds (plus round 0)
parameter           max_steps = 4'd4;   // every round consists on 5 steps (0 to 4)

reg [2:0]           current_state, next_state;
parameter           IDLE = 3'd6,
                    S0 = 3'd0,
                    S1 = 3'd1,
                    S2 = 3'd2,
                    S3 = 3'd3,
                    S4 = 3'd4,
                    DONE = 3'd5;


// ---------- STATE MACHINE ----------

always @ (posedge clk or negedge reset_n)
  begin: STATE_MEMORY
  
    if (!reset_n)   current_state <= IDLE;
    else            current_state <= next_state;
    
  end


always @ (current_state or start or ready or reset_n)
  begin: NEXT_STATE_LOGIC
  
    case (current_state)
      IDLE :    next_state = (start) ? S1 : IDLE;   // start step counter with start
      S0 :      next_state = (ready) ? DONE : S1;   // to DONE if ready, else continue encryption
      S1 :      next_state = S2;
      S2 :      next_state = S3;
      S3 :      next_state = S4;
      S4 :      next_state = S0;                    // resets after step = 4
      DONE:     next_state = (start) ? S1 : DONE;   // it can start from DONE state
      default : next_state = IDLE;
    endcase
    
  end


always @ (current_state or rnd_cnt)
  begin: OUTPUT_LOGIC
  
    case (current_state)
      IDLE :  begin  
                step = 3'd0;
                ready = 1'b0;
              end
              
      S0 :    begin
                step = 3'd0;
                if (rnd_cnt == 0)   ready = 1'b1;   // when round counter finishes and step = 0
                else                ready = 1'b0;
              end

      S1 :    begin
                step = 3'd1;
                ready = 1'b0;
              end
      
      S2 :    begin
                step = 3'd2;
                ready = 1'b0;
              end
      
      S3 :    begin
                step = 3'd3;
                ready = 1'b0;
              end
      
      S4 :    begin
                step = 3'd4;
                ready = 1'b0;
              end
               
      DONE :  begin  
                step = 3'd0;
                ready = 1'b1;       // Encryption DONE
              end
              
      default : begin  
                  step = 3'd0;
                  ready = 1'b0;
                end
    endcase
    
  end

always @ (posedge clk or negedge reset_n)
  begin
  
    if (!reset_n)
      begin
        rnd_cnt <= 4'b0;                            // reset of round counter
      end
    else
      if(current_state == S3)                       // round counter only when step = 3
        if (rnd_cnt == max_rnd) rnd_cnt <= 4'b0;    // reset when round = 14
        else                    rnd_cnt <= rnd_cnt + 1;

  end


endmodule
