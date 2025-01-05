//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2024 04:48:32 AM
// Design Name: 
// Module Name: i2c_slave
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


module i2c_slave(
input clk,
input rst,
/* verilator lint_off UNUSED */
input sda_out_en,
input scl,
input sda_out,
output logic sda_in
    );
    
 localparam [7:0]slave_address = 8'h02;
 logic [2:0] bit_cnt;
 logic [7:0] register[0:255];
 logic [7:0] received_address;
 /* verilator lint_off UNOPTFLAT */
 logic read_write;
 logic [7:0]register_address;
 logic [7:0]b;
 logic rece;
 logic [7:0]data_out;
 logic [7:0]data_in;

  typedef enum logic[3:0]{IDLE,START,SLAVE_ADDRESS,RW,ACK,ADDRESS,ACK2,DATA,ACK3,STOP} state_type;
  state_type state,next_state;
  
  always_ff @(posedge clk) begin
       if (~rst) begin
           state <= IDLE;
           received_address <= 8'b0;
           bit_cnt <= 3'b0;
       end else begin
           state <= next_state;
           if (state == SLAVE_ADDRESS) begin
               received_address <= {received_address[6:0], sda_out};
               bit_cnt <= bit_cnt + 1'b1;
           end
           else if (state == ADDRESS) begin
               b <= {b[6:0], sda_out};
               bit_cnt <= bit_cnt + 1'b1;
                if (&bit_cnt) begin
                    rece <= 0;
                end
           end
           else if (state == DATA && ~read_write) begin
                data_in <={data_in[6:0],sda_out} ;
                bit_cnt <= bit_cnt + 1'b1;
           end
       end
   end
   
   assign register_address = b;

   integer i;   
    always_ff @(posedge clk) begin
        if (~rst) begin
        // Reset the register array
        for (i = 0; i < 32; i++) begin
            register[i] <= 8'b0;
        end 
        end
       else if (state == ACK2 && read_write) begin
           data_out<= register[register_address];
        end
       else if (state == DATA && read_write) begin
            data_out<= {data_out[6:0],1'b0};
            bit_cnt <= bit_cnt + 1'b1;
         end
    end
  
   always_comb begin
       if(~rst)begin
          sda_in = 1 ;
      end
      else if(received_address ==slave_address && state == ACK)begin
         sda_in = 0;
      end
      else if(state == ACK2)begin
         sda_in = rece;
      end
      else if(state == DATA && read_write)begin
         sda_in = data_out[7];
      end
      else if(state == RW)begin
/* verilator lint_off ALWCOMBORDER */
          read_write = sda_out;
      end
      else if (state == ACK3) begin
         register[register_address] = data_in;  
      end
      else begin
         sda_in = 1;
      end
  end
  
    always_comb begin
      case(state)
          IDLE : next_state = START;
          START : if (~sda_out)next_state = SLAVE_ADDRESS;
          SLAVE_ADDRESS : if (&bit_cnt) next_state = RW;
          RW : if (sda_out || ~sda_out) next_state = ACK;
          ACK : if(~sda_in)next_state = ADDRESS;else next_state= IDLE;
          ADDRESS : if (&bit_cnt) next_state =ACK2;
          ACK2 : if (~sda_in) next_state =DATA;else next_state= IDLE;
          DATA : if (&bit_cnt) next_state = ACK3;
          ACK3 : if (~sda_out) next_state = STOP;else next_state= IDLE;
          STOP : next_state = IDLE;    
          default  : next_state = IDLE;
      endcase
   end
 

endmodule

// typedef enum logic[3:0]{IDLE,START,SLAVE_ADDRESS,RW,ACK,ADDRESS,ACK2,DATA,ACK3,STOP} state_type;
// state_type state,next_state;
 
//always_ff @(posedge clk) begin
//     if (~rst) begin
//         state <= IDLE;
//         received_address <= 8'b0;
//         bit_cnt <= 3'b0;
//     end else begin
//         state <= next_state;
//         if (state == SLAVE_ADDRESS) begin
//             received_address <= {received_address[6:0], sda_out};
//             bit_cnt <= bit_cnt + 1'b1;
//         end 
//         else if (state == ADDRESS) begin
//             register_address <= {register_address[6:0], sda_out};
//             bit_cnt <= bit_cnt + 1'b1;
//         end
//         else if (state == DATA) begin
//             if(sda_out)begin
//                 data_out<= register[register_address];
//                 bit_cnt <= bit_cnt + 1'b1;
//             end
//         end 
//     end
// end
 
// integer i;
 
// always_ff @(posedge clk) begin
//     if (~rst) begin
//         // Reset the register array
//         for (i = 0; i < 32; i++) begin
//             register[i] <= 32'b0;
//         end 
//     end
//     else if (state == DATA && ~sda_out) begin
//                 register[register_address] <= data_in;
//                 bit_cnt <= bit_cnt + 1'b1;
//     end
////     else begin
////                 if (state == ADDRESS && read_write) begin
////                 data_out<= register[register_address];
////                 bit_cnt <= bit_cnt + 1'b1;
////             end
////         end
// end
 
// always_comb begin
//     if(~rst)begin
//         sda_in = 1 ;
//     end
//     else if(received_address ==slave_address && state == ACK)begin
//         sda_in = 0;
//     end
//     else if(state == DATA && sda_out)begin
//         sda_in = data_out[7];
//     end
//     else if(state == ACK2 || state == ACK3)begin
//         sda_in = 0;
//     end
//     else begin
//         sda_in = 1;
//     end
// end
 
//  always_comb begin
//    case(state)
//        IDLE : if (scl) next_state = START;
//        START : if (~sda_out)next_state = SLAVE_ADDRESS;
//        SLAVE_ADDRESS : if (&bit_cnt) next_state = RW;
//        RW : if (sda_out || ~sda_out) next_state = ACK;
//        ACK : if (~sda_in) next_state = ADDRESS;
//        ADDRESS : if (&bit_cnt) next_state = ACK2;
//        ACK2 : if (~sda_in) next_state = DATA;
//        DATA : if (&bit_cnt) next_state = ACK3;
//        ACK3 : if (~sda_in) next_state = STOP;
//        STOP : next_state = IDLE;
//        default  : next_state = IDLE;
//    endcase
// end
    