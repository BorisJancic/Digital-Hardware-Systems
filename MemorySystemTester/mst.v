//////////////////////////////////////////////////////////////////////////////////
// Company: University of Waterloo
// Engineer: Boris Jancic (student)
// 
// Create Date: 07/24/2024
// Design Name: Memory System Tester
// Module Name: mst
// Project Name: Project 4
//
// Revision 0.01 - Created
// Additional Comments: Test device for memory system (based on original description)
// This design compiles and simulates in Icarus Verilog
//
//////////////////////////////////////////////////////////////////////////////////


module mst(
    input clock,
    input reset,
    input enable,
    
    input [7:0] rdd,
    output wire[7:0] rda,
    output wire we,
    output wire[7:0] wrd,
    output wire[7:0] wra,
    
    output reg[8:0] t1attempts,
    output reg[8:0] t1fails,
    output reg[8:0] t2attempts,
    output reg[8:0] t2fails,
    output reg done
);
    reg write_enable;
    reg[7:0] write_address;
    reg[7:0] write_data;
    reg[7:0] read_address;
    wire[7:0] read_data;

    assign we = write_enable;
    assign wra = write_address;
    assign wrd = write_data;
    assign rda = read_address;
    assign read_data = rdd;
    
    parameter INIT=3'b000, STATE_1=3'b001, STATE_2=3'b010, STATE_3=3'b011, DONE=3'b100;
    reg[2:0] state;
    reg[8:0] i;
    reg[8:0] i_lead; // have the next iteration ready to write to the next address

    always @(negedge clock) begin
        if (reset) begin
            t1attempts <= 0;
            t1fails <= 0;
            t2attempts <= 0;
            t2fails <= 0;
            done <= 0;
            state <= INIT;
            i <= 0;
            i_lead <= 0;
        end else if (enable) begin
            case (state)
                INIT: begin // get initial write down the pipeline
                    write_enable <= 1;
                    write_address <= 8'h00;
                    write_data <= 8'h00;
                    state <= STATE_1;
                end
                STATE_1: begin // place the next read into the pipline
                    write_enable <= 0;
                    read_address <= i[7:0];
                    state <= STATE_2;
                end
                STATE_2: begin // increment the lead to get ready to place the next write into the pipline
                    i_lead <= i + 1;
                    state <= STATE_3;
                end
                STATE_3: begin // read and verify the result, send the next write down the pipline
                    if (i[8] == 0) begin // first bit stores the test case (00 or FF)
                        if (read_data != 8'h00) begin
                            t1fails <= t1fails + 1;
                        end
			t1attempts <= t1attempts + 1;
                    end else if (i[8] == 1) begin
                        if (read_data != 8'hFF) begin
                            t2fails <= t2fails + 1;
                        end
                        t2attempts <= t2attempts + 1;
                    end
                    i <= i + 1;

			if (i != 9'b1_1111_1111) begin // while every test hasn't been complete, move on to the next
                        write_enable <= 1;
                        write_address[7:0] <= i_lead[7:0];
                        if (i_lead[8] == 0) begin
                            write_data[7:0] <= 8'h00;
                        end else begin
                            write_data[7:0] <= 8'hFF;
                        end

                        state <= STATE_1;
                    end else begin // if i was at the last test case, finish testing
			done <= 1;
                        state <= DONE;
                    end
                end
                DONE: begin
                    done <= 1;
        	    state <= DONE;
                end
                default: begin
		    done <= 0;
                end
            endcase
        end
    end
endmodule
