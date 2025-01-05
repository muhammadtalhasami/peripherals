//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2024 04:36:32 AM
// Design Name: 
// Module Name: i2c_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module i2c_top(
input clk,
input rst,
input r_w,
input [7:0]slave_address,
input [7:0]register_address,
input [7:0]data,
input load
    );

logic sda_in;
logic sda_out_en;
logic sda_out;
logic scl;


  i2c_master u_i2c_master0(      
     .clk(clk),
     .rst(rst),
     .load(load),
     .read_write_bit(r_w),
     .sda_in(sda_in),
     .device_address(slave_address),
     .register_address(register_address),
     .data(data),
     .sda_out_en(sda_out_en),
     .scl(scl),
     .sda_out(sda_out)
   );
   
   i2c_slave u_i2c_slave0(      
    .clk(clk),
    .rst(rst),
    .sda_out_en(sda_out_en),
    .scl(scl),
    .sda_out(sda_out),
    .sda_in(sda_in)
    );       
endmodule