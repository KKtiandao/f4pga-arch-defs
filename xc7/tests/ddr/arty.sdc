create_clock -period 2.5 sys4x_clk__main_clkout_buf1 -waveform {0.000 1.250}
#create_clock -period 2.5 sys4x_clkb__main_clkout_buf4 -waveform {0.000 1.250}
create_clock -period 2.5 sys4x_dqs_clk__main_clkout_buf2 -waveform {0.625 1.875}
create_clock -period 5 main_clkout_buf3__clk200_clk -waveform {0.000 2.500}

create_clock -period 10 clk100 -waveform {0.000 5.000}
create_clock -period 10 builder_pll_fb -waveform {0.000 5.000}

create_clock -period 20 main_clkout0 -waveform {0.000 10.000}
create_clock -period 20 sys_clk__main_clkout_buf0 -waveform {0.000 10.000}
create_clock -period 2.5 main_clkout1 -waveform {0.000 1.250}
create_clock -period 2.5 main_clkout2 -waveform {0.625 1.875}
create_clock -period 6 main_clkout3 -waveform {0.000 2.500}
