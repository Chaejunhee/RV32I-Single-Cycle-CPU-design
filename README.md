# 🖥️ RV32I Single-Cycle Processor Design

## 📋 프로젝트 개요 (Project Overview)
이 프로젝트는 **SystemVerilog**를 사용하여 설계된 **RISC-V 32-bit Integer (RV32I)** 싱글 사이클 프로세서입니다.

RISC-V 명령어 집합 아키텍처(ISA)를 준수하여 설계되었으며, 데이터패스(Datapath)와 제어 유닛(Control Unit)을 분리하여 모듈화된 구조를 갖추고 있습니다. 실제 어셈블리 코드를 기계어(`code2.txt`)로 변환하여 시뮬레이션을 통해 동작을 검증했습니다.

### 👨‍💻 Author
* **채준희** (Chae Jun-hee)

---

## 🎯 주요 기능 및 특징 (Key Features)

* **Architecture:** RISC-V 32-bit Integer (RV32I) Single-Cycle
* **Language:** SystemVerilog
* **Instruction Set:** RV32I Base Integer Instruction Set 지원
    * **R-type:** `add`, `sub`, `xor`, `or`, `and`, `sll`, `srl`, `sra`, `slt`, `sltu`
    * **I-type:** `addi`, `xori`, `ori`, `andi`, `slli`, `srli`, `srai`, `slti`, `sltiu`, `lb`, `lh`, `lw`, `lbu`, `lhu`, `jalr`
    * **S-type:** `sb`, `sh`, `sw`
    * **B-type:** `beq`, `bne`, `blt`, `bge`, `bltu`, `bgeu`
    * **U-type:** `lui`, `auipc`
    * **J-type:** `jal`
* **Memory Structure:** Harvard Architecture (Instruction Memory와 Data Memory 분리)

---

## 🏗 시스템 구조 (System Architecture)

### 1. 전체 블록 다이어그램 (Block Diagram)
전체 시스템은 `RV32I_TOP` 모듈을 최상위로 하여 **Datapath**와 **Control Unit**으로 구성됩니다.

<img width="568" height="459" alt="image" src="https://github.com/user-attachments/assets/76a89adb-ce38-490e-b621-d233fa357613" />


### 2. 주요 모듈 설명 (Module Description)

| 모듈명 (Module) | 역할 (Description) |
| :--- | :--- |
| **RV32I_TOP** | 프로세서의 최상위 모듈. Datapath와 Control Unit을 연결하고 메모리 인터페이스를 관리합니다. |
| **datapath** | PC, 레지스터 파일(RegFile), ALU, Immediate Generator 등 데이터 처리 로직을 포함합니다. |
| **control_unit** | 명령어(Opcode, Funct3, Funct7)를 해독하여 ALU 제어 신호 및 Mux 선택 신호를 생성합니다. |
| **instruction_memory** | 기계어 코드(`code2.txt`)를 로드하여 프로세서에 명령어를 공급합니다. |
| **data_memory** | Load/Store 명령어를 위한 데이터 저장소입니다. |
| **alu** | 산술 및 논리 연산을 수행합니다. |

---

## 🛠 개발 환경 (Environment)
* **Design & Verification:** SystemVerilog
* **Simulation Tool:** Xilinx Vivado / ModelSim / Questasim
* **Synthesis Tool:** Xilinx Vivado

---

## 📂 파일 구조 (File Structure)
```text
├── src/
│   ├── RV32I_TOP.sv        # [TOP] Processor Top Module
│   ├── datapath.sv         # Datapath (ALU, RegFile, PC, etc.)
│   ├── control_unit.sv     # Main Control & ALU Control
│   ├── instruction.sv      # Instruction Memory
│   ├── data_mem.sv         # Data Memory
│   └── define.sv           # Opcode & Control Signal Definitions
├── simulation/
│   ├── tb_RV32I.sv         # Testbench (Not included in upload, assumed)
│   └── code2.txt           # Test Program (Machine Code)
└── docs/
    └── RV32I_채준희.pptx    # Project Presentation
