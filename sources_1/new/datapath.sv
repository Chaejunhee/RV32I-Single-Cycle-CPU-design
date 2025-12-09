`timescale 1ns / 1ps
`include "define.sv"

module datapath (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    input  logic [ 3:0] alu_controls,
    input  logic        reg_wr_en,
    input  logic        aluSrcMuxSel,
    input  logic [ 2:0] RegWdataSel,
    input  logic        branch,
    input  logic        jal,
    input  logic        jalr,
    input  logic [ 1:0] d_size,
    input  logic [31:0] dRdata,
    output logic [31:0] instr_rAddr,
    output logic [31:0] dAddr,
    output logic [31:0] dWdata
);

    logic [31:0] w_regfile_rd1, w_regfile_rd2, w_alu_result;
    logic [31:0] w_imm_Ext, w_aluSrcMux_out, w_RegWdataout, w_pc_MuxOut, w_pc_Next;
    logic [31:0] w_mux_jarl_out;
    logic pc_MuxSel, btaken;
    logic [31:0] w_pc_imm;

    assign dAddr = w_alu_result;
    assign dWdata = w_regfile_rd2;

    // assign pc_MuxSel = jalr | jal | (branch & btaken);

    assign pc_MuxSel = jalr | jal | (branch & ((btaken === 1'bx) ? 1'b0 : btaken));



    mux_2x1 U_PC_MUX (  //pc 바로 앞단 먹서
        .sel(pc_MuxSel),
        .x0 (w_pc_Next),
        .x1 (w_pc_imm),
        .y  (w_pc_MuxOut)
    );

    adder U_PC_IMM_ADDER (
        .a  (w_imm_Ext),
        .b  (w_mux_jarl_out),
        .sum(w_pc_imm)
    );

    adder U_PC_ADDER (
        .a  (32'd4),
        .b  (instr_rAddr),
        .sum(w_pc_Next)
    );

    mux_2x1 U_MUX_JALR (
        .sel(jalr),
        .x0 (instr_rAddr),
        .x1 (w_regfile_rd1),
        .y  (w_mux_jarl_out)
    );
    program_counter U_PC (
        .clk    (clk),
        .reset  (reset),
        .pc_Next(w_pc_MuxOut),
        .pc     (instr_rAddr)
    );

    mux_5x1 U_RegWdataMux (
        .sel(RegWdataSel),
        .x0 (w_alu_result),
        .x1 (dRdata),
        .x2 (w_imm_Ext),
        .x3 (w_pc_imm),
        .x4 (w_pc_Next),
        .y  (w_RegWdataout)
    );


    register_file U_REG_FILE (
        .clk      (clk),
        .RA1      (instr_code[19:15]),  // read address 1
        .RA2      (instr_code[24:20]),  // read address 2
        .WA       (instr_code[11:7]),   // write address
        .reg_wr_en(reg_wr_en),          // write enable
        .WData    (w_RegWdataout),      // write data
        .RD1      (w_regfile_rd1),      // read data 1
        .RD2      (w_regfile_rd2)       // read data 2
    );


    ALU U_ALU (
        .a           (w_regfile_rd1),
        .b           (w_aluSrcMux_out),
        .alu_controls(alu_controls),
        .alu_result  (w_alu_result),
        .btaken      (btaken)
    );

    mux_2x1 U_AluSrcMux (
        .sel(aluSrcMuxSel),
        .x0 (w_regfile_rd2),
        .x1 (w_imm_Ext),
        .y  (w_aluSrcMux_out)
    );

    extend U_Extend (
        .instr_code(instr_code),
        .d_size    (d_size),
        .imm_Ext   (w_imm_Ext)
    );

endmodule

module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] pc_Next,
    output logic [31:0] pc
);

    register U_PC_REG (
        .clk  (clk),
        .reset(reset),
        .d    (pc_Next),
        .q    (pc)
    );
endmodule

module register (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] d,
    output logic [31:0] q
);

    always_ff @(posedge clk, posedge reset) begin
        if (reset) begin
            q <= 0;
        end else begin
            q <= d;
        end
    end

endmodule

