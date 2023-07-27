
// ---------- MIX COLUMNS FOR ENC WORD ----------

module mix_w    ( round, round_key, in, out );


// ---------- MODULE INTERFACE ----------

input       [3:0]   round;
input       [31:0]  round_key;
input       [31:0]  in;
output      [31:0]  out;


// ---------- MODULE REGISTERS AND SIGNALS ----------

wire    [7:0]       byte0_in, byte1_in, byte2_in, byte3_in;
wire    [7:0]       byte0_out, byte1_out, byte2_out, byte3_out;


// ---------- MODULE IMPLEMENTATION ----------

assign byte0_in[7:0] = in[31:24];
assign byte1_in[7:0] = in[23:16];
assign byte2_in[7:0] = in[15:8];
assign byte3_in[7:0] = in[7:0];

assign out = (round == 0 || round == 14) ? in ^ round_key : {byte0_out, byte1_out, byte2_out, byte3_out} ^ round_key;


// ---------- MODULES INSTANTIATION ----------

byte_mix byte_mix0_u (.a(byte0_in), .b(byte1_in), .c(byte2_in), .d(byte3_in), .out(byte0_out));

byte_mix byte_mix1_u (.a(byte1_in), .b(byte2_in), .c(byte3_in), .d(byte0_in), .out(byte1_out));

byte_mix byte_mix2_u (.a(byte2_in), .b(byte3_in), .c(byte0_in), .d(byte1_in), .out(byte2_out));

byte_mix byte_mix3_u (.a(byte3_in), .b(byte0_in), .c(byte1_in), .d(byte2_in), .out(byte3_out));


endmodule