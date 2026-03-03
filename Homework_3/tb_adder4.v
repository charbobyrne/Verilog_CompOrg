module tb_adder4;

    reg  [3:0] a, b;
    reg        cin;
    wire [3:0] sum;
    wire       cout;

    adder4 dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    task apply_and_show;
        input [3:0] aa;
        input [3:0] bb;
        input       cc;
        begin
            a   = aa;
            b   = bb;
            cin = cc;

            #50;  // Wait 50 ns
            $display("%4t   %b   %b  %b  |   %b    %b", $time, cin, a, b, cout, sum);
            
        end
    endtask

    initial begin
        $display("time  cin   a     b     | cout  sum");

        // Test cases
        apply_and_show(4'b0000, 4'b0000, 1'b0); // 0000 + 0000 (cin 0) = 0000 (cout = 0)
        apply_and_show(4'b0011, 4'b0101, 1'b0); // 0011 + 0101 (cin 0) = 1000 (cout = 0)
        apply_and_show(4'b1111, 4'b0001, 1'b0); // 1111 + 0001 (cin 0) = 0000 (cout = 1)
        apply_and_show(4'b0000, 4'b0000, 1'b1); // 0000 + 0000 (cin 1) = 0001 (cout = 0)
        apply_and_show(4'b1001, 4'b0110, 1'b1); // 1001 + 0110 (cin 1) = 0000 (cout = 1)

        $finish;
    end
endmodule