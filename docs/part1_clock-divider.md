# Step 1: Clock Divider & Timing Generator

## 1. Objective
Design a clock divider module (`i2c_clk_gen.v`) that converts a fast 50 MHz system clock ($f_{clk}$) into precise timing pulses to drive a 100 kHz I2C clock ($SCL$).

- **Why?**
  I2C peripherals communicate at much lower speeds than physical microcontrollers, so a clock divider allows the high-speed system to control low-speed bus traffic synchronously without needing an external clock
---

## 2. Specification & Mathematics
- **System Clock ($f_{clk}$)**: 50 MHz ($T_{clk} = 20\text{ ns}$)
- **Target I2C Speed ($f_{scl}$)**: 100 kHz ($T_{scl} = 10\,\mu\text{s}$)

### Cycle Calculation
$$\text{Cycles per } SCL \text{ period} = \frac{50,000,000\text{ Hz}}{100,000\text{ Hz}} = 500\text{ system clock cycles}$$


### Counter Bit-Width Calculation
To count 500 states (counting from $0$ to $499$):
$$2^N \ge 500 \implies N = 9\text{ bits } (2^9 = 512)$$
- Counter register definition: `reg [8:0] count`



---

## 3. Timing Strategy (4 Ticks per SCL Period)
Instead of generating a simple toggling clock, the module generates 4 single-cycle tick pulses every 125 system clock cycles ($500 / 4 = 125$):

1. **Tick 1 (Q1)**: SCL High center
   - **Why?** $SCL$ is stable HIGH here, making it the safest time to sample incoming data from the $SDA$ line without line transition noise.
2. **Tick 2 (Q2)**: SCL High-to-Low transition
   - **Why?** Marks the start of the clock's falling edge, signaling the state machine that $SCL$ is preparing to go LOW.
3. **Tick 3 (Q3)**: SCL Low center
   - **Why?** According to I2C specifications, data on $SDA$ is only allowed to change while $SCL$ is LOW. Changing data at the center of the LOW period ensures maximum setup time before $SCL$ rises again.
4. **Tick 4 (Q4)**: SCL Low-to-High transition
   - **Why?** Marks the start of the clock's rising edge, signaling the master to release $SCL$ back HIGH.

- **Why 4 ticks instead of just outputting a 100 kHz clock?**
  I2C requires precise sub-cycle timing sequence control (e