/*
    Project     :   Float Point Multiplication implemantation SystemVerilog
    Date        :   01.01.2023
    Author      :   Mehmet Sucuk   
    
    Example : float point multiplication result
    32 bit
    sign | exponent | mantissa
        1| 10000110 | 00101100001001100110100
          
*/

// Required product for mantis part.
module multiplier (input logic [31:0] a,b, output logic [47:0] product);
logic [23:0]                               op_a, op_b;
assign op_a                              = (|a[30:23]) ? {1'b1,a[22:0]} : {1'b0,a[22:0]};
assign op_b                              = (|b[30:23]) ? {1'b1,b[22:0]} : {1'b0,b[22:0]};
assign product                           = op_a * op_b;
endmodule

// determination of the sign
module sign (input logic sign1, sign2, output logic signOut);        
assign signOut                          = sign1 ^ sign2;
endmodule

// output mantissa and exponent 
module normalize (input logic [47:0] product, input logic [8:0] exponent_a,exponent_b, output logic [22:0] product_mantissa, output logic [8:0] exponentResult);
logic                                     normalised,round;
logic [47:0]                              product_normalised;
assign normalised                       = product[47] ? 1'b1 : 1'b0;                 
assign product_normalised               = normalised ? product : product << 1;	
assign round                            = |product_normalised[22:0]; 
assign product_mantissa                 = product_normalised[46:24] + (product_normalised[23] & round); 
assign exponentResult                   = (exponent_a + exponent_b) - 8'd127 + normalised;
endmodule 	

module fpMultiplication (input logic [31:0] x, y,output logic [31:0] fpmult);
logic                                     sign_x, sign_y, signResult;
logic [8:0]                               exponent_x, exponent_y, exponentResult;;
logic [22:0]                              product_mantissa;
logic [47:0]                              product;

assign exponent_x                       = x[30:23]; 
assign exponent_y                       = y[30:23]; 
assign sign_x                           = x[31];
assign sign_y                           = y[31];

multiplier  mult(x, y, product);                                                                                                                                
sign        signcalc(sign_x,sign_y,signResult);                               
normalize   norm(product,exponent_x,exponent_y,product_mantissa,exponentResult);

assign fpmult = {signResult,exponentResult[7:0],product_mantissa};                                   
endmodule 

//---------------------------------------------------------------------------------

module testbench();
logic [31:0] x, y, out;
fpMultiplication multiplication(x,y,out);
initial begin
assign x = 32'b10111110100110011001100110011010;                   // x     = -0.3 
assign y = 32'b01000011111110100010000000000000;                   // y     = 500.25
#10;                                                               // out   = 0xC3161334

assign x = 32'b01000000010010011001100110011010;                   // x     = 3.15 
assign y = 32'b11000001011001100011110101110001;                   // y     = -14.39 
#10;                                                               // out   = 0xC2355063

assign x = 32'b01000101100000000000000000000000;                   // x     = 4096 
assign y = 32'b01000101100000000000000000000000;                   // y     = 4096 
#10;                                                               // out   = 0x4B800000

assign x = 32'b01001010100110001001011010000000;                   // x     = 5000000 
assign y = 32'b01001010100110001001011010000000;                   // y     = 5000000 
#10;                                                               // out   = 0x55B5E621

assign x = 32'b00000000000000000000000000000000;                   // x     = 0 
assign y = 32'b00000000000000000000000000000000;                   // y     = 0 
#10;                                                               // out   = 0x00000000

end
endmodule
