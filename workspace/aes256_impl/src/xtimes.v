
// ---------- MULTIPLY BY 2 ----------

/*
   2 = 0010 = x ;   v = 1011 0010 = x7 + x5 + x4 + x ;   P = 'h11B = 1 0001 1011 = x8 + x4 + x3 + x + 1
   v*2 = v*x = (x7 + x5 + x4 + x)x = x8 + x6 + x5 + x2;
   v*2(modP) = (x8 + x6 + x5 + x2) + (x8 + x4 + x3 + x + 1) = x6 + x5 + x4 + x3 + x2 + x + 1 = 0111 1111
*/

module xtimes    ( in, out );


// ---------- MODULE INTERFACE ----------

input       [7:0]	in;
output      [7:0]	out;


// ---------- MODULE REGISTERS AND SIGNALS ----------

wire    [3:0]       xt;


// ---------- MODULE IMPLEMENTATION ----------

// same as: xt = in[7] ? 1101 : 0000;
assign xt[3] = in[7];
assign xt[2] = in[7];
assign xt[1] = 1'b0;
assign xt[0] = in[7];

// if in = 1011 0010, in * 2 (mod P)= 1 0110 0100 
//                                xor 1 0001 1011 = 011 1111 1
// same as: {in[6:4], xt ^ in[3:0], in[7]} =        011,1111,1

assign out[7:5] = in[6:4];
assign out[4:1] = xt[3:0] ^ in[3:0];  // 1101 ^ 0010 = 1111
assign out[0]   = in[7];

endmodule