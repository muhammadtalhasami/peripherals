module spi_top(
    input clk,
    input rst,
    input [7:0] data_m,
    input [7:0] data_s,
    input [1:0] mode_s,
    input [1:0] chip_selection,
    input load
);

logic mosi;
logic miso_0;
logic miso_1;
logic miso_2;
logic [1:0] ss;
logic sclk;


spi_master u_spi_master0 (
    .clk(clk),
    .rst(rst),
    .mosi(mosi),
    .miso(miso_2),        
    .mode(mode_s),
    .load_m(load),
    .ss(ss),
    .chip_sel(chip_selection),
    .data(data_m),
    .sclk(sclk)
);


spi_slave u_spi_slave0 (
    .clk(clk),
    .rst(rst),
    .mosi(mosi),
    .miso(miso_0),
    .ss(ss == 2'b00 ? 0 : 1),
    .data_slv(data_s),
    .sclk(sclk)
);


spi_slave u_spi_slave1 (
    .clk(clk),
    .rst(rst),
    .mosi(miso_0),
    .miso(miso_1),
    .ss(ss == 2'b11 ? 0 : 1),
    .data_slv(data_s),
    .sclk(sclk)
);

spi_slave u_spi_slave2 (
    .clk(clk),
    .rst(rst),
    .mosi(miso_1),
    .miso(miso_2),
    .ss(ss == 2'b10 ? 0 : 1),
    .data_slv(data_s),
    .sclk(sclk)
);

endmodule
