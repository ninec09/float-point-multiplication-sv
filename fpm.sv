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

// calculate mantissa and exponent 
module normalize (input logic [47:0] product, input logic [8:0] exponent_a,exponent_b, output logic [22:0] product_mantissa, output logic [8:0] exponentResult);
logic                                     normalised,round;
logic [47:0]                              product_normalised;
assign normalised                       = product[47] ? 1'b1 : 1'b0;                 
assign product_normalised               = normalised ? product : product << 1;	
assign round                            = |product_normalised[22:0]; 
assign product_mantissa                 = product_normalised[46:24] + (product_normalised[23] & round); 
assign exponentResult                   = (exponent_a + exponent_b) - 8'd127 + normalised;
endmodule 	

module fpMultiplication (input logic [31:0] x, y,output logic [31:0] fpmultResult);
logic                                     sign_x, sign_y, signResult, exception, zero, overflow, underflow;
logic [8:0]                               exponent_x, exponent_y, exponentResult;
logic [22:0]                              product_mantissa;
logic [47:0]                              product;
logic [31:0]                              fpmult;

assign exponent_x                       = x[30:23]; 
assign exponent_y                       = y[30:23]; 
assign sign_x                           = x[31];
assign sign_y                           = y[31];
assign exception                        = (&x[30:23]) | (&y[30:23]);
assign zero                             = exception ? 1'b0 : (product_mantissa == 23'd0) ? 1'b1 : 1'b0;
assign overflow                         = ((exponentResult[8] & !exponentResult[7]) & !zero) ;
assign underflow                        = ((exponentResult[8] & exponentResult[7]) & !zero) ? 1'b1 : 1'b0;

multiplier  mult(x, y, product);                                                                                                                                
sign        signcalc(sign_x,sign_y,signResult);                               
normalize   norm(product,exponent_x,exponent_y,product_mantissa,exponentResult);

assign fpmult = exception ? 32'd0 : zero ? {signResult,31'd0} : overflow ? {signResult,8'hFF,23'd0} : 
                underflow ? {signResult,31'd0} : {signResult,exponentResult[7:0],product_mantissa}  ;

// fpmultResult added for a special test case.
assign fpmultResult = exponentResult[8] ? fpmult : overflow ? fpmult : underflow ? fpmult : 
                      zero ? {signResult, exponentResult[7:0] ,product_mantissa} : fpmult ;                                 
endmodule 

//---------------------------------------------------------------------------------

module testbench();
logic [31:0] x, y, out;
fpMultiplication multiplication(x,y,out);
initial begin
assign x = 32'b10111110100110011001100110011010;                   // x     = 0xBE99999A   
assign y = 32'b01000011111110100010000000000000;                   // y     = 0x43FA2000   
#10;                                                               // out   = 0xC3161334    

assign x = 32'b01000000010010011001100110011010;                   // x     = 0x4049999A
assign y = 32'b11000001011001100011110101110001;                   // y     = 0xC1663D71   
#10;                                                               // out   = 0xC2355063

assign x = 32'b01000101100000000000000000000000;                   // x     = 0x45800000
assign y = 32'b01000101100000000000000000000000;                   // y     = 0x45800000
#10;                                                               // out   = 0x4B800000

assign x = 32'b01001010100110001001011010000000;                   // x     = 0x4A989680
assign y = 32'b01001010100110001001011010000000;                   // y     = 0x4A989680
#10;                                                               // out   = 0x55B5E621

assign x = 32'b00000000000000000000000000000000;                   // x     = 0x00000000 
assign y = 32'b00000000000000000000000000000000;                   // y     = 0x00000000 
#10;                                                               // out   = 0x00000000

assign x = 32'b00000010000000000000000000000000;                   // x     = 0x02000000 
assign y = 32'b00000010000000000000000000000000;                   // y     = 0x02000000 
#10;                                                               // out   = 0x00000000

assign x = 32'b01000010001101001000010100011111;                   // x     = 0x4234851F 
assign y = 32'b01000010011111001000010100011111;                   // y     = 0x427C851F
#10;                                                               // out   = 0x453210EA

end
endmodule
