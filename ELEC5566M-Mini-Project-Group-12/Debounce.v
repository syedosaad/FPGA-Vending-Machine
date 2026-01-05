//  Author: Saaduddin Syed //


module Debounce(
    input clk,          // clock (use 50MHz for DE1-SoC)
    input btn_in,       // active HIGH button input
    output reg btn_out  // debounced button output (active HIGH)
);
    reg [17:0] cnt;             // About 2.6ms for 50MHz clk (enough for pushbuttons)
    reg btn_sync_0, btn_sync_1; // synchronized button states
    reg btn_state;              // current state of the button (debounced)
    always @(posedge clk) begin
        // synchronize the input to the clock
        btn_sync_0 <= btn_in;      // first stage of synchronization
        btn_sync_1 <= btn_sync_0; // second stage of synchronization

        // debounce logic
        if (btn_sync_1 == btn_state)    // no change in state
            cnt <= 0; // no change, reset counter
        else begin
            cnt <= cnt + 1;
            if (cnt == 18'd200_000) begin // ~4ms at 50MHz
                btn_state <= btn_sync_1; // update state after debounce period
                cnt <= 0;               // reset counter after state change
            end
        end
        btn_out <= btn_state;           // output the debounced state
    end
endmodule