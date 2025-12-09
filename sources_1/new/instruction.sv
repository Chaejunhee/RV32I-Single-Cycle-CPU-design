`timescale 1ns / 1ps

module instr_mem (
    input  logic [31:0] instr_rAddr,
    output logic [31:0] instr_code
);
    // logic [7:0] rom[0:63];
    logic [31:0] rom[0:127];

    initial begin
        //외부 rom파일 작성
        // $readmemh("code2.txt", rom);
        // rom[0] = 32'h00000013; // do nothing
        // //////////////////////////////word
        //R-type
        // rom[0] = 32'h00308533;  // add x10, x1, x3 
        // rom[1] = 32'h404185b3;  // sub x11, x3, x4
        // rom[2] = 32'h00329633;  // sll x12, x5, x3
        // rom[3] = 32'h003026b3;  // slt x13, x0, x3
        // rom[4] = 32'h00303733;  // sltu x14, x0, x3
        // rom[5] = 32'h0025c7b3;  // xor x15, x11, x2
        // rom[6] = 32'h00305833;  // srl x16 x0 x3 
        // rom[7] = 32'h407458b3;  // sra x17, x8, x7 
        // rom[8] = 32'h00526933;  // or x18, x4, x5 
        // rom[9] = 32'h00a479b3;  // and x19, x8, x10

        // //32'b imm(7bit)_rs2(5bit) _ rs1(5bit) _ funct3(3bit) _imm(5bit) _ opcode(7'b0100011) s-type
        //S - type
        // rom[0] = 32'h008182a3;  // sb x8, 5(x3) 
        // rom[1] = 32'h00819323;  // sh x8, 6(x3)
        // rom[2] = 32'h0081a3a3;  // sw x8, 7(x3)
        // //IL-type
        rom[0] = 32'h00c2a583;  // lw x11, 12(x5)
        rom[1] = 32'h00c29603;  // lh x12, 12(x5)
        rom[2] = 32'h00c28683;  // lb x13, 12(x5)
        rom[3] = 32'h00c2d703;  // lhu x14, 12(x5)
        rom[4] = 32'h00c2c783;  // lbu x15, 12(x5)
        // //I-type
        // rom[0] = 32'h00f28593;  // addi x11, x5, 15
        // rom[1] = 32'h00f2a613;  // slti x12, x5, 15
        // rom[2] = 32'h0032b693;  // sltiu x13, x5, 3
        // rom[3] = 32'h00a2c713;  // xori x14, x5, 10
        // rom[4] = 32'h00a2e793;  // ori x15, x5, 10
        // rom[5] = 32'h00a2f813;  // andi x16, x5, 10
        // rom[6] = 32'h00129893;  // slli x17, x5, 1
        // rom[7] = 32'h0012d913;  // srli x18, x5, 1
        // rom[8] = 32'h4034d993;  // srai x19, x9, 3

        //b-type
        // /////////////////////
        // rom[0]  = 32'hff800593;  //addi x11 x0, -8 음수값 저장
        // rom[1]  = 32'hfa500613;  //addi x12 x0, -91 음수값 저장

        // rom[2]  = 32'h00528b63;  //beq x5, x5, 22 
        // rom[8]  = 32'hfe839ae3;  //bne x7, x8, -12
        // rom[6]  = 32'h0095cc63;  //blt x11, x9, 24
        // rom[12] = 32'h00345163;  //bge x8, x3, 2  
        // rom[13] = 32'h0095ec63;  //bltu x11, x9, 24
        // rom[14] = 32'h0175f463;  //bgeu x11, x23, 8
        /////////////////////
        //U-type
        // rom[0] = 32'h0000a5b7;  // lui x11, 10
        // rom[1] = 32'h0000a617;  // auipc x12, 10
        // JAL (J-type)
        // rom[0] = 32'h010005ef;  // jal x11, 16
        // JALR (I-type)u
        // rom[4] = 32'h01020667;  // jalr x12, 16(x4)
    end
    //word
    assign instr_code = rom[instr_rAddr[31:2]];
    //byte
    // assign instr_code = {
    //     rom[instr_rAddr+3],
    //     rom[instr_rAddr+2],
    //     rom[instr_rAddr+1],
    //     rom[instr_rAddr]
    // };
endmodule
