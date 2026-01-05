//  Author: Harini Nagarathinam, Shikha Tripathi //


module seven_segment_display_controller (
    input clock, 
    input reset,
	 input [4:0]select,
	 input buy,
	 input [7:0] price,
	 input [11:0]moneyIn,
	 output reg [4:0] ledOutput,
	 input [11:0]change,
	 input stock,
	 output reg [2:0]scrollMode,
	 output reg showMoney,
	 output reg [11:0]amountDisplay
); 

reg [2:0] state; //State-Machine Registers
reg [27:0] timer; //timer
reg buyPrev;
reg c;
reg enjoyShown;
reg [11:0] changeBuffer;

//Local Parameters used to define state names (similar to #define in C)
localparam idle = 3'b000;            // waiting for money
localparam productSelected = 3'b001; // Product selected
localparam moneyInserted = 3'b010;   // money inserted 
localparam returnChange = 3'b011;    // Returning change
localparam itemDispense = 3'b100;    //  dispensing product
localparam outOfStock = 3'b101;      // Out of stock

//Timer delay
localparam delay5  = 28'd250_000_000;
localparam delay1  = 28'd50_000_000;

always @(posedge clock or posedge reset) begin
    if (reset)
        buyPrev <= 0;
    else
        buyPrev <= buy;
end
wire buyEdge = buy && !buyPrev;

//State transition logic
always @(posedge clock or posedge reset) begin
    if (reset) begin
        //Reset the state machine
        state <= idle;
		  timer <= 0;
		  changeBuffer <= 0;
	          enjoyShown <=0;
    end else begin
	     case (state)
        idle: begin
		            enjoyShown <=0;
						if (buyEdge && (select != 5'b00000)) begin
		                timer <= 0;
							 changeBuffer <= 0;
							 state <= productSelected;
		            end  				  
	           end 
	     productSelected: begin
		                      if( select == 0)
									     state <= idle; // Back to idle, when item unselected
									 if(timer < delay1) begin
									     timer <= timer+1;
										  c <=0;
	                         end if( moneyIn >= price) begin
										  c<= 1;
										  timer <=0;
										  state <= moneyInserted;
								    end
								end
	     moneyInserted: begin
								 if( select == 0)
								     state <= idle; // Back to idle, when item unselected
								 else if( timer < delay5)
								     timer <= timer +1;
								 else begin
								     if(stock) begin // if out of stock, stock =1
									      timer <= 0;
									      state <= outOfStock;
									  end else if( moneyIn == price ) begin    // money is inserted
									      timer <= 0;
											state <= itemDispense;
								     end else if( moneyIn > price) begin
									      timer <=0;
						               state <= returnChange;
									  end
							    end		 
			              end	
        returnChange: begin
                      	  if(timer < delay1) begin
								      timer <= timer +1;
										changeBuffer <= (moneyIn - price);
								  end else begin
								      timer <= 0;
								      state <= itemDispense;
								  end
				          end				  
	     itemDispense: begin
								  if( timer < delay5) begin
								      timer <= timer+1;
								  end else begin
								      changeBuffer <= 0;
										state <= idle;
							     end
							 end
        outOfStock: begin
		                  if(timer < delay5)
								    timer <= timer+1;
								else
		                      state <= idle;
						  end
	     default: state=idle;
        endcase
    end
end

always @(*) begin
    scrollMode = 3'd0;
	 showMoney = 1'b0;
	 amountDisplay = 12'd0;
    case (state)
        idle: begin
       		      scrollMode = (select ==0)?3'd0:3'd1;
					end
        productSelected: begin
		                     if((timer < delay1) && (c <1)) begin
									    scrollMode = 3'd1;
					    				 ledOutput = 5'b11111;
										 showMoney=0;
										 amountDisplay=0;
									end else begin
									    scrollMode = 3'd0;
										 showMoney=1;
										 amountDisplay=moneyIn;
									end
							  end	
        moneyInserted: begin
		                       showMoney=1;
									  amountDisplay=moneyIn;
								 end
        itemDispense: begin
								      scrollMode=3'd4; //Enjoy
								      showMoney =0;
							 end
        returnChange: begin
		                    showMoney=1;
								  amountDisplay=changeBuffer;
							 end
        outOfStock: begin
		                  scrollMode=3'd3;
								showMoney=0;
						  end
    endcase
end

endmodule
