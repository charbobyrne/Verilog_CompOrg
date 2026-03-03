// 1-bit full adder given from Professor Najeeb
module fullAdder (a, b, cin, sum, cout);
    input a, b, cin;
    output sum, cout;
    reg sum, cout;

    always @(a or b or cin) begin
        sum  = #2 a ^ b ^ cin;
        cout = #2 (a & b)|(a & cin)|(b & cin);
    end
endmodule