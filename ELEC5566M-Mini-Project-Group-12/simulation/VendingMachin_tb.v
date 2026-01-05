// Author Harini Nagarathinam
`timescale 1 ns/1 ps
module VendingMachin_tb;

//Test bench generated signals
reg clock, reset,buy;
reg [4:0]select,load;
reg pence20,pound;

//Dut Output signals
wire [4:0] products;
wire [4:0] outOfStock;
wire [11:0] money;

//DUT
vending_machine vm_dut(
    .clk      (clock), 		
    .reset    (reset),		
    .pence_20 (pence20),	
    .pound    (pound),		
    .select   (select),		
    .load     (load),		
    .buy      (buy),			
    .products (products),		
    .money    (money),			
    .out_of_stock(outOfStock)
);

always #10 clock =~clock;

initial begin
    $display("\nVending Machine test bench");
	 
	 //Initialise
	 clock = 0;
	 reset = 1;
	 pence20 = 0;
	 pound = 0;
	 buy = 0;
	 select = 0;
	 load = 0;
	 
	 #20 reset = 0;
	 
	 $display("\nTest 1 - Insert 1 pound");
	 #20 pound = 1;
	 #20 pound = 0;
	 if(money==12'd100)
	     $display("Pass - Insertes 1pound");
	 else
	     $display("Fail");
	
	 $display("Test 2 - Insert 20p");
	 #20 pence20 = 1;
	 #20 pence20 = 0;
	 if(money==12'd120)
	     $display("Pass - Insertes 20p");
	 else
	     $display("Fail");  
		  
	 $display("Test 3 - Buy chocolate");
	 select = 5'b00010;
	 buy = 1;
	 #20 buy = 0;
	 if(products[1] == 1'b1)
	     $display("Pass - Item dispensed");
	 else
	     $display("Fail"); 
	 if(money == 12'd40)
	     $display("Correct change");
	 else
	     $display("Incorrect change");
	 
	 $display("Test 4 - Buy water with insufficient money");
	 select = 5'b00001;
	 buy = 1;
	 #20 buy = 0;
	 if(products[0] !== 1'b0)
	     $display("Fail - Item dispensed");
	 else
	     $display("Pass - item not dispensed"); 
	 
	 $display("Test 5 - Empty stock of Fizzy drink");
	 select = 5'b00100;
	 repeat (5) begin
	     #20 pound = 1;
		  #20 pound = 0;
		  #20 buy = 1;
		  #20 buy = 0;
	 end
	 #100;
	 if(outOfStock[2] == 1)
	     $display("Pass - Out of stock shown");
	 else
	     $display("Fail");
		  
	 $display("Test 6 - Restock of Fizzy drink");
	 load = 5'b00100;
	 #100;
	 if(outOfStock[2] == 0)
	     $display("Pass - Stock replenished");
	 else
	     $display("Fail");
		  
	 $display("Test 7 - System reset");
	 reset = 1; 
	 #20 reset = 0;
	 if(money == 0 || products == 0)
	    $display("Pass - System reset");
	 else
	     $display("Fail");
		  
	 $display("\nAll tests complete");
	 $finish;
  end
endmodule