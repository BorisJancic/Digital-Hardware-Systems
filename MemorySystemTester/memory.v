module memory(
    input clock,
    input reset,
    input we,
    input [7:0] wra,
    input [7:0] wrd,
    input [7:0] rda,
    output [7:0] rdd
    );
    
    reg [7:0] mem[255:0];
    reg [7:0] rddata;
    
    always @(posedge clock) begin
        if(reset) begin
            rddata <= 8'b0;
        end else begin
            if(we) begin
                mem[wra] <= wrd;
            end
            rddata <= mem[rda];
        end
    end

    assign rdd = rddata;      
endmodule
