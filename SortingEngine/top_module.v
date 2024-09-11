//////////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Engineer: Boris Jancic (student)
// 
// Create Date: 07/17/2024
// Design Name: Sorting Engine Test Bench
// Module Name: top_module
// Project Name: Project 3
// Target Devices: 
// Tool Versions:
// Description: 
// 
// Dependencies: SE
// 
// Revision:
// Revision 0.01 - Created
// Additional Comments: Top Module as Test Bench
// This design compiles and simulates in Icarus Verilog
//
//////////////////////////////////////////////////////////////////////////////////

`timescale 10ns / 1ns
`include "SE.v"

module top_module();
    reg clk = 0;
    reg valid_4_10_in = 0;
    reg valid_4_11_in = 0;
    reg valid_8_10_in = 0;
    reg valid_8_11_in = 0;
    reg valid_4_10_out;
    reg valid_4_11_out;
    reg valid_8_10_out;
    reg valid_8_11_out;
    reg [(4*10)-1:0] array_4_10_in;
    reg [(4*10)-1:0] array_4_10_out;
    reg [(4*11)-1:0] array_4_11_in;
    reg [(4*11)-1:0] array_4_11_out;
    reg [(8*10)-1:0] array_8_10_in;
    reg [(8*10)-1:0] array_8_10_out;
    reg [(8*11)-1:0] array_8_11_in;
    reg [(8*11)-1:0] array_8_11_out;
    
    always #5 clk = ~clk;

    // Sorting engines of different lengths and input sizes
    SE #(
        .DATAWIDTH(4),
        .ARRAYLENGTH(10)
    ) SE_4_10 (
        .clk(clk),
        .array_in(array_4_10_in),
        .valid_in(valid_4_10_in),
        .array_out(array_4_10_out),
        .valid_out(valid_4_10_out)
    );
    SE #(
        .DATAWIDTH(4),
        .ARRAYLENGTH(11)
    ) SE_4_11 (
        .clk(clk),
        .array_in(array_4_11_in),
        .valid_in(valid_4_11_in),
        .array_out(array_4_11_out),
        .valid_out(valid_4_11_out)
    );
    SE #(
        .DATAWIDTH(8),
        .ARRAYLENGTH(10)
    ) SE_8_10 (
        .clk(clk),
        .array_in(array_8_10_in),
        .valid_in(valid_8_10_in),
        .array_out(array_8_10_out),
        .valid_out(valid_8_10_out)
    );
    SE #(
        .DATAWIDTH(8),
        .ARRAYLENGTH(11)
    ) SE_8_11 (
        .clk(clk),
        .array_in(array_8_11_in),
        .valid_in(valid_8_11_in),
        .array_out(array_8_11_out),
        .valid_out(valid_8_11_out)
    );

    initial begin
        $display("Testing 10 x 4bits");
        array_4_10_in = 40'h9_3_5_F_2_2_A_1_8_7;
        #100
        if (valid_4_10_out == 1) $display("Failed");
        else $display("Passed: Undefined Initial Valid");
        valid_4_10_in = 1;
        #100
        if (valid_4_10_out == 1) $display("Failed");
        else $display("Passed: valid_in Hold (no sorting)");
        valid_4_10_in = 0;
        $display("    Starting Sort, t=%0t", $time);
        #60
        if (array_4_10_out != 40'h1_2_2_3_5_7_8_9_A_F) $display("Failed");
        else $display("Passed: Sorted, t=%0t", $time);
        $display("---------");

        $display("Testing 11 x 4bits");
        array_4_11_in = 44'hF_D_C_A_8_7_6_4_1_1_1;
        #10
        valid_4_11_in = 1;
        #10
        valid_4_11_in = 0;
        #40
        if (valid_4_11_out == 1) $display("Failed");
        else $display("Passed: No Early valid_out");
        valid_4_11_in = 1;
        #30
        if (valid_4_11_out == 1) $display("Failed");
        else $display("Passed: No valid_out After valid_in");
        valid_4_11_in = 0;
        $display("    Starting Sort, t=%0t", $time);
        #60
        if (valid_4_11_out == 1) $display("Failed");
        else $display("Passed: valid_out");
        if (array_4_11_out != 44'h1_1_1_4_6_7_8_A_C_D_F) $display("Failed");
        else $display("Passed: Sorted, t=%0t", $time);
        $display("---------");

        $display("Testing 10 x 8bits");
        array_8_10_in = 80'h12_15_FF_5D_74_2F_1F_E1_85_34;
        #10
        valid_8_10_in = 1;
        #10
        valid_8_10_in = 0;
        #40
        if (valid_8_10_out == 1) $display("Failed");
        else $display("Passed: No Early valid_out");
        valid_8_10_in = 1;
        #30
        if (valid_8_10_out == 1) $display("Failed");
        else $display("Passed: No valid_out After valid_in");
        valid_8_10_in = 0;
        $display("    Starting Sort, t=%0t", $time);
        #60
        if (valid_8_10_out == 1) $display("Failed");
        else $display("Passed: valid_out");
        if (array_8_10_out != 80'h12_15_1F_2F_34_5D_74_85_E1_FF) $display("Failed");
        else $display("Passed: Sorted, t=%0t", $time);
        $display("---------");

        $display("Testing 11 x 8bits");
        array_8_11_in = 88'hFF_12_15_AA_5D_74_2F_1F_E1_85_10;
        #10
        valid_8_11_in = 1;
        #10
        valid_8_11_in = 0;
        #40
        if (valid_8_11_out == 1) $display("Failed");
        else $display("Passed: No Early valid_out");
        valid_8_11_in = 1;
        #30
        if (valid_8_11_out == 1) $display("Failed");
        else $display("Passed: No valid_out After valid_in");
        valid_8_11_in = 0;
        $display("    Starting Sort, t=%0t", $time);
        #60
        if (valid_8_11_out == 1) $display("Failed");
        else $display("Passed: valid_out");
        if (array_8_11_out != 88'h10_12_15_1F_2F_5D_74_85_AA_E1_FF) $display("Failed");
        else $display("Passed: Sorted, t=%0t", $time);

        $finish;
    end
endmodule
