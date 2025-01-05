module i2c_master(
    input clk,
    input rst,
    input load,
    input read_write_bit,
    input sda_in,
    input [7:0]device_address,
    input [7:0]register_address,
    input [7:0]data,
    output logic sda_out_en,
    output logic scl,
    output logic sda_out
);

logic [2:0] bit_cnt;
logic [7:0] a;
logic [7:0] b;
logic [7:0] c;
logic rece;
/* verilator lint_off UNUSED */
logic [7:0] received_data_slave;

typedef enum logic[3:0] {IDLE, START, SLAVE_ADDRESS,RW,ACK,ADDRESS,ACK2,DATA,ACK3,STOP} state_type;
state_type state, next_state;

always_ff @(posedge clk ) begin
    if (~rst) begin
        a <= 8'b0;
        b <= 8'b0;
        c <= 8'b0;
        bit_cnt <= 3'h0;
        state <= IDLE;
    end else begin
        state <= next_state;
        if (state == START) begin
            a <= device_address;
            b <= register_address;
            c <= data;
            bit_cnt <= 3'h0;
        end else if (state == SLAVE_ADDRESS) begin
            a <= {a[6:0], 1'b0};
            bit_cnt <= bit_cnt + 1'b1;
        end
        else if (state == ADDRESS) begin
             b <= {b[6:0], 1'b0};
             bit_cnt <= bit_cnt + 1'b1;
         end
        else if (state == DATA) begin
            received_data_slave <= {received_data_slave[6:0], sda_in};
            c<= {c[6:0], 1'b0};
            bit_cnt <= bit_cnt + 1'b1;
                if (&bit_cnt) begin
                rece <= 0;
            end
         end
     end
end

always_comb begin
    if(~rst) begin
        sda_out = 1;
    end else if(state == START) begin
        sda_out = 0;
    end else if(state == SLAVE_ADDRESS) begin
        sda_out = a[7];
    end
    else if(state == RW) begin
        sda_out = sda_out_en;
    end 
    else if(state == ADDRESS) begin
            sda_out = b[7];
    end
    else if(state == DATA && ~read_write_bit ) begin
            sda_out = c[7];
    end
    else if(state == ACK3) begin
            sda_out = rece;
    end
    else if(state == STOP) begin
            sda_out = 0;
    end
    else begin
        sda_out = 1;
    end
end

always_comb begin
    if(state == IDLE || state == STOP) begin
        scl = 1;
    end 
    else begin
        scl = clk;
    end
end

assign  sda_out_en =read_write_bit;

always_comb begin
    case(state)
        IDLE: if (load) next_state = START;
        START: if (~sda_out) next_state = SLAVE_ADDRESS;
        SLAVE_ADDRESS: if (&bit_cnt) next_state = RW;
        RW: if (sda_out_en || ~sda_out_en) next_state = ACK;
        ACK : if(~sda_in)next_state = ADDRESS;else next_state= IDLE;
        ADDRESS : if (&bit_cnt) next_state =ACK2;
        ACK2 : if (~sda_in) next_state =DATA;else next_state= IDLE;
        DATA : if (&bit_cnt) next_state = ACK3;
        ACK3 : if (~sda_out) next_state = STOP;else next_state= IDLE;
        STOP : next_state = IDLE;         
        default: next_state = IDLE;
    endcase
end

endmodule