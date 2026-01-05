// Author Harini Nagarathinam
`timescale 1 ns/1 ps
module SSDController_tb;

//Test bench generated signals
reg clock, reset, buy, stock;
reg [4:0] select;
reg [7:0] price;
reg [11:0] moneyIn, change;

//Dut Output signals
wire [2:0] scrollMode;
wire showMoney;
wire [11:0] amountDisplay;

//DUT
seven_segment_display_controller ssdController_dut(
    .clock(clock),
    .reset(reset),
    .select(select),
    .moneyIn(moneyIn),
    .price(price),
    .buy(buy),
    .change(change),
	 .stock(stock),
    .scrollMode(scrollMode),
    .showMoney(showMoney),
    .amountDisplay(amountDisplay)
);

//Clock generation
always #10 clock = ~clock; //50MHz

initial begin
    $display ("\n SSD Controller Testbench");
	 
	 //Initialise 
	 clock = 0;
	 reset = 1;
	 buy = 0;
	 select = 0;
	 price = 0;
	 moneyIn = 0;
	 change = 0;
	 stock = 4;
	 
	 #20 reset = 0;
	 
	 $display("Test 1 - buy with no selection");
	 #20 buy = 1;
	 #20 buy = 0;
	 if (scrollMode != 3'd0)
	     $display("Fail");
	 else
	     $display("Pass");
		  
	 $display("\nTest 2 - exact payment, no change");
	 #20 select = 5'b00001; 
	     price = 8'd100;
		  moneyIn = 12'd100;
		  buy =1;
	 #20 buy =0;
	 if(amountDisplay !== 12'd100 || showMoney !== 1)
	     $display("Fail");
	 else
	     $display("Pass");
		  
	 $display("\nTest 3 - Under payment");
	 #20 moneyIn = 8'd60;
	     buy = 1;
	 #20 buy = 0;
	 if(scrollMode !== 3'd0 && showMoney==1)
	     $display("Fail");
	 else
	     $display("Pass");
		  
	 $display("\nTest 5 - Out of stock");
	 #20 stock = 0;
	     moneyIn = 12'd100;
		  price = 8'd100;
		  buy = 1;
	 #20 buy = 0;
	 #500;
	 if( scrollMode == 3'd3)
	     $display("Pass ");
	 else
	     $display("Fail ");
		  
	 $display("\nTest 6 - Reset mid way");
	 #20 moneyIn = 80;
	     stock = 1;
		  buy = 1;
	 #20 reset = 1;
	 #20 reset = 0;
	 if(scrollMode !== 3'd1)
	     $display("Fail");
	 else
	     $display("Pass");
	 
	 $display("\nAll tests complete");
	 $finish;
  end
endmodule