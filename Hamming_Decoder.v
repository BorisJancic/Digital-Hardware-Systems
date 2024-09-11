module HAM_12(
    input[11:0] code,
    output reg[7:0] data,
    output reg[3:0] syndrome
);
    wire[7:0] data_in;
 	wire[3:0] C_recv;
    wire[3:0] C_calc;

    assign data_in = {
        code[11], code[10], code[9], code[8],
        code[6], code[5], code[4], code[2]
    };
    assign C_recv = {code[7], code[3], code[1], code[0]};
    assign C_calc[0] = data_in[0]^data_in[1]^data_in[3]^data_in[4]^data_in[6];
    assign C_calc[1] = data_in[0]^data_in[2]^data_in[3]^data_in[5]^data_in[6];
    assign C_calc[2] = data_in[1]^data_in[2]^data_in[3]^data_in[7];
    assign C_calc[3] = data_in[4]^data_in[5]^data_in[6]^data_in[7];

    wire[3:0] synd;
    assign synd[3:0] = {C_recv[3]^C_calc[3], C_recv[2]^C_calc[2], C_recv[1]^C_calc[1], C_recv[0]^C_calc[0]};
    
    reg[11:0] data_corr;
    always @(*) begin
        case (synd)
            4'b0011: data_corr[11:0] = {code[11:3], ~code[2], code[1:0]};
            4'b0101: data_corr[11:0] = {code[11:5], ~code[4], code[3:0]};
            4'b0110: data_corr[11:0] = {code[11:6], ~code[5], code[4:0]};
            4'b0111: data_corr[11:0] = {code[11:7], ~code[6], code[5:0]};
            4'b1001: data_corr[11:0] = {code[11:9], ~code[8], code[7:0]};
            4'b1010: data_corr[11:0] = {code[11:10], ~code[9], code[8:0]};
            4'b1011: data_corr[11:0] = {code[11], ~code[10], code[9:0]};
            4'b1100: data_corr[11:0] = {~code[11], code[10:0]};
            default: data_corr[11:0] = code[11:0];
        endcase
    end
    
    assign data = {
        data_corr[11], data_corr[10], data_corr[9], data_corr[8], 
        data_corr[6], data_corr[5], data_corr[4], data_corr[2]
    };
    assign syndrome = synd;
endmodule

module HAM_12_TB(
    input[7:0] data,
    input[3:0] syndrome,
    output reg[11:0] code
);
    initial
    begin
        $monitor ($time, "ns code[11:0]=%b, data[7:0]=%b, syndrome[3:0]=%b", code, data, syndrome);
        		code = 12'b001101001111;
        	#10 code = 12'b001101001110;
            #10 code = 12'b001101001101;
        	#10 code = 12'b001101001011;
        	#10 code = 12'b001101000111;
        	#10 code = 12'b001101011111;
        	#10 code = 12'b001101101111;
        	#10 code = 12'b001100001111;
        	#10 code = 12'b001111001111;
        	#10 code = 12'b001001001111;
        	#10 code = 12'b000101001111;
        	#10 code = 12'b011101001111;
        	#10 code = 12'b101101001111;
			#10
		$finish;
    end
endmodule

module top_module();
    wire[11:0] code;
    wire[7:0] data;
    wire[3:0] syndrome;
    HAM_12 v1(code, data, syndrome);
    HAM_12_TB v2(data, syndrome, code);
endmodule
