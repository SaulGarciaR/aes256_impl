
// ---------- BYTE MIX COLUMNS ----------

module byte_mix (   a, b, c, d, out );


// ---------- MODULE INTERFACE ----------

input       [7:0]   a, b, c, d;
output      [7:0]   out;


// ---------- MODULE REGISTERS AND SIGNALS ----------

wire [7:0] mul2, mul3;


// ---------- MODULE IMPLEMENTATION ----------

assign out = mul2 ^ mul3 ^ c ^ d;


// ---------- MODULES INSTANTIATION ----------

xtimes      xt_u       (    .in(a), .out(mul2)  );
                        
MUL3        mul3_u     (    .in(b), .out(mul3)  );


endmodule