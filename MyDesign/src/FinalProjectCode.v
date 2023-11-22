//Razan Abdelrahman.

//First stage:
// A module to build a 1 bit Full Adder.
module OneBitFullAdder (input x,y,Cin, output Sum,Cout);
	wire w1,w2,w3;	 //Declare wires.
	
	//Build the circuit using gates.
	xor #(12ns) gate1 (w1,x,y);	
	xor #(12ns) gate2 (Sum,w1,Cin);
	and #(8ns) gate3 (w2,w1,Cin);
	and #(8ns) gate4 (w3,x,y);
	or #(8ns) gate5 (Cout,w3,w2);
			
endmodule	 



// A module to build a 4 bits Full Adder.
module FourBitsFullAdder (A,B,Cin,Sum,Cout);   
	//Declare inputs ,outputs & wires.
	input [3:0]A,B;
	input Cin;
	output [3:0]Sum;
	output Cout;
	wire [4:0] w;
	genvar i;
	
	assign w[0]=Cin;
	assign Cout=w[4];
	
	generate 	//The beginning of the generater.
	for(i=0 ; i<4 ; i=i+1 )
		begin : start  
			//Make an instance of the full adder.
			OneBitFullAdder U1 (A[i],B[i],w[i],Sum[i],w[i+1]);
		end
	endgenerate	  //The end of it. 
	
endmodule
	
		
		

