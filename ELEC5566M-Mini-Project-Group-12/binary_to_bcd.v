//  Author: Shikha Tripathi //
// binary_to_bcd.v
// converts 12-bit binary input into 4-digit BCD format for use on 7-segment displays


module binary_to_bcd (
    input [11:0] binary,             // 12-bit binary input 
    output reg [15:0] bcd_out        // 4-digit BCD output - thousands, hundreds, tens, units
);
    integer i;                       // loop counter
    reg [27:0] shift_reg;            // temporary 28 bit register to hold BCD conversion 

    always @(*) begin
        shift_reg = 28'd0;           // initialize shift register to zero
        shift_reg[11:0] = binary;    // load binary input into 12 bits

   
        // double dabble algorith that shifts binary number to left to convert it to BCD
        for (i = 0; i < 12; i = i + 1) begin
            // If a 4-bit BCD group is 5 or more, add 3 before shifting
            if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3;   // units
            if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3;   // tens
            if (shift_reg[23:20] >= 5) shift_reg[23:20] = shift_reg[23:20] + 3;   // hundreds
            if (shift_reg[27:24] >= 5) shift_reg[27:24] = shift_reg[27:24] + 3;   // thousands

            // shift the register left by 1 bit
            shift_reg = shift_reg << 1;
        end

        // extract top 16 bits of the BCD output
        bcd_out = shift_reg[27:12];
    end
endmodule