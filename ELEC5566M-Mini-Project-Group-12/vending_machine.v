//  Author:  Saaduddin Syed //


module vending_machine(

	input clk,				//Assigning board clock, 50Mhz
	input reset,			//Reset Button
	input pence_20,		//20 pence
	input pound,			//100 pence = 1 pound
	input [4:0] select,	//select the items/product, machine will have 6 items to select.
								//And this trays will have 5 items
	input [4:0]load,		//restock the trays in the vending machine
	input buy,				//purchase the items if vending machine gets enough amount
	
	output reg [4:0] products=0,		//Product that will be dispensed
												/* [1] 60p for Bottle of water
													[2] 80p for Chocolate Bar
													[3]100p for Can of Fizzy Drink
													[4]120p for Crisps
													[5]200p for Sandwich*/
	output reg [11:0] money=0,				//output change from the machine, return if extra amount is given
	output reg [4:0] out_of_stock=0);	//when machine is out of stock. Machine will start with quantity 5 per tray
	
	
	reg pence_20_count, pound_count;	//store the value of the money
	reg buy_count;
	//intial stock in the vending machine
	reg [3:0] stock0=4'b0101;	//Each tray will have 5 items, product [0] Bottle of Water 		=  60 pence
	reg [3:0] stock1=4'b0101;	//Each tray will have 5 items, product [1] Chocolate Bar 		=  80 pence
	reg [3:0] stock2=4'b0101;	//Each tray will have 5 items, product [2] Can of Fizzy Drink 	= 100 pence
	reg [3:0] stock3=4'b0101;	//Each tray will have 5 items, product [3] Crisps 					= 120 pence
	reg [3:0] stock4=4'b0101;	//Each tray will have 5 items, product [4] Sandwich 				= 200 pence
	
	always@(posedge clk)		//Rising edge of the clk will look for rising edge in the coder
	begin
		pence_20_count <= pence_20;	//At the end of clock pence_20_count is taking value of pence_20 
		pound_count <= pound;			//At the end of clock pound_count is taking value of pound
		buy_count <= buy;					//At the end of clock buy_count is taking value of buy
		//Above 3 lines are basically taking the value of the input which was given by the user like a flip-flop
		
		if (reset==1)		//This section run when the rest is triggered
			
			money<=1'b0;	//This makes the value of money zero(reset)
			
		else if (pence_20_count == 1'b0 && pence_20 == 1'b1)	//run when the previous count of 20 pence is zero and and the current input is high
			
			money <= money + 12'd20;									//adds 20 pence to the money
			
		else if (pound_count == 1'b0 && pound == 1'b1)			//run when the previous count of pound is zero and and the current input is high
			
			money <= money + 12'd100;									//adds 100 pence to the money
				
		else if (buy_count == 1'b0 && buy == 1'b1)				//when user trigger buy and the previous value is low 
		
		//Selecting Products bellow
		
		case(select)
		
		5'b00001:	//Buy a Bottle of Water
		
			if	(money >= 12'd60 && stock0>0)
				begin
					products[0] <= 1'b1;			//Bottle of water is despensed if the above case is met
					stock0 <= stock0 - 1'b1;	//We have one less product in stock
					money <= money - 12'd60;	//Money is taken by the machine
				end
				
		5'b00010:	//Buy a Chocolate Bar
		
			if	(money >= 12'd80 && stock1>0)
				begin
					products[1]  <= 1'b1;		//Chocolate Bar is despensed if the above case is met
					stock1 <= stock1 - 1'b1;	//We have one less product in stock
					money <= money - 12'd80;	//Money is taken by the machine
				end
				
		5'b00100:	//Buy a Can of Fizzy Drink
		
			if	(money >= 12'd100 && stock2>0)
				begin
					products[2] <= 1'b1;			//Can of Fizzy Drink is despensed if the above case is met
					stock2 <= stock2 - 1'b1;	//We have one less product in stock
					money <= money - 12'd100;	//Money is taken by the machine
				end
							
		5'b01000:	//Buy Crisps
		
			if	(money >= 12'd120 && stock3>0)
				begin
					products[3] <= 1'b1;			//Crisps is despensed if the above case is met 
					stock3 <= stock3 - 1'b1;	//We have one less product in stock
					money <= money - 12'd120;	//Money is taken by the machine
				end
					
		5'b10000:	//Buy a Sandwich
		
			if	(money >= 12'd200 && stock4>0)
				begin
					products[4] <= 1'b1;			//Sandwich is despensed if the above case is met
					stock4 <= stock4 - 1'b1;	//We have one less product in stock
					money <= money - 12'd200;	//Money is taken by the machine
				end
				
			endcase				
						
		//If the buy button is not hit and the buy count is zero
		
				else if (buy_count == 1'b1 && buy == 1'b0)
				begin
					products[0] <= 1'b0;
					products[1] <= 1'b0;
					products[2] <= 1'b0;
					products[3] <= 1'b0;
					products[4] <= 1'b0;
				end
			
		//If the vending machin runs out of stock ,[5:0] out of stock led goes high
				else begin
					if	(stock0 == 4'b0000)			//If the bottle of water is out of stock
						out_of_stock[0] <= 1'b1;	//LED will light up if out of stock 
					else 
						out_of_stock[0] <= 1'b0;	//LED is off if the product is in stock
						
					if	(stock1 == 4'b0000)			//If the chocolate bar is out of stock
						out_of_stock[1] <= 1'b1;	//LED will light up if out of stock 
					else 
						out_of_stock[1] <= 1'b0;	//LED is off if the product is in stock
						
					if	(stock2 == 4'b0000)			//If the can of fizzy drink is out of stock
						out_of_stock[2] <= 1'b1;	//LED will light up if out of stock 
					else 
						out_of_stock[2] <= 1'b0;	//LED is off if the product is in stock	

					if	(stock3 == 4'b0000)			//If the crisps out of stock
						out_of_stock[3] <= 1'b1;	//LED will light up if out of stock 
					else 
						out_of_stock[3] <= 1'b0;	//LED is off if the product is in stock

					if	(stock4 == 4'b0000)			//If the sandwich is out of stock
						out_of_stock[4] <= 1'b1;	//LED will light up if out of stock 
					else 
						out_of_stock[4] <= 1'b0;	//LED is off if the product is in stock
					
					case(load)
						
						5'b00001:	stock0<=4'b0101;//Restock it to 5
						5'b00010:	stock1<=4'b0101;//Restock it to 5
						5'b00100:	stock2<=4'b0101;//Restock it to 5
						5'b01000:	stock3<=4'b0101;//Restock it to 5
						5'b10000:	stock4<=4'b0101;//Restock it to 5
						
					endcase
				end
			end 
endmodule
	
