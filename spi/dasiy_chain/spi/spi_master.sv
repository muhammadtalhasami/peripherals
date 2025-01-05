// -----------------------------------------MASTER---------------------------------------------------------------------------
module spi_master(
    input logic clk,
    input logic rst,
    input logic load_m,
    input logic [7:0] data,
/* verilator lint_off UNUSED */
    input logic miso,
    input logic [1:0] mode,
    input logic [1:0] chip_sel,
    output logic sclk,
    output logic mosi,
    output logic [1:0]ss
);

logic [7:0] a;
logic [2:0] bit_cnt;
logic cpol;
logic cpha;

typedef enum logic [1:0] {IDLE, LOAD, DATA_TRANSMIT} state_type;
state_type state, next_state;

always_ff @(posedge clk ) begin
    if (~rst) begin
        a <= 8'b0;
        bit_cnt <= 3'h0;
        state <= IDLE;
    end else begin
        state <= next_state;
        if (state == LOAD) begin
            a <= data;
            bit_cnt <= 3'h0;
        end else if (state == DATA_TRANSMIT) begin
            a <= {a[6:0], 1'b0};
            bit_cnt <= bit_cnt + 1'b1;
        end
    end
end

always_comb begin
    if (state == IDLE) begin
        sclk = mode[1];
    end 
    else if (state == DATA_TRANSMIT&& mode == 2'b00) begin
        sclk = ~clk;
    end
    else if (state == DATA_TRANSMIT&& mode == 2'b01) begin
        sclk = clk;
    end
    else if (state == DATA_TRANSMIT&& mode == 2'b10) begin
        sclk = ~clk;
    end
    else if (state == DATA_TRANSMIT&& mode == 2'b11) begin
        sclk = clk;
    end
    else begin
        sclk = mode[1];
    end
end

assign cpol = mode[1];
assign cpha = mode[0];

assign ss =   (state == DATA_TRANSMIT) ? chip_sel : 1;
assign mosi = (state == DATA_TRANSMIT) ? a[7] : 1'b0;

always_comb begin
    case (state)
        IDLE: if (load_m) next_state = LOAD;
        LOAD: next_state = DATA_TRANSMIT;
        DATA_TRANSMIT: if (&bit_cnt) next_state = IDLE;
        default: next_state = IDLE;
    endcase
end

endmodule


