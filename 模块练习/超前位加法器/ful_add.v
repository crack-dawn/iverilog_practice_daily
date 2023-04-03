//一位加法器
// 基础练习
module Add1
(
		input a,
		input b,
		input C_in,
		output f,
		output g,
		output p
		);
assign f=a^b^C_in;
assign g=a&b;
assign p=a|b;
endmodule

//4位CLA部件
module CLA_4(
		input [3:0]P,
		input [3:0]G,
		input C_in,
		output [4:1]Ci,
		output Gm,
		output Pm
	);
assign Ci[1]=G[0]|P[0]&C_in;
assign Ci[2]=G[1]|P[1]&G[0]|P[1]&P[0]&C_in;
assign Ci[3]=G[2]|P[2]&G[1]|P[2]&P[1]&G[0]|P[2]&P[1]&P[0]&C_in;
assign Ci[4]=G[3]|P[3]&G[2]|P[3]&P[2]&G[1]|P[3]&P[2]&P[1]&G[0]|P[3]&P[2]&P[1]&P[0]&C_in;

assign Gm=G[3]|P[3]&G[2]|P[3]&P[2]&G[1]|P[3]&P[2]&P[1]&G[0];
assign Pm=P[3]&P[2]&P[1]&P[0];
endmodule

//四位超前进位加法器
module Add4_head
(
	input [3:0]A,
	input [3:0]B,
	input C_in,
	output [3:0]F,
	output Gm,
	output Pm,
	output C_out
);
	wire [3:0] G;
	wire [3:0] P;
	wire [4:1] C;
 Add1 u1
 (	.a(A[0]),
	.b(B[0]),
	.C_in(C_in),
	.f(F[0]),
	.g(G[0]),
	.p(P[0])
 );
  Add1 u2
 (	.a(A[1]),
	.b(B[1]),
	.C_in(C[1]),
	.f(F[1]),
	.g(G[1]),
	.p(P[1])
 );
   Add1 u3
 (	.a(A[2]),
	.b(B[2]),
	.C_in(C[2]),
	.f(F[2]),
	.g(G[2]),
	.p(P[2])
 );
   Add1 u4
 (	.a(A[3]),
	.b(B[3]),
	.C_in(C[3]),
	.f(F[3]),
	.g(G[3]),
	.p(P[3])
 );
 CLA_4 uut
 (
	.P(P),
	.G(G),
	.C_in(C_in),
	.Ci(C),
	.Gm(Gm),
	.Pm(Pm)
 );
  assign C_out=C[4];
 endmodule
