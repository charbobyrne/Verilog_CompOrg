// ECE:3350 SISC processor project
// main SISC module, part 2

`timescale 1ns/100ps

module sisc (clk, rst_f);

  input clk, rst_f;

  // Existing control signals from part 1
  wire rf_we, wb_sel;
  wire [3:0] alu_op;

  // New control signals for part 2
  // br_sel chooses absolute or relative branch address generation
  // pc_rst resets the program counter to zero
  // pc_write allows the program counter to update
  // pc_sel chooses PC plus one or branch target
  // ir_load loads the fetched instruction into the instruction register
  wire br_sel, pc_rst, pc_write, pc_sel, ir_load;

  // Status related wires
  wire [3:0] alu_sts, stat, stat_en;

  // Datapath wires from part 1
  wire [31:0] rega, regb, wr_dat, alu_out;

  // New instruction fetch wires for part 2
  wire [15:0] pc_out, br_addr;
  wire [31:0] im_read_data, instr;

  // Control unit
  // Now decodes the instruction from the instruction register
  // Also drives the new PC and branch control signals
  ctrl u1 (
    clk,
    rst_f,
    instr[31:28],
    instr[27:24],
    stat,
    rf_we,
    alu_op,
    wb_sel,
    br_sel,
    pc_rst,
    pc_write,
    pc_sel,
    ir_load
  );

  // Register file
  // Still uses Rs Rt and Rd fields from the current instruction
  rf u2 (
    clk,
    instr[19:16],
    instr[15:12],
    instr[23:20],
    wr_dat,
    rf_we,
    rega,
    regb
  );

  // Arithmetic logic unit
  // Still uses the immediate field and MFF field from the current instruction
  alu u3 (
    clk,
    rega,
    regb,
    instr[15:0],
    stat[3],
    alu_op,
    instr[27:24],
    alu_out,
    alu_sts,
    stat_en
  );

  // Writeback mux
  mux32 u5 (
    alu_out,
    32'h00000000,
    wb_sel,
    wr_dat
  );

  // Status register
  statreg u6 (
    clk,
    alu_sts,
    stat_en,
    stat
  );

  // New branch address unit
  // Uses the current PC value and the instruction target field
  // Produces either absolute or relative branch target
  br u7 (
    pc_out,
    instr[15:0],
    br_sel,
    br_addr
  );

  // New instruction memory
  // Reads instruction using the current PC value
  im u8 (
    pc_out,
    im_read_data
  );

  // New instruction register
  // Latches the fetched instruction during the fetch state
  ir u9 (
    clk,
    ir_load,
    im_read_data,
    instr
  );

  // New program counter
  // Advances to next instruction or loads branch target
  pc u10 (
    clk,
    br_addr,
    pc_sel,
    pc_write,
    pc_rst,
    pc_out
  );

  // Monitor
  // Now shows fetched instruction and PC in addition to the part 1 signals
  initial
    $monitor(
      "t=%0t PC=%h IR=%h R1=%h R2=%h R3=%h R4=%h R5=%h STAT=%h ALU_OP=%h WB_SEL=%b RF_WE=%b PC_SEL=%b PC_WRITE=%b IR_LOAD=%b BR_SEL=%b WD=%h",
      $time,
      pc_out,
      instr,
      u2.ram_array[1],
      u2.ram_array[2],
      u2.ram_array[3],
      u2.ram_array[4],
      u2.ram_array[5],
      stat,
      alu_op,
      wb_sel,
      rf_we,
      pc_sel,
      pc_write,
      ir_load,
      br_sel,
      wr_dat
    );

endmodule