`timescale 1ns / 1ps

module data_mem (
    input  logic        clk,
    input  logic        d_wr_en,
    input  logic [31:0] dAddr,
    input  logic [31:0] dWdata,
    input  logic [ 1:0] d_size,
    input  logic [ 2:0] load_type,
    output logic [31:0] dRdata
);

    logic [31:0] ram[0:255];  // word


    initial begin  //word version
        for (int i = 0; i < 16; i++) begin
            ram[i] = i + 32'h87654321;
        end
        ram[17] = 32'hf1234abc;
    end

    always_ff @(posedge clk) begin
        if (d_wr_en) begin
            case (d_size)
                2'b00: begin  // SW (Store Word)
                    ram[dAddr] <= dWdata;  //word
                end
                // end
                2'b01: begin  // SH (Store Half)
                    ram[dAddr][15:0] <= dWdata[15:0];  //word
                end
                2'b10: begin  // SB (Store Byte)
                    ram[dAddr][7:0] <= dWdata[7:0];  //word
                end
            endcase
        end
    end

    always_comb begin  //word
        case (load_type)
            3'b000:  dRdata = {{24{ram[dAddr][7]}}, ram[dAddr][7:0]};  //LB
            3'b001:  dRdata = {{16{ram[dAddr][15]}}, ram[dAddr][15:0]};  //LH
            3'b010:  dRdata = ram[dAddr];  //LW
            3'b100:  dRdata = {{24{1'b0}}, ram[dAddr][7:0]};  //LBU
            3'b101:  dRdata = {{16{1'b0}}, ram[dAddr][15:0]};  //LBH
            default: dRdata = ram[dAddr];
        endcase
    end



endmodule




