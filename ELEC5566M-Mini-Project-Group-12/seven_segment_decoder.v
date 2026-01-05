//  Author: Shikha Tripathi //
// seven_segment_decoder.v
// to control the 6 digits/characters (HEX0 to HEX5) of the seven-segment displays


module seven_segment_decoder (
    input [7:0] char0, char1, char2, char3, char4, char5, // 6 characters to display 
    output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5         // segment output for hex displays
);

    wire [6:0] seg0, seg1, seg2, seg3, seg4, seg5;				// temporarily holds segment patterns for each digit/character

    //function to convert each character to its corresponding 7-segment pattern
    assign seg0 = decode_char(char0); // HEX0 
    assign seg1 = decode_char(char1); // HEX1
    assign seg2 = decode_char(char2); // HEX2
    assign seg3 = decode_char(char3); // HEX3
    assign seg4 = decode_char(char4); // HEX4
    assign seg5 = decode_char(char5); // HEX5 

    //connect segment patterns to the actual HEX displays
    assign HEX0 = seg0;
    assign HEX1 = seg1;
    assign HEX2 = seg2;
    assign HEX3 = seg3;
    assign HEX4 = seg4;
    assign HEX5 = seg5;

    // Function to check input character and return pattern to display on 7-segment 
    function [6:0] decode_char;
        input [7:0] char; // character to display (ASCII input)
        begin
            // check which character and return the matching 7-segment pattern
            case (char)
                "0": decode_char = 7'b1000000; // display 0
                "1": decode_char = 7'b1111001; // display 1
                "2": decode_char = 7'b0100100; // display 2
                "3": decode_char = 7'b0110000; // display 3
                "4": decode_char = 7'b0011001; // display 4
                "5": decode_char = 7'b0010010; // display 5
                "6": decode_char = 7'b0000010; // display 6
                "7": decode_char = 7'b1111000; // display 7
                "8": decode_char = 7'b0000000; // display 8
                "9": decode_char = 7'b0011000; // display 9
                "A": decode_char = 7'b0001000; // display A
					 "b": decode_char = 7'b1111100; // display b
                "C": decode_char = 7'b1000110; // display C
                "D": decode_char = 7'b0100001; // display D
                "E": decode_char = 7'b0000110; // display E
                "F": decode_char = 7'b0001110; // display F
                "H": decode_char = 7'b0001001; // display H
                "I": decode_char = 7'b1111001; // display I
					 "J": decode_char = 7'b1100001; // display J
                "K": decode_char = 7'b0001111; // display K
                "L": decode_char = 7'b1000111; // display L
                "M": decode_char = 7'b1101010; // display M
                "N": decode_char = 7'b0101011; // display N
                "O": decode_char = 7'b1000000; // display O
					 "P": decode_char = 7'b0001100; // display P
                "R": decode_char = 7'b0101111; // display R
                "S": decode_char = 7'b0010010; // display S
                "T": decode_char = 7'b0000111; // display T
                "U": decode_char = 7'b1000001; // display U
                "Y": decode_char = 7'b0010001; // display Y
                " ": decode_char = 7'b1111111; // blank (no display)
                default: decode_char = 7'b1111111; // if unknown, show nothing
            endcase
        end
    endfunction

endmodule
