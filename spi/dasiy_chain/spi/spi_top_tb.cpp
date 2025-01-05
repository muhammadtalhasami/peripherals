#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vspi_top.h"

vluint64_t sim_time = 0;

void read_values(Vspi_top* dut) {
    if (sim_time == 0 && sim_time < 5) {
        dut->clk = 0;
        dut->rst = 0;
    } else if (sim_time >= 5 && sim_time< 10) {
        dut->rst = 1;
        dut->data_m = 3;
        dut->data_s = 2;
    }
    if (sim_time == 10) {
        dut->load = 1;
        dut->mode_s = 1;
        dut->chip_selection  = 0;
    } 
}

int main(int argc, char** argv, char** env) {
    Vspi_top* dut = new Vspi_top;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 99); // Trace 99 levels of hierarchy
    m_trace->open("waveform.vcd");

        dut->clk = 0;
        dut->rst = 0;

    while (sim_time <= 200) {
        dut->clk = !dut->clk;
        read_values(dut);
        dut->eval();
        m_trace->dump(sim_time);
        sim_time++;
    }

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}

        // clk = 0;
        // rst = 0;
        // #10;
        // data_m = 8'd3;
        // data_s = 8'd2;
        // rst = 1;
        // #10;
        // load=1'b1;
        // mode_s=2'b01;
        // chip_selection=2'b00;
        // #200;     
        // $finish;