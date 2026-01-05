// Author Harini Nagarathinam
`timescale 1 ns/1 ps
module TopModule_tb;

//Test bench generated signals
reg clock;
reg [3:0]key;
reg [9:0]switch;

//Dut Output signals
wire [9:0]led;

//DUT
top_module topModule_dut(
    .CLOCK_50(clock),
	 .KEY(key),	   
	 .SW(switch),		
	 .LEDR(led)
);

always #10 clock = ~clock;

initial begin
    $display("\n Top module test bench");
	 
	 //Initialise
	 clock = 0;
	 key = 4'b1111;
	 switch = 10'b0;
	 
    $display("Test 1 - Reset");
    #20 key[0] = 0; 
	 #20 key[0] = 1;  
    if (led == 10'b0)
        $display("Pass - Reset cleared all outputs");
    else
        $display("Fail ");

    $display("Test 2 - Insert 1 pound");
    #20 key[3] = 0; 
	 #20 key[3] = 1;
    if (led[9:5] == 5'd4)  // Check lower 5 bits of 100p
        $display("Pass");
    else
      $display("Fail");

    $display("Test 3 - Buy Chocolate (80p)");
    switch[4:0] = 5'b00010;
    #20 key[1] = 0; 
	 #20 key[1] = 1;
    if (led[1] == 1'b1)
        $display("Pass - Chocolate dispensed");
    else
        $display("Fail");

    $display("Test 4 - Buy Sandwich with insufficient money");
    switch[4:0] = 5'b10000;
    #20 key[1] = 0; 
	 #20 key[1] = 1;
    #80;
    if (led[4] == 1'b1)
        $display("Fail");
    else
        $display("Pass");

    #20 key[3] = 0; 
	 #20 key[3] = 1;
    #20 key[3] = 0; 
	 #20 key[3] = 1; //Inserted 2 pounds
    $display("Test 5 - Buy Sandwich");
    switch[4:0] = 5'b10000;
    #20 key[1] = 0; 
	 #20 key[1] = 1;
    #100;
    if (led[4] == 1'b1)
        $display("Pass - Sandwich dispensed");
    else
        $display("Fail");
    $display("\nAll tests complete");
	 $finish;
  end
endmodule