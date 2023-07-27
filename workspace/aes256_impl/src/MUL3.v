
// ---------- MULTIPLY BY 3 ----------

module MUL3     ( in, out );


// ---------- MODULE INTERFACE ----------

input       [7:0]	in;
output      [7:0]	out;


// ---------- MODULE REGISTERS AND SIGNALS ----------

wire    [7:0]       xt;


// ---------- MODULE IMPLEMENTATION ----------

assign out = xt ^ in;


// ---------- MODULES INSTANTIATION ----------

xtimes  xt_u    ( .in(in), .out(xt) );


endmodule