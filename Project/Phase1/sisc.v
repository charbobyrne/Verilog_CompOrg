// ECE:3350 SISC processor project
// main SISC module, part 1
// This File needs to be complete for Project 1

`timescale 1ns/100ps  

module sisc (clk, rst_f, ir);

  input clk, rst_f;
  input [31:0] ir;

  // declare all internal wires here

  
  // Instruction fields
 
  wire [3:0] opcode    = ir[31:28];
  wire [3:0] mm        = ir[27:24];
  wire [3:0] write_reg = ir[23:20];
  wire [3:0] read_rega = ir[19:16];
  wire [3:0] read_regb = ir[15:12];
  wire [15:0] imm      = ir[15:0];

  
  // Control signals
  
  wire        rf_we;
  wire        wb_sel;
  wire [3:0]  alu_op;

  
  // Datapath signals
  
  wire [31:0] rsa, rsb;
  wire [31:0] alu_result;
  wire [3:0]  alu_stat;
  wire [3:0]  stat_en;
  wire [3:0]  stat_out;
  wire [31:0] write_data;

  // Carry-in to ALU comes from saved status register carry bit
  wire c_in = stat_out[3];



// component instantiation goes here

// Control unit (FSM)
  ctrl my_ctrl (
    .clk(clk),
    .rst_f(rst_f),
    .opcode(opcode),
    .mm(mm),
    .stat(stat_out),
    .rf_we(rf_we),
    .alu_op(alu_op),
    .wb_sel(wb_sel)
  );

  // Register file
  rf my_rf (
    .clk(clk),
    .read_rega(read_rega),
    .read_regb(read_regb),
    .write_reg(write_reg),
    .write_data(write_data),
    .rf_we(rf_we),
    .rsa(rsa),
    .rsb(rsb)
  );

  // ALU
  // Note: funct is provided as mm (ir[27:24]) for REG_OP-type instructions.
  alu my_alu (
    .clk(clk),
    .rsa(rsa),
    .rsb(rsb),
    .imm(imm),
    .c_in(c_in),
    .alu_op(alu_op),
    .funct(mm),
    .alu_result(alu_result),
    .stat(alu_stat),
    .stat_en(stat_en)
  );

  // Status register
  statreg my_statreg (
    .clk(clk),
    .in(alu_stat),
    .enable(stat_en),
    .out(stat_out)
  );

  // Writeback mux
  // Part 1: writeback should come from ALU result for these instructions.
  // in_b is a placeholder for future parts
  mux32 my_wbmux (
    .in_a(alu_result),
    .in_b(32'h00000000),
    .sel(wb_sel),
    .out(write_data)
  );
  
// put a $monitor statement here.
initial begin
  $monitor("t=%0t IR=%h R1=%h R2=%h R3=%h R4=%h R5=%h ALU_OP=%h WB_SEL=%b RF_WE=%b WD=%h",
           $time, ir,
           my_rf.ram_array[1],
           my_rf.ram_array[2],
           my_rf.ram_array[3],
           my_rf.ram_array[4],
           my_rf.ram_array[5],
           alu_op, wb_sel, rf_we, write_data);
end 



endmodule


