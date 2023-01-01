/*
    Project     :   Float Point Multiplication
    Date        :   01.01.2023
    Author      :   Mehmet Sucuk         
*/



module multiplier (input logic [31:0] a,b,output logic [47:0] product);
logic [23:0] op_a, op_b;
assign op_a = (|a[30:23]) ? {1'b1,a[22:0]} : {1'b0,a[22:0]};
assign op_b = (|b[30:23]) ? {1'b1,b[22:0]} : {1'b0,b[22:0]};
assign product = op_a * op_b;
endmodule


module sign #(parameter N = 1)
(input logic sign1, sign2, output logic signOut);        
assign signOut = sign1 ^ sign2;
endmodule


module normalize (input logic [47:0] product, input logic [7:0] exponent_a,exponent_b, output logic [22:0] product_mantissa,output logic [7:0] exponentResult);
logic normalised,round;
logic [47:0] product_normalised;
assign normalised = product[47] ? 1'b1 : 1'b0;                 
assign product_normalised = normalised ? product : product << 1;	
assign round = |product_normalised[22:0]; 
assign product_mantissa = product_normalised[46:24] + (product_normalised[23] & round); 
assign exponentResult = exponent_a + exponent_b - 8'd127+1;
endmodule 	


module fpMultiplication(input logic [31:0] x, y,output logic [31:0] fpmult);
logic [7:0]  exponent_x, exponent_y;
logic [7:0]  exponentResult;
logic [22:0] product_mantissa;
logic sign_x, sign_y, signResult;
logic [47:0] product;

assign exponent_x = x[30:23]; 
assign exponent_y = y[30:23]; 
assign sign_x = x[31];
assign sign_y = y[31];

multiplier  mult(x, y, product);                                                                                                                                
sign        signcalc(sign_x,sign_y,signResult);                               
normalize   norm(product,exponent_x,exponent_y,product_mantissa,exponentResult);                    


assign fpmult = {signResult,exponentResult,product_mantissa};                              
endmodule 

module testbench();
logic [31:0] x, y, out;
fpMultiplication multiplication(x,y,out);
initial begin

assign x = 32'b10111110100110011001100110011010;                   // -0.3 sayisinin gosterimi
assign y = 32'b01000011111110100010000000000000;                   // 500.25 sayisinin gosterimi
                                                                   // sonuc : 0xC3161334
#10;

assign x = 32'b01000000010010011001100110011010;                   // 3.15 sayisinin gosterimi
assign y = 32'b11000001011001100011110101110001;                   // -14.39 sayisinin gosterimi
                                                                   // sonuc : 0xC2355063
#10;

assign x = 32'b01000101100000000000000000000000;                   // 4096 sayisinin gosterimi
assign y = 32'b01000101100000000000000000000000;                   // 4096 sayisinin gosterimi
                                                                   // sonuc : 0x4B800000
#10;

assign x = 32'b00000000000000000000000000000000;                   // 0 sayisinin gosterimi
assign y = 32'b00000000000000000000000000000000;                   // 0 sayisinin gosterimi
                                                                   // sonuc : 0x00000000
#10;

end
endmodule
