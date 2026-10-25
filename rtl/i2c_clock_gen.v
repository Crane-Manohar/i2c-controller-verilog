module i2c_clk_gen (
    // Inputs
    input  wire clk,      // 50 MHz system clock
    input  wire rst_n,    // Active-low asynchronous reset
    input  wire enable,   // Enable signal to run the divider

    // Outputs driven by sequential logic
    output reg  scl,      // Generated 100 kHz I2C clock
    output reg  tick      // Quarter-cycle strobe pulse (4x per SCL period)
);

    // Internal 9-bit register to hold the 0-499 count
    reg [8:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 9'd0;
            scl   <= 1'b1;
            tick  <= 1'b0;
        end else if (enable) begin
            // 1. Counter update logic
            if (count == 9'd499) begin
                count <= 9'd0;
            end else begin
                count <= count + 1'b1;
            end

            // 2. SCL clock generation (High for first half, Low for second half)
            if (count < 9'd250) begin
                scl <= 1'b1;
            end else begin
                scl <= 1'b0;
            end

            // 3. Tick strobe generation (Pulse High for 1 clock cycle at quarter-points)
            if (count == 9'd124 || count == 9'd249 || count == 9'd374 || count == 9'd499) begin
                tick <= 1'b1;
            end else begin
                tick <= 1'b0;
            end
        end else begin
            // Resting state when enable is LOW
            count <= 9'd0;
            scl   <= 1'b1;
            tick  <= 1'b0;
        end
    end

endmodule