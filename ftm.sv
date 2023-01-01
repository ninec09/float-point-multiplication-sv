module multiplier (input logic [22:0] a,b,output logic [47:0] product);
logic [23:0] op_a, op_b;
assign op_a = (|a[30:23]) ? {1'b1,a[22:0]} : {1'b0,a[22:0]};
assign op_b = (|b[30:23]) ? {1'b1,b[22:0]} : {1'b0,b[22:0]};;
assign product = op_a * op_b;
endmodule


module addition (input logic [7:0] exponent1, exponent2, output logic [7:0] y);
assign y = exponent1 + exponent2 - 127;       
endmodule


module sign #(parameter N = 1)
(input logic sign1, sign2, output logic signOut);        
assign signOut = sign1 ^ sign2;
endmodule


module normalised (input logic [47:0] product, input logic [7:0] exponent, output logic [22:0] product_mantissa,output logic [7:0] exponentRes);
logic normalised,round;
logic [47:0] product_normalised;
assign round = |product_normalised[22:0]; 
assign normalised = product[47] ? 1'b1 : 1'b0;                 
assign product_normalised = normalised ? product : product << 1;	

assign product_mantissa = product_normalised[46:24] + (product_normalised[23] & round); 
assign exponentRes = exponent;      
endmodule 	

// yukardaki modulleri isledigim son modul.
module fpMultiplication(input logic [31:0] x, y,output logic [31:0] fpmult);
logic [7:0] expx, expy, exponent, expoRes;
logic [22:0] floatOne, floatTwo, floatOut;
logic signOne, signTwo, signOut;
logic [47:0] mantissa;
assign {expx, floatOne} = {x[30:23], x[22:0]};
assign {expy, floatTwo} = {y[30:23], y[22:0]};
assign signOne = x[31];
assign signTwo = y[31];
multiplier mult(floatOne, floatTwo, mantissa);                                                 
addition add(expx, expy, exponent);                                 // exponent modulu Out.
signCalculation signcalc(signOne, signTwo, signOut);                // isaret biti modulu Out.
normalize norm(mantissa, exponent, floatOut, expoRes);              // normalize islemi Out.
assign fpmult = {signOut,expoRes,floatOut};                         // modulun sonucu.
endmodule 

module testbench();
logic [31:0] x, y, out;
fpMultiplication multiplication(x,y,out);
initial begin
assign x = 32'b10111110100110011001100110011010;                    // -0.3 sayisinin gosterimi
assign y = 32'b01000011111110100010000000000000; #10;               // 500.25 sayisinin gosterimi
end
endmodule
