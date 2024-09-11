`timescale 10ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Engineer: Boris Jancic (student)
// 
// Create Date: 06/11/2024
// Design Name: A Pattern Detector
// Module Name: PD
// Project Name: Project 2
// Target Devices: 
// Tool Versions:
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.02 - State Machine Created
// Additional Comments:
// This design compiles and simulates in Icarus Verilog (https://hdlbits.01xz.net/wiki/Iverilog).
//
//////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Engineer: William D. Bishop, P.Eng.
// 
// Create Date: 05/28/2024 08:57:46 PM
// Design Name: A Pattern Detector
// Module Name: top_module
// Project Name: Project 2
// Target Devices: 
// Tool Versions:
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// This design compiles and simulates in Vivado / XSim and Icarus Verilog.
//
//////////////////////////////////////////////////////////////////////////////////

module PD(
    input clk,
    input reset,
    input enable,
    input[3:0] din,
    output reg pattern1,
    output reg pattern2
);
    parameter Idle=4'b0000, S_px_d0=4'b0001, S_p1_d1=4'b0010, S_p1_d2=4'b0011, S_p1_d3=4'b0100,
    	      S_p2_d1=4'b0110, S_p2_d2=4'b0111, S_p2_d3=4'b1000;
    reg [3:0] state = Idle;

    always @(posedge clk) begin
        if (enable) begin
            case (state)
                Idle:
                    case (din)
                        4'b0000: state <= S_px_d0;
                        default: state <= Idle;
                    endcase
                S_px_d0:
                    case (din)
                        4'b0101: state <= S_p1_d1;
                        4'b0110: state <= S_p2_d1;
                        4'b0000: state <= S_px_d0;
                        default: state <= Idle;
                    endcase
                
                S_p1_d1:
                    case (din)
                        4'b0011: state <= S_p1_d2;
                        4'b0000: state <= S_px_d0;
                        default: state <= Idle;
                    endcase
                S_p1_d2:
                    case (din)
                        4'b0001: begin
                            state <= S_p1_d3;
                            pattern1 <= 1'b1;
                        end
                        4'b0000: state <= S_px_d0;
                        default: state <= Idle;
                    endcase
                S_p1_d3: begin
                    pattern1 <= 1'b0;
                    case (din)
                        4'b0000: state <= S_px_d0;
                        default: state <= Idle;
                    endcase
                end
                
                S_p2_d1:
                    case (din)
                        4'b0001: state <= S_p2_d2;
                        4'b0000: state <= S_px_d0;
                        default: state <= Idle;
                    endcase
                S_p2_d2:
                    case (din)
                        4'b1001: begin
                            state <= S_p2_d3;
                            pattern2 <= 1'b1;
                        end
                        4'b0000: state <= S_px_d0;
                        default: state <= Idle;
                    endcase
                S_p2_d3: begin
                    pattern2 <= 1'b0;
                    case (din)
                        4'b0000: state <= S_px_d0;
                        default: state <= Idle;
                    endcase
                end
                default: begin
                    pattern1 <= 1'b0;
                    pattern2 <= 1'b0;
                    state <= Idle;
                end
            endcase
        end else if (reset) begin
            pattern1 <= 1'b0;
            pattern2 <= 1'b0;
            state <= Idle;
        end
    end
endmodule

module top_module ();
    reg clk=1'b0;
    reg reset=1'b0;
    reg enable=1'b0;
    reg [3:0] din=4'b0000;
    reg okay;
    wire pattern1;
    wire pattern2;

    PD u1 ( .clk(clk), .reset(reset), .enable(enable), .din(din), .pattern1(pattern1), .pattern2(pattern2) );
    
    initial
    begin
        clk = 1'b0;
        forever begin
            #10 clk = ~clk;
        end
    end
    
    initial
    begin

	// Continuously monitor changes to inputs and outputs
        $monitor("t=%0t, clk=%0b, rst=%0b, ena=%0b, din=%0h, ok=%0b, p1=%0b, p2=%0b", 
            $time, clk, reset, enable, din, okay, pattern1, pattern2);

	// Create a dumpfile that summarizes the values of all signals during simulation
	$dumpfile("top_module.vcd");
	$dumpvars(0, top_module);

        // Test 1
        okay = 1'b1; 
        reset = 1'b1;

        #40 reset = 1'b0;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b1; din = 4'b0000;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0101;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0011;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0001;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b0;
        if(pattern1 == 1'b1 && pattern2 == 1'b0 && okay == 1'b1)
            $display("Test 1 success");
        else
            $display("Test 1 failed");
       
        // Test 2
        okay = 1'b1; 
        reset = 1'b1;

        #40 reset = 1'b0;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b1; din = 4'b0000;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0110;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0001;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b1001;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b0;
        if(pattern1 == 1'b0 && pattern2 == 1'b1 && okay == 1'b1)
            $display("Test 2 success");
        else
            $display("Test 2 failed");
       
        // Test 3
        okay = 1'b1; 
        reset = 1'b1;

        #40 reset = 1'b0;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b1; din = 4'b0000;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0101;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0000;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0110;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0001;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b1001;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b0;
        if(pattern1 == 1'b0 && pattern2 == 1'b1 && okay == 1'b1)
            $display("Test 3 success");
        else
            $display("Test 3 failed");
       
        // Test 4
        okay = 1'b1; 
        reset = 1'b1;

        #40 reset = 1'b0;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b1; din = 4'b0000;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0101;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0000;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0110;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0000;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0101;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0011;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 din = 4'b0001;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b0;
        if(pattern1 == 1'b1 && pattern2 == 1'b0 && okay == 1'b1)
            $display("Test 4 success");
        else
            $display("Test 4 failed");

        // Test 5
        okay = 1'b1; 
        reset = 1'b1;

        #40 reset = 1'b0;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b1; din = 4'b0000;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b0; din = 4'b0110;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b1; din = 4'b0101;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b0; din = 4'b0001;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b1; din = 4'b0011;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b0; din = 4'b1001;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b1; din = 4'b0001;
        if(pattern1 == 1'b1 || pattern2 == 1'b1)
            okay = 1'b0;

        #20 enable = 1'b0;
        if(pattern1 == 1'b1 && pattern2 == 1'b0 && okay == 1'b1)
            $display("Test 5 success");
        else
            $display("Test 5 failed");
            
        #20 $finish;
       
    end
    
endmodule