module register_file (
    input  logic        clk,
    input  logic [ 4:0] RA1,        // read address 1
    input  logic [ 4:0] RA2,        // read address 2
    input  logic [ 4:0] WA,         // write address
    input  logic        reg_wr_en,  // write enable
    input  logic [31:0] WData,      // write data
    output logic [31:0] RD1,        // read data 1
    output logic [31:0] RD2         // read data 2
);

    logic [31:0] reg_file[0:31];  // 32bit 32개.

    initial begin
        reg_file[0] = 32'd0;
        reg_file[1] = 32'd1;
        reg_file[2] = 32'd2;
        reg_file[3] = 32'd3;
        reg_file[4] = 32'd4;
        reg_file[5] = 32'd5;
        reg_file[6] = 32'd6;
        reg_file[7] = 32'd7;
        reg_file[8] = 32'd8;
        reg_file[9] = 32'd9;
    end

    always_ff @(posedge clk) begin
        if (reg_wr_en & (WA != 5'd0)) begin
            reg_file[WA] <= WData;
        end
    end

    //register address = 0 is zero to return
    assign RD1 = (RA1 != 0) ? reg_file[RA1] : 0;
    assign RD2 = (RA2 != 0) ? reg_file[RA2] : 0;

endmodule

module ALU (
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [3:0] alu_controls,
    output logic [31:0] alu_result,
    output logic btaken
);

    // logic btaken_buf;
    // assign btaken = (btaken_buf == 1'bx) ? 1'b0 : btaken_buf;

    always_comb begin
        case (alu_controls)
            `ADD:    alu_result = a + b;
            `SUB:    alu_result = a - b;
            `SLL:    alu_result = a << b[4:0];
            `SRL:    alu_result = a >> b[4:0];  //0으로 extend
            `SRA:    alu_result = $signed(a) >>> b[4:0];  //[31] extend by signed bit
            `SLT:    alu_result = ($signed(a) < $signed(b)) ? 32'h1 : 32'h0;
            `SLTU:   alu_result = (a < b) ? 32'h1 : 32'h0;
            `XOR:    alu_result = a ^ b;
            `OR:     alu_result = a | b;
            `AND:    alu_result = a & b;
            default: alu_result = 32'bx;
        endcase
    end

    //branch
    always_comb begin

        case (alu_controls[2:0])
            `BEQ:    btaken = ($signed(a) == $signed(b));
            `BNE:    btaken = ($signed(a) != $signed(b));
            `BLT:    btaken = ($signed(a) < $signed(b));
            `BGE:    btaken = ($signed(a) >= $signed(b));
            `BLTU:   btaken = ($unsigned(a) < $unsigned(b));
            `BGEU:   btaken = ($unsigned(a) >= $unsigned(b));
            default: btaken = 1'b0; 
        endcase

    end

endmodule

module extend (
    input  logic [31:0] instr_code,
    input  logic [ 1:0] d_size,
    output logic [31:0] imm_Ext
);

    wire [6:0] opcode = instr_code[6:0];
    wire [2:0] funct3 = instr_code[14:12];


    always_comb begin
        case (opcode)
            `OP_R_TYPE:     imm_Ext = 32'bx;
            // 20 literal 1'b0, 7bit, imm[11:5] 7bit,imm[4:0] 5bit
            `OP_S_TYPE: begin
                case (d_size)
                    2'b00: imm_Ext = {{20{instr_code[31]}}, instr_code[31:25], instr_code[11:7]};
                    2'b01: imm_Ext = {{4{instr_code[31]}}, instr_code[31:25], instr_code[11:7]};
                    2'b10: imm_Ext = {instr_code[27:25], instr_code[11:7]};
                endcase
            end
            `OP_IL_TYPE:    imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            //양수일경우 0으로 채우기, 음수일경우 1로 채우기 (msb 패딩)
            `OP_I_TYPE: begin
                //3인경우만 0으로 패딩, 나머지경우 signed extension
                if (funct3 == 3'b011) imm_Ext = {20'b0, instr_code[31:20]};
                else imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            end
            `OP_B_TYPE:     imm_Ext = {{20{instr_code[31]}}, instr_code[7], instr_code[30:25], instr_code[11:8], 1'b0};
            `OP_LUI_TYPE:   imm_Ext = {instr_code[31:12], 12'b0};
            `OP_AUIPC_TYPE: imm_Ext = {instr_code[31:12], 12'b0};
            `OP_J_TYPE:     imm_Ext = {{11{instr_code[31]}}, instr_code[31], instr_code[19:12], instr_code[20], instr_code[30:21], 1'b0};
            `OP_JALR:       imm_Ext = {{20{instr_code[31]}}, instr_code[31:20]};
            default:        imm_Ext = 32'bx;
        endcase
    end

endmodule

module mux_2x1 (
    input  logic        sel,
    input  logic [31:0] x0,   //0 : regFile R2
    input  logic [31:0] x1,   //1 : imm [31:0]
    output logic [31:0] y     //to ALU
);

    assign y = sel ? x1 : x0;

endmodule

module adder (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] sum
);

    assign sum = a + b;

endmodule

module mux_5x1 (
    input  logic [ 2:0] sel,
    input  logic [31:0] x0,
    input  logic [31:0] x1,
    input  logic [31:0] x2,
    input  logic [31:0] x3,
    input  logic [31:0] x4,
    output logic [31:0] y
);

    assign y = (sel == 3'b000) ? x0 : (sel == 3'b001) ? x1 : (sel == 3'b010) ? x2 : (sel == 3'b011) ? x3 : x4;

endmodule
