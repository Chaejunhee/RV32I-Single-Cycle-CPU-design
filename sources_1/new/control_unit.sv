`timescale 1ns / 1ps
`include "define.sv"

module control_unit (
    input  logic [31:0] instr_code,
    output logic [ 3:0] alu_controls,
    output logic        aluSrcMuxSel,
    output logic        reg_wr_en,
    output logic        d_wr_en,
    output logic [ 1:0] d_size,
    output logic [ 2:0] load_type,
    output logic [ 2:0] RegWdataSel,
    output logic        branch,
    output logic        jal,
    output logic        jalr
);

    //    rom [0] = 32'h004182B3; //32'b0000_0000_0100_0001_1000_0010_1011_0011; // add x5, x3, x4
    wire  [6:0] funct7 = instr_code[31:25];
    wire  [2:0] funct3 = instr_code[14:12];
    wire  [6:0] opcode = instr_code[6:0];

    logic [8:0] controls;

    //제어신호 풀어서 출력
    assign {RegWdataSel, aluSrcMuxSel, reg_wr_en, d_wr_en, branch, jal, jalr} = controls;

    always_comb begin
        case (opcode)
            //RegWdataSel,aluSrcMuxSel,reg_wr_en,d_wr_en,brach,jal,jalr
            `OP_R_TYPE:     controls = 9'b000_0_1_0_0_0_0;  // R-type
            `OP_S_TYPE:     controls = 9'b000_1_0_1_0_0_0;  // S-type
            `OP_IL_TYPE:    controls = 9'b001_1_1_0_0_0_0;  //IL-type
            `OP_I_TYPE:     controls = 9'b000_1_1_0_0_0_0;  //I-type
            `OP_B_TYPE:     controls = 9'b000_0_0_0_1_0_0;  //B-type
            `OP_LUI_TYPE:   controls = 9'b010_0_1_0_0_0_0;  //U-type LUI
            `OP_AUIPC_TYPE: controls = 9'b011_0_1_0_0_0_0;  //U-type AUIPC
            `OP_J_TYPE:     controls = 9'b100_0_1_0_0_1_0;  //j-type
            `OP_JALR:       controls = 9'b100_0_1_0_0_0_1;  //jalr
            default:        controls = 9'b000_0_0_0_0_0_0;
        endcase
    end

    //ALU 제어신호
    always_comb begin
        case (opcode)
            `OP_R_TYPE:     alu_controls = {funct7[5], funct3};  // R-type
            `OP_S_TYPE:     alu_controls = `ADD;  // S-type
            `OP_IL_TYPE:    alu_controls = `ADD;  //IL-type
            `OP_I_TYPE: begin
                if ({funct7[5], funct3} == 4'b1101) alu_controls = {1'b1, funct3};  //sra의 경우
                else alu_controls = {1'b0, funct3};  //나머지 경우
            end  //I-type srll과 sra구분위해 funct7[5]  필요 , 조건문 참-> sra 거짓-> srll
            `OP_B_TYPE:     alu_controls = {1'b0, funct3};
            `OP_LUI_TYPE:   alu_controls = `ADD;  //U-type
            `OP_AUIPC_TYPE: alu_controls = `ADD;  //U-type
            `OP_J_TYPE:     alu_controls = `ADD;  //j-type
            `OP_JALR:       alu_controls = `ADD;  //jalr
            default:        alu_controls = 4'bx;
        endcase
    end

    //opcode stype , ram/extend control
    always_comb begin
        d_size = 2'bx;
        if (opcode == `OP_S_TYPE) begin
            case (funct3)
                3'b000:  d_size = 2'b10;  //Store Byte
                3'b001:  d_size = 2'b01;  //Store Half
                3'b010:  d_size = 2'b00;  //Store Word
                default: d_size = 2'bx;
            endcase
        end
    end

    //opcode Itype, rom control
    always_comb begin
        load_type = 3'bx;
        if (opcode == `OP_IL_TYPE) begin
            case (funct3)
                3'b000:  load_type = 3'b000;  //LB 
                3'b001:  load_type = 3'b001;  //LH
                3'b010:  load_type = 3'b010;  //LW
                3'b100:  load_type = 3'b100;  //LBU
                3'b101:  load_type = 3'b101;  //LHU
                default: load_type = 3'bx;
            endcase
        end
    end

endmodule
