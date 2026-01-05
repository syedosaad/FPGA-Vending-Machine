//  Author: Shikha Tripathi //

module top_module_mapping(
    input clk,                    // clock input 
    input [4:0] select,           // 5 switches to select product
    input [4:0] load,             // 5 switches to load stock levels
    input reset,                  // button to reset the system
    input pound,                  // button to add 100p
    input pence_20,               // button to add 20p
    input buy,                    // button to confirm purchase

    output [4:0] products,        // show available products (LEDs)
    output [4:0] out_of_stock,    // show out-of-stock items (LEDs)

    // 6 seven-segment displays for money and messages
    output [6:0] HEX0,            // units digit of money
    output [6:0] HEX1,            // tens digit of money
    output [6:0] HEX2,            // hundreds digit of money
    output [6:0] HEX3,            // thousands digit of money
    output [6:0] HEX4,            // first digit of scrolling message
    output [6:0] HEX5             // Second digit of scrolling message
);

    // debounce the button inputs to prevent glitches
    wire db_reset, db_buy, db_pence_20, db_pound;
    Debounce db0(clk, reset,     db_reset);      // clean reset signal
    Debounce db1(clk, buy,       db_buy);        // clean buy signal
    Debounce db2(clk, pence_20,  db_pence_20);   // clean 20p button signal
    Debounce db3(clk, pound,     db_pound);      // clean £1 button signal

    // wire to hold the current money amount (in pence)
    wire [11:0] money;

    // FSM state register (0-5)
    reg [2:0] state;
	 
    // define states 
    localparam WELCOME = 0, SELECTED = 1, INSERTING = 2, CHECK = 3, INSUFFICIENT = 4, ENJOY = 5;

    // variables for scrolling message display
    reg [31:0] scroll_counter;    // Counter for timing message scrolling
    reg [3:0] scroll_index;       // Current position in the message
    wire [6:0] scroll_char1, scroll_char2;   // Character segments for display
    // creates tick signal at ~2Hz for scrolling (when counter hits target)
    wire scroll_tick = (scroll_counter == 32'd25_000_000);

    // message display modules for different states
    scrolling_message welcome_msg(.index(scroll_index), .char1(scroll_char1), .char2(scroll_char2), .mode(0));
    scrolling_message insert_msg (.index(scroll_index), .char1(scroll_char1), .char2(scroll_char2), .mode(1));
    scrolling_message insufficient_msg (.index(scroll_index), .char1(scroll_char1), .char2(scroll_char2), .mode(2));
    scrolling_message enjoy_msg (.index(scroll_index), .char1(scroll_char1), .char2(scroll_char2), .mode(3));

    // main vending machine logic module
    vending_machine VM(
        .clk(clk),                // system clock
        .reset(db_reset),         // debounced reset signal
        .pence_20(db_pence_20),   // 20p coin insert signal
        .pound(db_pound),         // 1 pound coin insert signal
        .select(select),          // product selection input
        .load(load),              // stock loading input
        .buy(db_buy),             // purchase confirmation signal
        .products(products),      // available products output
        .money(money),            // current money amount
        .out_of_stock(out_of_stock) // out-of-stock indicators
    );

    // convert binary money value to BCD for display
    wire [3:0] thousands, hundreds, tens, ones;
    binary_to_bcd bcd_converter(
        .binary(money),           // money in binary form
        .thousands(thousands),    // thousands digit BCD
        .hundreds(hundreds),      // hundreds digit BCD
        .tens(tens),              // tens digit BCD
        .ones(ones)               // units digit BCD
    );

    // state machine logic for vending operations
    always @(posedge clk or posedge db_reset) begin
        if (db_reset) begin
            // reset state and scroll variables
            state <= WELCOME;     // go back to welcome state
            scroll_counter <= 0;  // reset scroll timing counter
            scroll_index <= 0;    // reset position in message
        end else begin
            // increment scroll counter for message animation
            scroll_counter <= scroll_counter + 1;
            if (scroll_tick) begin
                // when time to scroll, update message position
                scroll_index <= scroll_index + 1;
                scroll_counter <= 0;  // reset counter
            end

            // state transition logic
            case (state)
                WELCOME: if (|select) state <= SELECTED;  // if any select bit is high
                SELECTED: state <= INSERTING;             // go to money insertion state
                INSERTING: if (db_buy) state <= CHECK;    // when buy pressed, check funds
                CHECK: begin
                    if (money < 100) state <= INSUFFICIENT;  // not enough money
                    else state <= ENJOY;                     // purchase successful
                end
                INSUFFICIENT: if (db_reset) state <= WELCOME;  // reset to try again
                ENJOY: if (db_reset) state <= WELCOME;         // reset after purchase
            endcase
        end
    end

    // display money amount on 7-segment displays
    seven_segment_decoder ssd0(.bin(ones), .seg(HEX0));      // units place
    seven_segment_decoder ssd1(.bin(tens), .seg(HEX1));      // tens place
    seven_segment_decoder ssd2(.bin(hundreds), .seg(HEX2));  // hundreds place
    seven_segment_decoder ssd3(.bin(thousands), .seg(HEX3)); // thousands place

    // display scrolling message on HEX4 based on current state
    assign HEX4 = (state == WELCOME) ? scroll_char1 :
                  (state == SELECTED || state == INSERTING) ? scroll_char1 :
                  (state == INSUFFICIENT) ? scroll_char1 :
                  (state == ENJOY) ? scroll_char1 : 7'b1111111;  // blank if no condition met

    // display scrolling message on HEX5 based on current state
    assign HEX5 = (state == WELCOME) ? scroll_char2 :
                  (state == SELECTED || state == INSERTING) ? scroll_char2 :
                  (state == INSUFFICIENT) ? scroll_char2 :
                  (state == ENJOY) ? scroll_char2 : 7'b1111111;  // blank if no condition met

endmodule