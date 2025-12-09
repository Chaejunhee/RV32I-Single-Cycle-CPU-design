`timescale 1ns / 1ps

//j-type 추가

module RV32I_TOP (
    input logic clk,
    input logic reset
);

    logic [31:0] instr_code, instr_rAddr;
    logic [31:0] dAddr, dWdata, dRdata;
    logic d_wr_en;
    logic [1:0] d_size;
    logic [2:0] load_type;


    RV32I_Core U_RV32I_CPU (.*);
    instr_mem U_Instr_Mem (.*);
    data_mem U_Data_Mem (.*);

endmodule

module RV32I_Core (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instr_code,
    input  logic [31:0] dRdata,
    output logic [31:0] instr_rAddr,
    output logic        d_wr_en,
    output logic [31:0] dAddr,
    output logic [31:0] dWdata,
    output logic [ 1:0] d_size,
    output logic [ 2:0] load_type
);

    logic [3:0] alu_controls;
    logic reg_wr_en, aluSrcMuxSel, branch, jal, jalr;
    logic [2:0] RegWdataSel;

    control_unit U_Control_Unit (.*);
    datapath U_Data_Path (.*);
endmodule
