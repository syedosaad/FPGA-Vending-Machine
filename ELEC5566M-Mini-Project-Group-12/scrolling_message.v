//  Author: Shikha Tripathi //
// scrolling_message.v
// Displays scrolling ASCII messages for different vending machine states

module scrolling_message(
    input clk,
    input reset,
    input [2:0] mode,
    output reg [7:0] char0,
    output reg [7:0] char1,
    output reg [7:0] char2,
    output reg [7:0] char3,
    output reg [7:0] char4,
    output reg [7:0] char5
);

    reg [22:0] clk_div;
    wire tick = clk_div[22]; // slower scrolling

    always @(posedge clk or posedge reset) begin
        if (reset)
            clk_div <= 0;
        else
            clk_div <= clk_div + 1;
    end

    reg [5:0] scroll_idx;
    reg [2:0] prev_mode;
    reg [7:0] message [0:63];

    always @(posedge tick or posedge reset) begin
        if (reset) begin
            scroll_idx <= 0;
            prev_mode <= mode;
        end else begin
            if (mode != prev_mode) begin
                scroll_idx <= 0; // restart scroll when message changes
                prev_mode <= mode;
            end else begin
                scroll_idx <= (scroll_idx + 1) % 58; // 64 - 6 = 58
            end
        end
    end

    always @(*) begin
        integer i;
        // Clear message buffer
        for (i = 0; i < 64; i = i + 1)
            message[i] = " ";

        case (mode)
            3'd0: begin // SELECT A PRODUCT
                message[0] = " "; message[1] = "S"; message[2] = "E"; message[3] = "L";
                message[4] = "E"; message[5] = "C"; message[6] = "T"; message[7] = " ";
                message[8] = "A"; message[9] = " "; message[10] = "P"; message[11] = "R";
                message[12] = "O"; message[13] = "D"; message[14] = "U"; message[15] = "C";
                message[16] = "T"; message[17] = " ";
            end
            3'd1: begin // INSERT MONEY
                message[0] = " "; message[1] = "I"; message[2] = "N"; message[3] = "S";
                message[4] = "E"; message[5] = "R"; message[6] = "T"; message[7] = " ";
                message[8] = "M"; message[9] = "O"; message[10] = "N"; message[11] = "E";
                message[12] = "Y"; message[13] = " ";
            end
            3'd2: begin // INSUFFICIENT AMOUNT
                message[0] = " "; message[1] = "I"; message[2] = "N"; message[3] = "S";
                message[4] = "U"; message[5] = "F"; message[6] = "F"; message[7] = "I";
                message[8] = "C"; message[9] = "I"; message[10] = "E"; message[11] = "N";
                message[12] = "T"; message[13] = " "; message[14] = "A"; message[15] = "M";
                message[16] = "O"; message[17] = "U"; message[18] = "N"; message[19] = "T"; message[20] = " ";
            end
            3'd3: begin // OUT OF STOCK
                message[0] = " "; message[1] = "O"; message[2] = "U"; message[3] = "T";
                message[4] = " "; message[5] = "O"; message[6] = "F"; message[7] = " ";
                message[8] = "S"; message[9] = "T"; message[10] = "O"; message[11] = "C";
                message[12] = "K"; message[13] = " ";
            end
            3'd4: begin // ENJOY!
                message[0] = " "; message[1] = "E"; message[2] = "N"; message[3] = "J";
                message[4] = "O"; message[5] = "Y"; message[6] = " ";
            end
        endcase

        // Display in right-to-left order
        char5 = message[scroll_idx];
        char4 = message[scroll_idx + 1];
        char3 = message[scroll_idx + 2];
        char2 = message[scroll_idx + 3];
        char1 = message[scroll_idx + 4];
        char0 = message[scroll_idx + 5];
    end

endmodule
