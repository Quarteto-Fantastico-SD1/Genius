/* módulo dos auto-falantes */
module speaker(output reg speaker, input [2:0] thing, input clk, input SE);

    /* configura registradores para o contador e para o tom */
    reg [17:0] counter;
    reg [17:0] tone;

    /* configura as frequências a serem tocadas (tons/notas) */
    always @* begin
        case(thing)
        0: tone = 227272;
        1: tone = 202478;
        2: tone = 180384;
        3: tone = 170262;
        4: tone = 151686;
        5: tone = 135136;
        6: tone = 120392;
        7: tone = 113636;
        endcase
    end

    /* contador recebe valor do tom */
    initial begin
        counter <= tone;
    end

    /* executar na borda de descida do clock */
    always @(posedge clk) begin
        counter <= counter - 1;
        if (counter == 0) begin
            counter <= tone;
        end
    end

    always @* begin
        speaker = 0;
        if ((counter < tone/2)) begin
            speaker = SE;
        end
    end
endmodule