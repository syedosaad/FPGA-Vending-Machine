//  Author: Saaduddin Syed, Manyan Wong //


module LT24_test (
    input  wire        clk,
    input  wire        reset_n,
    output wire [15:0] LT24_DATA,
    output wire        LT24_WR_N,
    output wire        LT24_RD_N,
    output wire        LT24_CS_N,
    output wire        LT24_RS,
    output wire        LT24_RESET_N,
    output wire        LT24_LCD_ON,  // Output for LCD backlight
    input  wire [2:0]  image_select // Select image to display
);

// Local Variables
reg  [ 7:0] xAddr;
reg  [ 8:0] yAddr;
reg  [15:0] pixelData;
wire        pixelReady;
reg         pixelWrite;

// LCD Display
localparam LCD_WIDTH  = 240;
localparam LCD_HEIGHT = 320;
localparam RED        = 16'hF800;  // Define red color
localparam WHITE      = 16'hFFFF; // Define white color

// Red Box Parameters 
localparam BOX_X1 = 50;
localparam BOX_Y1 = 50;
localparam BOX_X2 = 150;
localparam BOX_Y2 = 150;

// Assign LCD Backlight - Always On
wire lcd_backlight;
assign LT24_LCD_ON = lcd_backlight;
assign lcd_backlight = 1'b1;

LT24Display #(
    .WIDTH       (LCD_WIDTH  ),
    .HEIGHT      (LCD_HEIGHT ),
    .CLOCK_FREQ  (50000000   )
) Display (
    //Clock and Reset In
    .clock       (clk      ),
    .globalReset (~reset_n),  // Invert reset signal
    //Reset for User Logic
    //.resetApp    (1'b0),    // Tie to ground - no reset  <- REMOVE THIS LINE
    //Pixel Interface
    .xAddr       (xAddr      ),
    .yAddr       (yAddr      ),
    .pixelData   (pixelData  ),
    .pixelWrite  (pixelWrite ),
    .pixelReady  (pixelReady ),
    //Use pixel addressing mode
    .pixelRawMode(1'b0       ),
    //Unused Command Interface
    .cmdData     (8'b0       ),
    .cmdWrite    (1'b0       ),
    .cmdDone     (1'b0       ),
    .cmdReady    (           ),
    //Display Connections
    .LT24Wr_n    (LT24_WR_N   ),
    .LT24Rd_n    (LT24_RD_N   ),
    .LT24CS_n    (LT24_CS_N   ),
    .LT24RS      (LT24_RS     ),
    .LT24Reset_n (LT24_RESET_N),
    .LT24Data    (LT24_DATA   ),
    .LT24LCDOn   (LT24LCD_On  )
);

// X Counter
wire [7:0] xCount;      // 8-bit counter for X coordinate
UpCounterNbit #(
    .WIDTH    (          8),
    .MAX_VALUE(LCD_WIDTH-1)
) xCounter (
    .clock     (clk     ),
    .reset     (~reset_n),  // Invert reset signal
    .enable    (pixelReady),
    .countValue(xCount    )
);

// Y Counter
wire [8:0] yCount;      // 9-bit counter for Y coordinate
wire yCntEnable = pixelReady && (xCount == (LCD_WIDTH-1));
UpCounterNbit #(
    .WIDTH    (           9),
    .MAX_VALUE(LCD_HEIGHT-1)
) yCounter (
    .clock     (clk     ),
    .reset     (~reset_n),  // Invert reset signal
    .enable    (yCntEnable),
    .countValue(yCount    )
);
// For 120x160 image scaled to 240x320 display (2x upscaling)
wire [7:0] img_x = xCount >> 1; // Divide by 2
wire [7:0] img_y = yCount >> 1; // Divide by 2
wire [14:0] img_addr = img_y * 8'd120 + img_x;  // 120x160 image address calculation

wire [16:0] pixel_addr; // 17-bit pixel address for 240x320 display
assign pixel_addr = yCount * LCD_WIDTH + xCount;

// Declare mem_pixel_data here before it's used
reg [15:0] mem_pixel_data;  // 16-bit pixel data for the display

// ...existing code...


wire [15:0] mem_pixel_data0, mem_pixel_data1, mem_pixel_data2, mem_pixel_data3, mem_pixel_data4;

//ROM: 1- PORT 

rom0 rom0_inst (               // 160x120 water bottle image with price
    .address(img_addr),     
    .clock(clk),
    .q(mem_pixel_data0)
);
rom1 rom1_inst (               // 160x120 chocolate bar image with price
    .address(img_addr),
    .clock(clk),
    .q(mem_pixel_data1)
);

rom2 rom2_inst (               // 160x120 soda image with price
    .address(img_addr),
    .clock(clk),
    .q(mem_pixel_data2)
);
rom3 rom3_inst (               // 160x120 crisp image with price
    .address(img_addr), 
    .clock(clk),
    .q(mem_pixel_data3)
);
rom4 rom4_inst (               // 160x120 sandwich image with price
    .address(img_addr),
    .clock(clk),
    .q(mem_pixel_data4)
);
// Pixel Write
always @ (posedge clk or negedge reset_n) begin
    if (~reset_n) begin
        pixelWrite <= 1'b0;
    end else begin
        pixelWrite <= 1'b1;
    end
end

// This is a simple test pattern generator.
// We create a different colour for each pixel based on
// the X-Y coordinate.
always @ (posedge clk or negedge reset_n) begin
    if (~reset_n) begin
        xAddr     <= 8'b0;
        yAddr     <= 9'b0;
        pixelData <= 16'h0000;
    end else if (pixelReady) begin
        xAddr     <= xCount;
        yAddr     <= yCount;
        pixelData <= mem_pixel_data;
    end
end

// Select the pixel data based on the image_select input
always @(*) begin
    case (image_select)
        3'b000: mem_pixel_data = mem_pixel_data0;   // Water bottle
        3'b001: mem_pixel_data = mem_pixel_data1;   // Chocolate bar
        3'b010: mem_pixel_data = mem_pixel_data2;   // Soda
        3'b011: mem_pixel_data = mem_pixel_data3;   // Crisp
        3'b100: mem_pixel_data = mem_pixel_data4;   // Sandwich
        default: mem_pixel_data = 8'h00; // Black or default
    endcase
end

endmodule