// A module to build 1 digit BCD-adder.	
module OneBitDigitBCDAdder (i,j,k,Sum,Cout);	
	//Declare the inputs,outputs & wires.
	input [0:3]i,j;
	input k;
	output [0:3] Sum;
	output Cout;	
	wire [3:0] S,D;
	wire C;	 
	wire w1,w2,W3; 
	wire ignoredCout;
	
	
	//Make an instance from the full adder (for four bits).
	FourBitsFullAdder U1 (i,j,k,S,Cout);	
	//Use gates to make some operations.
	and #(8ns) G1 (w1,S[3],S[2]);
	and #(8ns) G2 (w2,S[3],S[1]);
	or #(8ns) G3 (Cout,w1,w2);	
	assign D[0]=0,
    D[1]=Cout,
	D[2]=Cout,
	D[3]=0;		 
	//Make another instance from the full adder (for four bits).
	FourBitsFullAdder U2 (S,D,1'b0,Sum,ignoredCout);
	
endmodule



//A module to build D-Flip Flop.
module register (CLK,reset,D,Q);		 
	input CLK,reset;
	input [7:0]D;
	output reg [7:0]Q;
	always @ (posedge CLK or negedge reset )
		if(~reset)
			Q=0;
		else
			Q=D;
endmodule
		


//A module to bulid the whole system.
module System (A,B,CarryIn,CLK,reset,CarryOut,S);	
	//Declare inputs,output & wires.
	input [7:0]A,B;
	input CarryIn, CLK,reset;
	
	output  [7:0]S;
	output   CarryOut;
	
	genvar i;
	
	wire [7:0]w1;
	wire [7:0]w2;  
	wire [8:0]w3;
	wire z1;	
		  
	//Take the inputs from the register.
	register U1 (CLK,reset,A,w1); 	
	register U2 (CLK,reset,B,w2);	
				
	//Make 2-instances from bcd adder to make 8-bits bcd adder.
		OneBitDigitBCDAdder U3 (w1[3:0],w2[3:0],1'b0,w3[3:0],z1);
		OneBitDigitBCDAdder U4 (w1[7:4],w2[7:4],z1,w3[7:4],w3[8]);  
		assign CarryOut=w3[8];
	//Give the output to the register.	
	register U5 (CLK,reset,w3[7:0],S);
			
endmodule	



// A module to build bcd-adder (Behaviourally).
module bcd_adder(A,B,CarryIn,Sum,CarryOut);
//declare the inputs and outputs of the module with their sizes.
    input [3:0] A,B;
    input CarryIn;
    output reg[3:0] Sum;
    output reg CarryOut;

    reg [4:0] Temp;  

//The always block for doing the addition operation.
    always @(A or B or CarryIn)
    begin
        Temp = A+B+CarryIn; //Add all the inputs.
        if(Temp > 9)//Check if the result greater then 9,    
			begin
            	Temp = Temp+6; //If is, add 6 to the result.
            	CarryOut = 1;  //Set the carry output.
            	Sum = Temp[3:0];   
			end
        else  
			begin	 //If not,
            	CarryOut = 0;//Set the carry to zero.
            	Sum = Temp[3:0];//The result doesn't change.
       	    end	 
		end
endmodule 
   


//The first step of the verfication is : Test generator.
//To Test the circuit and give the true value.(expected one).
module TestGenerater (A,B,CarryIn,S,CarryOut); 	 
	//Declare the inputs,outputs & wires.
	input [7:0]A,B;
	input CarryIn;
	
	output [7:0]S;
	output  CarryOut;
	
	wire z1;		 
	
	//Make 2-instances from the bcd-adder.
	bcd_adder part1 (A[3:0],B[3:0],CarryIn,S[3:0],z1);
	bcd_adder part2 (A[7:4],B[7:4],z1,S[7:4],CarryOut);
	
endmodule

		
//The test for the whole system (Verfication).	
module TestTheSystem();
	//Declare the inputs as registers and the outputs as wires.
	reg CLK,reset,CarryIn;
	reg [7:0] A,B;
	wire [7:0] Sum1,Sum2;
	wire CarryOut1,CarryOut2;
	
	//Make an instance from the test generator.
	TestGenerater U1 (A,B,CarryIn,Sum1,CarryOut1);
	//Make an instance from the system (strucrally).
	System U2 (A,B,CarryIn,CLK,reset,CarryOut2,Sum2);	  
	 
	
	initial	
		 begin
			{CarryIn,A,B}=9'h000;
			 //Call the task to compare between the results.
			comparater(Sum1,Sum2,CarryOut1,CarryOut2);
			repeat (65535)	
			#10ns {CarryIn,A,B}={CarryIn,A,B}+9'h001; 
		end
			
		
								  	
			
	//The second step of the verfication is :  Result Analyzer.
	//To compare between the result that come out from the system and the expected one.
	task comparater;
	input [7:0] s1,s2;
	input C1,C2;   
	
	if ({s1,C1}!={s2,C2})//If they are not equal, print this to the screen.
		$display("The result is uncorrect!"); 	
	endtask
	
endmodule
//***************************************************************************************************************************
//The next satge:	

//A module to build 4-bit look ahead adder.
module FourBitsCLAAdder(A,B,Cin,Sum,Cout);	
	//Declare inputs,outputs& wires.
	input[3:0] A,B;
	input Cin;	   
	
	output [3:0] Sum;
	output Cout;
	
	wire p0,p1,p2,p3,g0,g1,g2,g3,c1,c2,c3,c4;  
	wire [9:0]w;
	
	//Build the circuit structurally using gates and delay.
	xor #(12ns) G1 (p0,A[0],B[0]);	 
	xor #(12ns) G2 (p1,A[1],B[1]);
	xor #(12ns) G3 (p2,A[2],B[2]);
	xor #(12ns) G4 (p3,A[3],B[3]);	
	
	and #(8ns) G5 (g0,A[0],B[0]);
	and #(8ns) G6 (g1,A[1],B[1]);
	and #(8ns) G7 (g2,A[2],B[2]);
	and #(8ns) G8 (g3,A[3],B[3]);
	
	assign c0=Cin;
	and #(8ns) part1 (w[0],p0,Cin);
	or #(8ns) part2 (c1,g0,w[0]);
	
	and #(8ns) part3 (w[1],p1,p0,Cin);
	and #(8ns) part4 (w[2],p1,g0);
	or #(8ns) part5 (c2,g1,w[1],w[2]);
	
	and #(8ns) part6 (w[3],p1,p1,p0,Cin); 
	and #(8ns) part7 (w[4],p2,p1,g0);
	and #(8ns) part8 (w[5],p2,g1);
	or #(8ns) part9 (c3,w[3],w[4],w[5]);  
	
	and #(8ns) part10 (w[6],p3,p2,p1,p0,Cin);
	and #(8ns) part11 (w[7],p3,p2,p1,g0);  
	and #(8ns) part12 (w[8],p3,p2,p1); 
	and #(8ns) part13 (w[9],p3,g2);
	or #(8ns) part14 (c4,w[6],w[7],w[8],w[9]);
	
	
	xor #(12ns) G9 (Sum[0],p0,c0);	
	xor #(12ns) G10 (Sum[1],p1,c1);
	xor #(12ns) G11 (Sum[2],p2,c2);
	xor #(12ns) G12 (Sum[3],p3,c3);


	assign Cout=c4;
endmodule



//A module to bulid 1-bcd adder using the carry look ahead adder.
//Declare the inputs,outputs & wires. 
module BCDAdderUsingCLAAdder (i,j,k,Sum,Cout);
	input [0:3]i,j;
	input k;
	output [0:3] Sum;
	output Cout;	
	wire [3:0] S,D;
	wire C;	 
	wire w1,w2,W3; 
	wire ignoredCout;
	
	
	//Make an instance from the carry look ahead adder (for four bits).
	 FourBitsCLAAdder U1 (i,j,k,S,Cout);	
	//Use gates to make some operations.
	and #(8ns) G1 (w1,S[3],S[2]);
	and #(8ns) G2 (w2,S[3],S[1]);
	or #(8ns) G3 (Cout,w1,w2);	
	assign D[0]=0,
    D[1]=Cout,
	D[2]=Cout,
	D[3]=0;		 
	//Make another instance from the carry look ahead adder (for four bits).
	FourBitsCLAAdder U2 (S,D,1'b0,Sum,ignoredCout);
	
endmodule
	

//A module to bulid the hole system.
module SystemCLAAdder (A,B,CarryIn,CLK,reset,CarryOut,S);	
	//Declare inputs,output & wires.
	input [7:0]A,B;
	input CarryIn, CLK,reset;
	
	output  [7:0]S;
	output   CarryOut;
	
	genvar i;
	
	wire [7:0]w1;
	wire [7:0]w2;  
	wire [8:0]w3;
	wire z1;	
	

	//Take the inputs from the register.
	register U1 (CLK,reset,A,w1); 	
	register U2 (CLK,reset,B,w2);		
				
	//Make 2-instances from bcd adder to make 8-bits bcd adder.
	  BCDAdderUsingCLAAdder U3 (w1[3:0],w2[3:0],1'b0,w3[3:0],z1);
	  BCDAdderUsingCLAAdder U4 (w1[7:4],w2[7:4],z1,w3[7:4],w3[8]);  
	  
	  assign CarryOut = w3[8];
	  //Give the outputs to the register.
	register U5 (CLK,reset,w3[7:0],S);
			 	
endmodule	
	


//The first step of the verfication is : Test generator.
//To Test the circuit and give the true value.(expected one).
module TestGenerater2 (A,B,CarryIn,S,CarryOut); 	 
	//Declare the inputs,outputs & wires.
	input [7:0]A,B;
	input CarryIn;
	
	output [7:0]S;
	output  CarryOut;
	
	wire z1;		 
	
	//Make 2-instances from the bcd-adder.
	bcd_adder part1 (A[3:0],B[3:0],CarryIn,S[3:0],z1);
	bcd_adder part2 (A[7:4],B[7:4],z1,S[7:4],CarryOut);
	
endmodule



//The test for the hole system (Verfication).	
module TestTheSystem2();
	//Declare the inputs as registers and the outputs as wires.
	reg CLK,reset,CarryIn;
	reg [7:0] A,B;
	wire [7:0] Sum1,Sum2;
	wire CarryOut1,CarryOut2;
	
	//Make an instance from the test generator.
	TestGenerater2 U1 (A,B,CarryIn,Sum1,CarryOut1);	 
	
	//Make an instance from the system (strucrally).   
	TestGenerater2 U2 (A,B,CarryIn,Sum2,CarryOut2);	
	//SystemCLAAdder U2 (A,B,CarryIn,CLK,reset,CarryOut2,Sum2);	

	initial	
		 begin
			{CarryIn,A,B}=9'h000;
			 //Call the task to compare between the results.
			comparater2 (Sum1,Sum2,CarryOut1,CarryOut2);
			repeat (65535)	
			#10ns {CarryIn,A,B}={CarryIn,A,B}+9'h001; 
		end
	
	//The second step of the verfication is :  Result Analyzer.
	//To compare between the result that come out from the system and the expected one.
	task comparater2;
	input [7:0] s1,s2;
	input C1,C2;   
	
	if ({s1,C1}!={s2,C2})//If they are not equal, print this to the screen.
		$display("The result is uncorrect!"); 	
	endtask
	
endmodule



//Thank You.
//**************************************************************************************************************************