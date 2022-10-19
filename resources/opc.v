module not_gate(I, O);
    input I;
    output O;
    assign O = !I;
endmodule

module buf_gate(I, O);
    input I;
    output O;
    assign O = I;
endmodule

module tinv(I, O, EN);
    input I;
    output O;
    input EN;
    assign O = EN ? !I : 1'bz;
endmodule

module tbuf(I, O, EN);
    input I;
    output O;
    input EN;
    assign O = EN ? I : 1'bz;
endmodule

module nand_gate(A, B, O);
    input A, B;
    output O;
    assign O = !(A && B);
endmodule

module nor_gate(A, B, O);
    input A, B;
    output O;
    assign O = !(A || B);
endmodule

module and_gate(A, B, O);
    input A, B;
    output O;
    assign O = A && B;
endmodule

module or_gate(A, B, O);
    input A, B;
    output O;
    assign O = A || B;
endmodule

module xor_gate(A, B, O);
    input A, B;
    output O;
    assign O = (A ^ B);
endmodule

module xnor_gate(A, B, O);
    input A, B;
    output O;
    assign O = !(A ^ B);
endmodule

module mux(IP, IN, SEL, O);
    input IP, IN, SEL;
    output O;
    assign O = SEL ? IP : IN;
endmodule

module dffpq(D, Q, CLK);
    input D, CLK;
    output reg Q;
    always @(posedge CLK) begin
        Q <= D;
    end
endmodule

module dffnq(D, Q, CLK);
    input D, CLK;
    output reg Q;
    always @(negedge CLK) begin
        Q <= D;
    end
endmodule

module dffprq(D, Q, CLK, RESET);
    input D, CLK, RESET;
    output reg Q;
    always @(posedge CLK, negedge RESET) begin
        if(!RESET) begin
            Q <= 0;
        end
        else begin
            Q <= D;
        end
    end
endmodule

module dffnrq(D, Q, CLK, RESET);
    input D, CLK, RESET;
    output reg Q;
    always @(negedge CLK, negedge RESET) begin
        if(!RESET) begin
            Q <= 0;
        end
        else begin
            Q <= D;
        end
    end
endmodule

module dffpsq(D, Q, CLK, SET);
    input D, CLK, SET;
    output reg Q;
    always @(posedge CLK, negedge SET) begin
        if(!SET) begin
            Q <= 1;
        end
        else begin
            Q <= D;
        end
    end
endmodule

module dffnsq(D, Q, CLK, SET);
    input D, CLK, SET;
    output reg Q;
    always @(negedge CLK, negedge SET) begin
        if(!SET) begin
            Q <= 1;
        end
        else begin
            Q <= D;
        end
    end
endmodule

module dffprsq(D, Q, CLK, SET, RESET);
    input D, CLK, RESET, SET;
    output reg Q;
    always @(posedge CLK, negedge RESET, negedge SET) begin
        if(!RESET) begin
            Q <= 0;
        end
        else if(!SET) begin
            Q <= 1;
        end
        else begin
            Q <= D;
        end
    end
endmodule

module dffnrsq(D, Q, CLK, RESET, SET);
    input D, CLK, RESET, SET;
    output reg Q;
    always @(negedge CLK, negedge RESET, negedge SET) begin
        if(!RESET) begin
            Q <= 0;
        end
        else if(!SET) begin
            Q <= 1;
        end
        else begin
            Q <= D;
        end
    end
endmodule

module dffpqn(D, QN, CLK);
    input D, CLK;
    output reg QN;
    always @(posedge CLK) begin
        QN <= !D;
    end
endmodule

module dffnqn(D, QN, CLK);
    input D, CLK;
    output reg QN;
    always @(negedge CLK) begin
        QN <= !D;
    end
endmodule

module dffprqn(D, QN, CLK, RESET);
    input D, CLK, RESET;
    output reg QN;
    always @(posedge CLK, negedge RESET) begin
        if(!RESET) begin
            QN <= 1;
        end
        else begin
            QN <= !D;
        end
    end
endmodule

module dffnrqn(D, QN, CLK, RESET);
    input D, CLK, RESET;
    output reg QN;
    always @(negedge CLK, negedge RESET) begin
        if(!RESET) begin
            QN <= 1;
        end
        else begin
            QN <= !D;
        end
    end
endmodule

module dffpsqn(D, QN, CLK, SET);
    input D, CLK, SET;
    output reg QN;
    always @(posedge CLK, negedge SET) begin
        if(!SET) begin
            QN <= 0;
        end
        else begin
            QN <= !D;
        end
    end
endmodule

module dffnsqn(D, QN, CLK, SET);
    input D, CLK, SET;
    output reg QN;
    always @(negedge CLK, negedge SET) begin
        if(!SET) begin
            QN <= 0;
        end
        else begin
            QN <= !D;
        end
    end
endmodule

module dffprsqn(D, QN, CLK, SET, RESET);
    input D, CLK, RESET, SET;
    output reg QN;
    always @(posedge CLK, negedge RESET, negedge SET) begin
        if(!RESET) begin
            QN <= 1;
        end
        else if(!SET) begin
            QN <= 0;
        end
        else begin
            QN <= !D;
        end
    end
endmodule

module dffnrsqn(D, QN, CLK, RESET, SET);
    input D, CLK, RESET, SET;
    output reg QN;
    always @(negedge CLK, negedge RESET, negedge SET) begin
        if(!RESET) begin
            QN <= 1;
        end
        else if(!SET) begin
            QN <= 0;
        end
        else begin
            QN <= !D;
        end
    end
endmodule

