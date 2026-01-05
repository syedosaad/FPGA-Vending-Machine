`timescale 1ns/1ps

module servo_motor_1_tb();


    reg clk;
    reg rst;
    reg enable_button;
    wire servo_out;
    
    // Instantiation of the Device Under Test 
    servo_motor_1 dut(
        .clk(clk),
        .rst(rst),
        .enable_button(enable_button),
        .servo_out(servo_out)
    );
    
    // Clock signal generation with 20ns period (50MHz frequency)
    always #10 clk = ~clk;
    
    initial begin
        // Initial conditions establishment
        clk = 0;
        rst = 0;  // Assert reset (active low)
        enable_button = 1;  // Button inactive (active low)
        
        // System reset procedure
        #100;  // Delay for system stabilization
        rst = 1;  // De-assert reset to enable normal operation
        #100;  // Allow sufficient time for reset recovery
        
        // Actuation of rotation mechanism via button press
        enable_button = 0;  // Button press assertion (active low)
        #100;  // Maintain button press for debounce period
        enable_button = 1;  // Button release
        
		   // Simulation duration servo dynamics
        #10000000; 
        
        $finish; // ensures the simulation stops properly
    end
endmodule