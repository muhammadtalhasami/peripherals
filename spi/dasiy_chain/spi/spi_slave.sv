// --------------------------------SLAVE------------------------------------------------------------------------------------

module spi_slave(
    input logic clk,
    input logic rst,
    input logic [7:0] data_slv,
/* verilator lint_off UNUSED */
    input logic sclk,
    input logic ss,
    input logic mosi,
    output logic miso
);

logic [7:0] b;
logic [2:0] bit_cnt_s;

typedef enum logic [1:0] {IDLE, LOAD, DATA_TRANSMIT} state_type;
state_type state, next_state;

always_ff @(posedge clk) begin
    if (~rst) begin
        b <= 8'b0;
        bit_cnt_s <= 3'h0;
        state <= IDLE;
    end else begin
        state <= next_state;
        if (state == LOAD) begin
            b <= data_slv;
            bit_cnt_s <= 3'h0;
        end else if (state == DATA_TRANSMIT) begin
            b <= {b[6:0], 1'b0};
            bit_cnt_s <= bit_cnt_s + 1'b1;
        end
    end
end

always_comb begin
    if(state == IDLE && ss)begin
        miso = mosi;
    end
    else if (state == DATA_TRANSMIT)begin
        miso = b[7];
    end
end

// assign miso = (state == DATA_TRANSMIT && ~ss) ? miso_internal :
//               (state == IDLE && ss) ? mosi :  0;

always_comb begin
    next_state = state;
    case (state)
        IDLE: if (~ss) next_state = LOAD;
        LOAD: next_state = DATA_TRANSMIT;
        DATA_TRANSMIT: if (&bit_cnt_s) next_state = IDLE;
        default: next_state = IDLE;
    endcase
end

endmodule