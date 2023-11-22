module fulladder (a,b,Cin,S,Cout);
	input a,b,Cin;
	output S,Cout;
	wire z1,z2,z3;
	xor #(12ns) gate1 (z1,a,b);
	and #(8ns) gate2 (z2,z1,Cin);
	and #(8ns) gate3 (z3,a,b);
	xor #(12ns) gate4 (S,z1,Cin);
	or #(8ns) gate5 (Cout,z2,z3);
endmodule 


module adder4 (a,b,CarryIn,Sum,CarryOut);
	input [3:0]a,b;
	input CarryIn;
	output [3:0] Sum;
	output CarryOut; 
	wire [4:0] z;
	genvar k;
	
	assign z[0] = CarryIn,
	CarryOut=z[4];
	
	
	generate 
	for (k=0 ; k<=3 ; k=k+1)
		begin 
			fulladder U1 (.a(a[k]),.b(b[k]),.Cin(z[k]),.S(Sum[k]),.Cout(z[k+1]));
		end	
	endgenerate
endmodule


module bcdadder (x,y,Cin,Sum,Cout);		 
	input [3:0]x,y;
	input Cin;
	output [3:0] Sum;
	output Cout;	
	wire [3:0]S1,S2;
	wire z1,z2,z3;
	wire ignoredCout;
	
	
	
	adder4 U1 (x,y,Cin,S1,Cout);	 
	adder4 U2 (S1,S2,1'b0,Sum,ignoredCout);
	
	and #(8ns) gate1 (z1,S1[3],S1[2]);
	and #(8ns) gate2 (z2,S1[3],S1[1]);
	or #(8ns) gate3 (z3,Cout,z1,z2);	
	assign S2[0]=0,
    S2[1]=Cout,
	S2[2]=Cout,
	S2[3]=0;		 
	
	
endmodule 


module DFF (CLK,reset,D,Q);		 
	input CLK,reset;
	input D;
	output reg Q;
	always @ (posedge CLK or negedge reset )
		if(~reset)
			Q=0;
		else
			Q=D;
endmodule



module system (x,y,Cin,CLK,reset,S,Cout);	
	input Cin, CLK,reset;
	input [7:0]x,y;
    output   Cout;
	output  [7:0]S;
	genvar k;
	wire [7:0]c1,c2;  
	wire [8:0]c3;
	wire z1;				
	
	generate
	for (k=0 ; k<=7 ; k=k+1)
		begin 
			DFF u1 (.CLK(CLK),.reset(reset),.D(x[k]),.Q(c1[k]));
		end	 
		
	for (k=0 ; k<=7 ; k=k+1)
		begin 
			DFF u2 (.CLK(CLK),.reset(reset),.D(y[k]),.Q(c2[k]));
		end
		
				
		bcdadder u3 (c1[3:0],c2[3:0],1'b0,c3[3:0],z1);
		bcdadder u4 (c1[7:4],c2[7:4],z1,c3[7:4],c3[8]); 
		
		assign Cout=c3[8];		 
		
		for (k=0 ; k<=7 ; k=k+1)
		begin 
			DFF u5 (.CLK(CLK),.reset(reset),.D(c3[k]),.Q(S[k]));
		end
		endgenerate
			
endmodule 


module BCD (x,y,Cin,S,Cout); 
	input Cin;
	input [3:0]x,y;		
	output reg Cout;
	output reg [3:0]S;	 
	reg [4:0]z;
	
	always @ (*)
		begin
		z=x+y+Cin;
		if(z>9)
			{Cout,S}=z+6;
		else
			{Cout,S}=z;
		end
endmodule
		
	

module testGenerater (x,y,Cin,S,Cout); 	 
	input [7:0]x,y;
	input Cin;
	output [7:0]S;
	output  Cout;
	wire z1;		 
	
	
	BCD U1 (.x(x[3:0]),.y(y[3:0]),.Cin(Cin),.S(S[3:0]),.Cout(z1));
	BCD U2 (.x(x[7:4]),.y(y[7:4]),.Cin(z1),.S(S[7:4]),.Cout(Cout));
	
endmodule 


module Analyzer (s1,s2,c1,c2);
	input [7:0]s1,s2;
	input c1,c2;
	always @ (*)
		begin 
			if ({s1,c1}!={s2,c2})
			$display("Error! Both results are not equal, there's an problem with the addition");
			end
endmodule 


module TEST ();
	reg CLK,reset,Cin;
	reg [7:0] X,Y;
	wire [7:0] S1,S2;
	wire Cout1,Cout2;
	
	testGenerater U1 (.x(X),.y(Y),.Cin(Cin),.S(S1),.Cout(Cout1));
	system U2 (.x(X),.y(Y),.Cin(Cin),.CLK(CLK),.reset(reset),.S(S2),.Cout(Cout2));	  
	Analyzer U3 (S1,S2,Cout1,Cout2); 
	
	initial begin
		{Cin,X,Y}=9'h000;
		repeat (16)		  
		#(10ns) {Cin,X,Y}=({Cin,X,Y})+9'h001;
	end
endmodule

		
	
	
			

		


		