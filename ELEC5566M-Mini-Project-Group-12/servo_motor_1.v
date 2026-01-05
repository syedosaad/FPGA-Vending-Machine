// Author Manyan Wong // 

module servo_motor_1 (
    input wire clk, // sets the clock speed
    input wire rst, // sets the reset switch
    input wire enable_button, // Button to trigger one rotation
    output reg servo_out // register for assigment pins
);

    parameter CLK_FREQ = 50000000; // 50 MHz system clock
    parameter PWM_PERIOD_MS = 20;  // 20ms PWM period (standard for servos)

    // Pulse widths for continuous rotation servo
    parameter ROTATE_PULSE_CYCLES = 100000; // 2ms at 50MHz (full speed one direction)
    parameter STOP_PULSE_CYCLES   = 75000;  // 1.5ms at 50MHz (stop/neutral position)

    localparam PWM_PERIOD_CYCLES = (CLK_FREQ / 1000) * PWM_PERIOD_MS; // 1,000,000 cycles for 20ms

    reg [31:0] counter;           // Counts clock cycles for PWM period
    reg [31:0] pulse_width_cycles;// Number of cycles for high pulse (controls speed/direction)
    reg [31:0] rotate_counter;    // Counts PWM periods during rotation
    reg rotating;                 // Indicates if servo should be rotating

    parameter ROTATE_PERIODS = 100; //PWM periods for one full rotation

    // Button press detection and rotation control
    reg prev_button; // Stores previous button state for edge detection
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            rotating <= 0;
            rotate_counter <= 0;
            prev_button <= 1'b1;
        end else begin
            prev_button <= enable_button;
            // Start rotation on button press (falling edge, active LOW)
            if (!rotating && prev_button == 1'b1 && enable_button == 1'b0) begin
                rotating <= 1;
                rotate_counter <= 0;
            end 
				
				
            // Count PWM periods while rotating
            else if (rotating && counter == PWM_PERIOD_CYCLES - 1) begin
                if (rotate_counter < ROTATE_PERIODS - 1)
                    rotate_counter <= rotate_counter + 1;
                else
                    rotating <= 0; // Stop after desired number of periods (one full rotation)
            end
        end
    end

    // Set pulse width: rotate or stop
    always @(*) begin
        if (rotating)
            pulse_width_cycles = ROTATE_PULSE_CYCLES; // Full speed (rotate)
        else
            pulse_width_cycles = STOP_PULSE_CYCLES;   // Stop (neutral)
    end

    // Counter logic for PWM period
    always @(posedge clk or negedge rst) begin
        if (!rst)
            counter <= 0;
        else if (counter >= PWM_PERIOD_CYCLES - 1)
            counter <= 0;
        else
            counter <= counter + 1;
    end

    // Generate PWM signal for servo
    always @(posedge clk or negedge rst) begin
        if (!rst)
            servo_out <= 1'b0;
        else if (counter < pulse_width_cycles)
            servo_out <= 1'b1;
        else
            servo_out <= 1'b0;
    end

endmodule