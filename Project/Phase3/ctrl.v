// ECE:3350 SISC computer project
// finite state machine
// part 2 control unit

`timescale 1ns/100ps

module ctrl (
  clk,
  rst_f,
  opcode,
  mm,
  stat,
  rf_we,
  alu_op,
  wb_sel,
  br_sel,
  pc_rst,
  pc_write,
  pc_sel,
  ir_load,
  mm_sel,
  dm_we,
  rb_sel
);

  input clk, rst_f;
  input [3:0] opcode, mm, stat;

  output reg rf_we, wb_sel;
  output reg [3:0] alu_op;

  // New part 2 control outputs
  // br_sel chooses absolute or relative branch address generation
  // pc_rst resets the program counter to zero
  // pc_write allows the program counter to update
  // pc_sel chooses between PC plus one and the branch address
  // ir_load loads the fetched instruction into the instruction register
  output reg br_sel, pc_rst, pc_write, pc_sel, ir_load;
  
  // Part 3 control Outputs
  // mm_sel selects the memory address source
  // dm_we enables writing to data memory
  // rb_sel selects register B for STX
  output reg mm_sel, dm_we, rb_sel;


  // states
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3, execute = 4, mem = 5, writeback = 6;
   
  // opcodes
  parameter NOOP = 0, REG_OP = 1, REG_IM = 2, SWAP = 3, BRA = 4, BRR = 5, BNE = 6, BNR = 7;
  parameter JPA = 8, JPR = 9, LOD = 10, STR = 11, CALL = 12, RET = 13, HLT = 15;
	
  // state registers
  reg [2:0] present_state, next_state;

  initial
    present_state = start0;

  // state register
  always @(posedge clk, negedge rst_f)
  begin
    if (rst_f == 1'b0)
      present_state <= start1;
    else
      present_state <= next_state;
  end

  // next-state logic
  always @(present_state, rst_f)
  begin
    case (present_state)
      start0:
        next_state = start1;
      start1:
        if (rst_f == 1'b0)
          next_state = start1;
        else
          next_state = fetch;
      fetch:
        next_state = decode;
      decode:
        next_state = execute;
      execute:
        next_state = mem;
      mem:
        next_state = writeback;
      writeback:
        next_state = fetch;
      default:
        next_state = start1;
    endcase
  end

  // halt on HLT instruction
  always @(opcode)
  begin
    if (opcode == HLT)
    begin
      #5 $display("Halt.");
      $finish;
    end
  end

  // output logic
  always @(present_state, opcode, mm, stat)
  begin
    // Existing part 1 defaults
    rf_we    = 1'b0;
    wb_sel   = 1'b0;
    alu_op   = 4'b0000;

    // New part 2 defaults
    br_sel   = 1'b0;
    pc_rst   = 1'b0;
    pc_write = 1'b0;
    pc_sel   = 1'b0;
    ir_load  = 1'b0;

    // New part 3 defaults
    mm_sel = 1'b0;
    dm_we  = 1'b0;
    rb_sel = 1'b0;
        
    case (present_state)

      // New part 2 reset behavior
      // Hold PC at zero while in start1
      start1:
      begin
        pc_rst = 1'b1;
      end

      // New part 2 fetch behavior
      // Load IR from instruction memory and advance PC to next instruction
      fetch:
      begin
        pc_write = 1'b1;
        pc_sel   = 1'b0;
        ir_load  = 1'b1;
      end

      // New part 2 branch decode behavior
      // Branch condition is checked here
      // BRA and BRR branch when mm AND stat is not zero
      // BNE and BNR branch when mm AND stat is zero
      // BRA and BNE are absolute
      // BRR and BNR are relative
      decode:
      begin
        if (opcode == BRA)
        begin
          if ((mm & stat) != 4'b0000)
          begin
            pc_sel   = 1'b1;
            pc_write = 1'b1;
            br_sel   = 1'b1;
          end
        end

        if (opcode == BRR)
        begin
          if ((mm & stat) != 4'b0000)
          begin
            pc_sel   = 1'b1;
            pc_write = 1'b1;
            br_sel   = 1'b0;
          end
        end

        if (opcode == BNE)
        begin
          if ((mm & stat) == 4'b0000)
          begin
            pc_sel   = 1'b1;
            pc_write = 1'b1;
            br_sel   = 1'b1;
          end
        end

        if (opcode == BNR)
        begin
          if ((mm & stat) == 4'b0000)
          begin
            pc_sel   = 1'b1;
            pc_write = 1'b1;
            br_sel   = 1'b0;
          end
        end
      end

      // Existing part 1 ALU execute behavior
      execute:
      begin
        if (opcode == REG_OP)
          alu_op = 4'b0001;
        if (opcode == REG_IM)
          alu_op = 4'b0011;
        // part 3: setting rb_sel one stage earlier so it functions
        // properly in mem
        if (opcode == STR && mm == 4'b0000)
          rb_sel = 1'b1;
        if (opcode == STR && mm == 4'b1000)
          rb_sel = 1'b1;
      end

      // Existing part 1 ALU mem-stage hold behavior
      // and additional part 3 components
      mem:
      begin
        if (opcode == REG_OP)
          alu_op = 4'b0000;
        if (opcode == REG_IM)
          alu_op = 4'b0010;
        if (opcode == STR && mm == 4'b0000)
        begin
          dm_we  = 1'b1;
          mm_sel = 1'b0;
          rb_sel = 1'b1;
        end
        if (opcode == STR && mm == 4'b1000)
        begin
          dm_we  = 1'b1;
          mm_sel = 1'b1;
          rb_sel = 1'b1;
        end
        if (opcode == LOD && mm == 4'b0000)
        begin
          mm_sel = 1'b0;
        end
        if (opcode == LOD && mm == 4'b1000)
        begin
          mm_sel = 1'b1;
        end
      end

      // Existing part 1 writeback behavior
      // and part 3 load logic
      writeback:
      begin
        if (opcode == REG_OP || opcode == REG_IM)
          rf_we = 1'b1;
        if (opcode == LOD && mm == 4'b0000)
        begin
          rf_we  = 1'b1;
          wb_sel = 1'b1;
          mm_sel = 1'b0;
        end
        if (opcode == LOD && mm == 4'b1000)
        begin
          rf_we  = 1'b1;
          wb_sel = 1'b1;
          mm_sel = 1'b1;
        end
      end

      default:
      begin
        rf_we    = 1'b0;
        wb_sel   = 1'b0;
        alu_op   = 4'b0000;
        br_sel   = 1'b0;
        pc_rst   = 1'b0;
        pc_write = 1'b0;
        pc_sel   = 1'b0;
        ir_load  = 1'b0;
        mm_sel   = 1'b0;
        dm_we    = 1'b0;
        rb_sel   = 1'b0;
      end
      
    endcase
  end

endmodule