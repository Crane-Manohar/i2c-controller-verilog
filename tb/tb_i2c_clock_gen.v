`timescale 1ns / 1ps

module tb_i2c_clk_gen;

    // Testbench registers to drive UUT inputs
    reg clk;
    reg rst_n;
    reg enable;

    // Testbench wires to monitor UUT outputs
    wire scl;
    wire tick;

    // Instantiate Unit Under Test (UUT)
    i2c_clk_gen uut (
        .clk    (clk),
        .rst_n  (rst_n),
        .enable (enable),
        .scl    (scl),
        .tick   (tick)
    );

    // 50 MHz Clock Generator (10 ns LOW, 10 ns HIGH)
    initial begin
        clk = 1'b0;
    end
    always #10 clk = ~clk;

    // Stimulus Process
    initial begin
        // Setup GTKWave dump file
        $dumpfile("tb_i2c_clk_gen.vcd");
        $dumpvars(0, tb_i2c_clk_gen);

        // Assert Reset at t = 0
        rst_n  = 1'b0;
        enable = 1'b0;

        // Hold reset for 50 ns
        #50;
        rst_n  = 1'b1;

        // Enable clock generator
        #20;
        enable = 1'b1;

        // Run simulation for 30 microseconds (3 full 100 kHz SCL periods)
        #30000;

        $display("Simulation complete. Open tb_i2c_clk_gen.vcd in GTKWave!");
        $finish;
    end

endmodule  