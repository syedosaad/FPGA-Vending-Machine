module servo_motor_1 (
    input wire clk,  
    input wire rst, 
    input wire [7:0] angle_input, //it's an 8-bit wide signal, carrying 8 bits of data signals simultaneously (representing values from 0 to 255).
    output reg servo_out 
);

    parameter CLK_FREQ = 50000000; // 50 MHz
    parameter PWM_PERIOD_MS = 20;  // 20ms period
    
    // Fixed pulse width values
    parameter MIN_PULSE_CYCLES = 50000;  // 1ms at 50MHz
    parameter MAX_PULSE_CYCLES = 100000; // 2ms at 50MHz
    
    localparam PWM_PERIOD_CYCLES = (CLK_FREQ / 1000) * PWM_PERIOD_MS; // 1,000,000 cycles
    
    reg [31:0] counter;
    reg [31:0] pulse_width_cycles;

    // Simple linear mapping from angle_input to pulse width
    always @(*) begin
        // First multiply by range then divide to avoid truncation issues
        // This calculation is simpler and more synthesis-friendly
        pulse_width_cycles = MIN_PULSE_CYCLES + (((MAX_PULSE_CYCLES - MIN_PULSE_CYCLES) * angle_input) / 255);
    end
// Counter logic - fix reset edge detection
always @(posedge clk or negedge rst) begin  // Changed to negedge
    if (!rst) begin                         // Keep condition as is (active-low)
        counter <= 0;
    end else begin
        if (counter >= PWM_PERIOD_CYCLES - 1)
            counter <= 0;
        else
            counter <= counter + 1;
    end
end

// Generate PWM signal - fix reset edge detection 
always @(posedge clk or negedge rst) begin  // Changed to negedge
    if (!rst)                               // Keep condition as is (active-low)
        servo_out <= 0;
    else if (counter < pulse_width_cycles)
        servo_out <= 1;
    else
        servo_out <= 0;
end


endmodule 