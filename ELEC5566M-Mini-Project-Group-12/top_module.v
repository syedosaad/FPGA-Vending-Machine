//  Author: Saaduddin Syed, Shikha Tripathi, Manyan Wong //



module top_module(
	
	input CLOCK_50,		// Clock input (50MHz)
	input [3:0] KEY,	// Pushbuttons (Intially LOW)
	input [9:0] SW,		// Switches (10 bits)
	output[9:0] LEDR,	// LEDs (10 bits)
	output [6:0] HEX0,       // 7-segment displays
	output [6:0] HEX1,
    output [6:0] HEX2,
	output [6:0] HEX3,
    output [6:0] HEX4,
	output [6:0] HEX5,
    output [15:0] LT24_DATA,
    output        LT24_WR_N,
    output        LT24_RD_N,
    output        LT24_CS_N,
    output        LT24_RS,
    output        LT24_RESET_N,
    output        LT24_LCD_ON,
    output        SERVO_OUT // output for servo motor
);

	// Key mappings
	wire reset		= ~KEY[0];	// Active LOW reset button
	wire buy	   	= ~KEY[1];	// Active LOW buy button
	wire pence_20	= ~KEY[2];	// Active LOW 20 pence button
	wire pound		= ~KEY[3];	// Active LOW pound button
	
	// Debounce logic
	wire db_reset, db_buy, db_pence_20, db_pound;
   Debounce db0(CLOCK_50, reset,     db_reset);
   Debounce db1(CLOCK_50, buy,       db_buy);
   Debounce db2(CLOCK_50, pence_20,  db_pence_20);
   Debounce db3(CLOCK_50, pound,     db_pound);
	
	// Vending machine output wires
	wire [4:0]  products; 	  	// Products dispensed (5 bits)
	wire [4:0]  out_of_stock;	// Out of stock items (5 bits)
	wire [11:0] money;  		// Money inserted (12 bits)
	wire [11:0] change;
    wire [2:0]  scroll_mode;
    wire        show_money;
    wire [11:0] amount_to_display;
    wire [1:0]  digit_mode;
	 reg        stock;
	 
	 // Detect button pulses
    reg pence_20_r, pound_r, buy_r;
    wire pence_20_pulse = ~pence_20_r & db_pence_20;
    wire pound_pulse    = ~pound_r & db_pound;
    wire buy_pulse      = ~buy_r & db_buy;
	 always @(posedge CLOCK_50) begin
        pence_20_r <= db_pence_20;
        pound_r    <= db_pound;
        buy_r      <= db_buy;
    end

    wire [4:0] select = SW[4:0];
    wire [4:0] load   = SW[9:5];
	
    vending_machine VM(
        .clk      (CLOCK_50), 		// 50MHz clock
        .reset    (db_reset),		// Debounced reset button
        .pence_20 (db_pence_20),	// Debounced 20 pence button
        .pound    (db_pound),		// Debounced pound button
        .select   (SW[4:0]),		// Product selection switches (5 bits for 5 products)
        .load     (SW[9:5]),		// Load switches (5 bits for 5 products)
        .buy      (db_buy),			// Debounced buy button
        .products (products),		// Products dispensed (5 bits)
        .money    (money),			// Money inserted (12 bits)
        .out_of_stock(out_of_stock) // Out of stock items (5 bits)
    );	
	 // Determine selected price
    reg [7:0] selected_price;
    always @(*) begin
        case (select)
            5'b00001: begin
				              selected_price = 8'd60;
								  stock = out_of_stock[0];
							 end
            5'b00010: begin
				              selected_price = 8'd80;
								  stock = out_of_stock[1];
							 end
            5'b00100: begin
				              selected_price = 8'd100;
								  stock = out_of_stock[2];
							 end
            5'b01000: begin
				              selected_price = 8'd120;
								  stock = out_of_stock[3];
							 end
            5'b10000: begin
				              selected_price = 8'd200;
								  stock = out_of_stock[4];
							 end
            default:  selected_price = 8'd0;
        endcase
    end

    assign change = (money >= selected_price && buy_pulse) ? (money - selected_price) : 12'd0;

    // Transaction complete flag
    reg transaction_complete;

    always @(posedge CLOCK_50 or posedge db_reset) begin
        if (db_reset) begin
            transaction_complete <= 0;
        end else if (buy_pulse && money >= selected_price) begin
            transaction_complete <= 1;
        end else begin
            transaction_complete <= 0;
        end
    end
	 
	 // Display FSM controller
    seven_segment_display_controller display_ctl (
        .clock(CLOCK_50),
        .reset(db_reset),
        .select(select),
        .moneyIn(money),
        .price(selected_price),
        .buy(buy_pulse),
        .change(change),
		  .stock(stock),
        .scrollMode(scroll_mode),
        .showMoney(show_money),
        .amountDisplay(amount_to_display)
    );

    wire [7:0] ascii0, ascii1, ascii2, ascii3, ascii4, ascii5;

    // Instantiate scrolling message display
    scrolling_message scroll_inst (
        .clk(CLOCK_50),
        .reset(db_reset),
        .mode(scroll_mode),
        .char0(ascii0),
        .char1(ascii1),
        .char2(ascii2),
        .char3(ascii3),
        .char4(ascii4),
        .char5(ascii5)
    );

    wire [15:0] bcd;
    binary_to_bcd bcd_conv (
        .binary(amount_to_display),
        .bcd_out(bcd)
    );

    wire [7:0] digit0 = 8'd48 + bcd[3:0];
    wire [7:0] digit1 = 8'd48 + bcd[7:4];
    wire [7:0] digit2 = 8'd48 + bcd[11:8];
    wire [7:0] digit3 = 8'd48 + bcd[15:12];
    wire [7:0] digit4 = " ";
    wire [7:0] digit5 = " ";

    // Drive final display
    seven_segment_decoder display_driver (
        .char0(show_money ? digit0 : ascii0),
        .char1(show_money ? digit1 : ascii1),
        .char2(show_money ? digit2 : ascii2),
        .char3(show_money ? digit3 : ascii3),
        .char4(show_money ? digit4 : ascii4),
        .char5(show_money ? digit5 : ascii5),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );

    reg [2:0] image_select;
always @(*) begin
    case (select)
        5'b00001: image_select = 3'd0;
        5'b00010: image_select = 3'd1;
        5'b00100: image_select = 3'd2;
        5'b01000: image_select = 3'd3;
        5'b10000: image_select = 3'd4;
        default:  image_select = 3'd0;
    endcase
end
    
LT24_test display_inst (
    .clk         (CLOCK_50),
    .reset_n     (~db_reset),      // Active-low reset
    .LT24_DATA   (LT24_DATA),
    .LT24_WR_N   (LT24_WR_N),
    .LT24_RD_N   (LT24_RD_N),
    .LT24_CS_N   (LT24_CS_N),
    .LT24_RS     (LT24_RS),
    .LT24_RESET_N(LT24_RESET_N),
    .LT24_LCD_ON (LT24_LCD_ON),
    .image_select(image_select)    // <-- Add this line
);

		
    assign LEDR[4:0] = products;    // For demonstration: products dispensed
   assign LEDR[9:5] = money[4:0];  // Lower money bits shown on upper LED


// Servo control
servo_motor_1 servo_controller (
    .clk(CLOCK_50),               // Connect to system clock
    .rst(~db_reset),              // Connect reset 
    .enable_button(transaction_complete), // Trigger servo when transaction completes
    .servo_out(SERVO_OUT)         // Connect to output pin
);

endmodule