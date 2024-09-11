//////////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Engineer: Boris Jancic (student)
// 
// Create Date: 07/17/2024
// Design Name: Sorting Engine
// Module Name: SE, swap_layer, comp_and_swap
// Project Name: Project 3
// Target Devices: 
// Tool Versions:
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - Created
// Additional Comments: Sorting Engine and Components
// This design compiles and simulates in Icarus Verilog
//
//////////////////////////////////////////////////////////////////////////////////

module SE #(
    parameter[7:0] DATAWIDTH = 8,
    parameter[7:0] ARRAYLENGTH = 10
)(
    input clk,
    input[(DATAWIDTH*ARRAYLENGTH)-1:0] array_in,
    input valid_in,
    output reg[(DATAWIDTH*ARRAYLENGTH)-1:0] array_out,
    output reg valid_out
);
    reg[ARRAYLENGTH-1:0] state = 1;
    reg[(DATAWIDTH*ARRAYLENGTH)-1:0] swap_in;
    reg[(DATAWIDTH*ARRAYLENGTH)-1:0] swap_out;
    reg initial_valid_in = 0;
	swap_layer #(
        .DATAWIDTH(DATAWIDTH),
        .ARRAYLENGTH(ARRAYLENGTH)
    ) swaper (
        .array_in(swap_in),
        .array_out(swap_out)
    );
    
    /*
        Sorting state machine
        Input input when valid_in
        Output result when done sorting with flag valid_out
    */
    always @(posedge clk) begin
        if (valid_in) begin // resets state
            state <= 1;
            valid_out <= 0;
            swap_in <= array_in;
        end else if (initial_valid_in) begin
            if (state[ARRAYLENGTH / 2 - 1 + ARRAYLENGTH % 2]) begin // sorted state
                valid_out <= 1;
                array_out <= swap_out;
            end else begin // sorting iteration, shift to next state
                valid_out <= 0;
                state <= {state[ARRAYLENGTH-2:0], 1'b0};
                swap_in <= swap_out;
            end
        end else begin valid_out <= 0; end
    end
endmodule

// Iteration of compare and swap for whole array
module swap_layer #(
    parameter[7:0] DATAWIDTH = 8,
    parameter[7:0] ARRAYLENGTH = 10
)(
    input [(DATAWIDTH*ARRAYLENGTH)-1:0] array_in,
    output [(DATAWIDTH*ARRAYLENGTH)-1:0] array_out
);
    wire[(DATAWIDTH*ARRAYLENGTH)-1:0] array_mid; // step between 1st and second layer
    generate
        genvar i;
        genvar j;
        if (ARRAYLENGTH % 2 == 0) begin // if even sized array
            // directly drive edge values
        	assign array_out[DATAWIDTH-1:0] = array_mid[DATAWIDTH-1:0];
    		assign array_out[(DATAWIDTH*ARRAYLENGTH)-1:DATAWIDTH*(ARRAYLENGTH-1)] = array_mid[(DATAWIDTH*ARRAYLENGTH)-1:DATAWIDTH*(ARRAYLENGTH-1)];
            for (i = 0; i < ARRAYLENGTH; i = i + 2) begin
                comp_and_swap #(.DATAWIDTH(DATAWIDTH)) u ( // first layer
                    .a_in(array_in[(i+1)*DATAWIDTH-1 : i*DATAWIDTH]),
                    .b_in(array_in[(i+2)*DATAWIDTH-1: (i+1)*DATAWIDTH]),
                    .a_out(array_mid[(i+1)*DATAWIDTH-1 : i*DATAWIDTH]),
                    .b_out(array_mid[(i+2)*DATAWIDTH-1: (i+1)*DATAWIDTH])
            	);
                if (i < ARRAYLENGTH - 2) begin
                    comp_and_swap #(.DATAWIDTH(DATAWIDTH)) v ( // second layer
                        .a_in(array_mid[(i+2)*DATAWIDTH-1 : (i+1)*DATAWIDTH]),
                        .b_in(array_mid[(i+3)*DATAWIDTH-1 : (i+2)*DATAWIDTH]),
                        .a_out(array_out[(i+2)*DATAWIDTH-1 : (i+1)*DATAWIDTH]),
                        .b_out(array_out[(i+3)*DATAWIDTH-1 : (i+2)*DATAWIDTH])
                    );
                end
            end
        end else begin // if odd sized array
            // directly drive edge values
            assign array_mid[DATAWIDTH-1:0] = array_in[DATAWIDTH-1:0];
    		assign array_out[(DATAWIDTH*ARRAYLENGTH)-1:DATAWIDTH*(ARRAYLENGTH-1)] = array_mid[(DATAWIDTH*ARRAYLENGTH)-1:DATAWIDTH*(ARRAYLENGTH-1)];
            for (i = 0; i < ARRAYLENGTH - 1; i = i + 2) begin
            	comp_and_swap #(.DATAWIDTH(DATAWIDTH)) u ( // first layer
                    .a_in(array_in[(i+2)*DATAWIDTH-1 : (i+1)*DATAWIDTH]),
                    .b_in(array_in[(i+3)*DATAWIDTH-1: (i+2)*DATAWIDTH]),
                    .a_out(array_mid[(i+2)*DATAWIDTH-1 : (i+1)*DATAWIDTH]),
                    .b_out(array_mid[(i+3)*DATAWIDTH-1: (i+2)*DATAWIDTH])
            	);
                comp_and_swap #(.DATAWIDTH(DATAWIDTH)) v ( // second layer
                    .a_in(array_mid[(i+1)*DATAWIDTH-1 : i*DATAWIDTH]),
                    .b_in(array_mid[(i+2)*DATAWIDTH-1: (i+1)*DATAWIDTH]),
                    .a_out(array_out[(i+1)*DATAWIDTH-1 : i*DATAWIDTH]),
                    .b_out(array_out[(i+2)*DATAWIDTH-1: (i+1)*DATAWIDTH])
            	);
            end
        end
    endgenerate
endmodule

// Order 2 inputs least to greates
module comp_and_swap #(
    parameter[7:0] DATAWIDTH = 4
)(
    input[DATAWIDTH-1:0] a_in,
    input[DATAWIDTH-1:0] b_in,
    output[DATAWIDTH-1:0] a_out,
    output[DATAWIDTH-1:0] b_out
);
    assign a_out = (a_in > b_in) ? a_in : b_in;
    assign b_out = (a_in > b_in) ? b_in : a_in;
endmodule
