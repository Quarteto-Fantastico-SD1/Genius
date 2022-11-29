/* aditor de três unidades */
module add3(in, out);
    /* retorna:
        (i) o próprio número, se menor que 4;
        (ii) o número somado de 3 unidades, se maior que 4 e menor que 9;
        (iii) 0, se maior que 9;
     */

    input [3:0] in; // Declara uma entrada in de 4 bits
    output [3:0] out; // Declara uma saída out de 4 bits
    reg [3:0] out; // Setando out como um registrador de 4 bits

    always @ (in) // Sempre que a entrada in mudar de valor:
    // Soma 3 aos números maiores que 4
    // Caso o número seja maior que 9, o padrão é 0
        case (in)
        4'b0000: out <= 4'b0000;
        4'b0001: out <= 4'b0001;
        4'b0010: out <= 4'b0010;
        4'b0011: out <= 4'b0011;
        4'b0100: out <= 4'b0100;
        4'b0101: out <= 4'b1000;
        4'b0110: out <= 4'b1001;
        4'b0111: out <= 4'b1010;
        4'b1000: out <= 4'b1011;
        4'b1001: out <= 4'b1100;
        default: out <= 4'b0000;
        endcase
endmodule
