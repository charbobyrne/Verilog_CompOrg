module truth_table (
    input  wire A,
    input  wire B,
    input  wire C,
    output wire Y
);
    // Truth table: Y = A OR C
    assign Y = A | C;
endmodule