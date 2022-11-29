/* display de sete segmentos */
module seven_seg(output reg [7:0] z, input [3:0] s);

/* entrada: s de 4 bits; saída: registrador z de 8 bits */
/* para cada valor de s, produz um número z correspondente ao número
que se deseja representar */

always @ * begin // Sempre que a entrada mudar de valor:
    case(s)
        0 : z = ~8'b00111111; // 0
        1 : z = ~8'b00000110; // 1
        2 : z = ~8'b01011011; // 2
        3 : z = ~8'b01001111; // 3
        4 : z = ~8'b01100110; // 4
        5 : z = ~8'b01101101; // 5
        6 : z = ~8'b01111101; // 6
        7 : z = ~8'b00000111; // 7
        8 : z = ~8'b01111111; // 8
        9 : z = ~8'b01101111; // 9
        10: z = ~8'b01110111; // A
        11: z = ~8'b01111100; // B
        12: z = ~8'b00111001; // C
        13: z = ~8'b01011110; // D
        14: z = ~8'b01111001; // E
        15: z = ~8'b01110001; // F
    endcase
end
endmodule