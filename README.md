ELEC5566M Mini-Project Repository - Group 12
This repository contains a FPGA-based vending machine implementation using Verilog HDL. Using a servo motor control system and seven-segment displays for user feedback, the system illustrates how to choose products, process payments, and dispense items.

Authors:
 Saaduddin Syed, Shikha Tripathi,  Manyan Wong, Harini Nagarathinam

Components
-Servo Motor Controller: Controls product dispensing mechanism using PWM signals 
-Seven-Segment Display: Shows product information, money amounts, and status messages 
-Input Controller: Processes user selections and payment input 
-State Machine: Manages the overall transaction flow

vending machine Features
-Button triggered servo motor rotation for product dispensing 
-Seven-segment display for real-time transaction feedback 
-Money insertion and validation system 
-Change calculation and return logic 
-Product selection via switches 
-Error handling for insufficient funds

User Instructions
-Select a product using the selection switches 
-Insert money using designated buttons 
-Press the buy button to confirm purchase 
-If funds are sufficient, the servo motor activates to dispense the product 
-Display shows "Enjoy"

Implementation
-Compile all Verilog files using Quartus Prime 
-Generate programming file and upload to FPGA 
-Connect physical components according to pin assignments mapping
