# Lab: Specification and Simulation of Digital System

## Overview
The project focuses on designing a **Control Unit (CU)** and an **Execution Unit (EU)** for finding the **longest increasing sequence** stored in RAM memory. The result includes the starting address and length of the sequence, which are saved to the last two locations of the RAM.

## Objectives
- Implement a **RAM memory module** to store input sequences.
- Design a **Control Unit** to manage sequential read/write operations in RAM.
- Implement an **Execution Unit** to compute the longest increasing sequence efficiently.
- Verify the correctness of the system through waveform simulations.

---

## Components

### 1. RAM Memory
- **Description**: A 32x8 RAM memory initialized with predefined content. The memory contains multiple increasing sequences, but the algorithm identifies the longest one.
- **Operation**:
   - Performs sequential read and write operations.
   - Stores the starting address and length of the longest increasing sequence in its final two locations.

---

### 2. Control Unit (CU)
- **Description**: The CU orchestrates interactions between the RAM and Execution Unit.
- **Key Features**:
   - Reads data sequentially from the RAM and passes it to the Execution Unit.
   - Manages two registers to store the starting address and sequence length.
   - Writes the computed results to the final two RAM locations.

---

### 3. Execution Unit (EU)
- **Description**: The EU processes incoming data from the CU to compute the longest increasing sequence.
- **Algorithm**:
   - Compares consecutive values to identify increasing sequences.
   - Updates registers to track the current sequence and identify the longest sequence.
   - Ensures the starting address and sequence length are correctly saved.

---

## Final Circuit
The final circuit integrates the **RAM**, **Control Unit**, and **Execution Unit**. The system processes the RAM data, computes the results, and writes them back to memory.

---

## Tools Used
- **Vivado**: Project implementation and simulation.
- **VHDL**: Design of the RAM, Control Unit, Execution Unit, and respective testbenches.

---

## Conclusion
This project successfully demonstrates the design, simulation, and verification of a **Control Unit** and **Execution Unit** for processing digital memory data. The implemented system efficiently identifies the longest increasing sequence in RAM and stores the results in predefined locations.

---

## Files
- `SequenceDetector.vhd`
- `ControlUnit.vhd`
- `ExecutionUnit.vhd`
- `TestbenchSequenceDetector.vhd`
- `TestbenchControlUnit.vhd`
- `TestbenchRAM.vhd`
