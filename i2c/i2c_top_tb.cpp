#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vi2c_top.h"

vluint64_t sim_time = 0;

void read_values(Vi2c_top* dut) {
    if (sim_time == 0 && sim_time < 5) {
        dut->clk = 0;
        dut->rst = 0;
    } else if (sim_time >= 5) {
        dut->rst = 1;
    }
    if (sim_time == 7) {
        dut->r_w = 0;
        dut->load = 1;
        dut->slave_address = 2;
        dut->register_address = 2;
        dut->data  = 3;
    } 
    if (sim_time == 70) {
        dut->r_w = 1;
    } 
}

int main(int argc, char** argv, char** env) {
    Vi2c_top* dut = new Vi2c_top;

    Verilated::traceEverOn(true);
    VerilatedVcdC* m_trace = new VerilatedVcdC;
    dut->trace(m_trace, 99); // Trace 99 levels of hierarchy
    m_trace->open("waveform.vcd");

        dut->clk = 0;
        dut->rst = 0;

    while (sim_time <= 500) {
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