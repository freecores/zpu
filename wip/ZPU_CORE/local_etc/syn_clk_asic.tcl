set clocks {clk}
set resets {areset}

create_clock [find port "clk"] -period 5.0 -name "clk"
set_clock_uncertainty 1.0 [find clock "clk"]

