module led_ctrl(output reg [2:0] led0, led1, led2, led3, input [1:0] cor, input enable, clk);
/* Acende o led correspondente a entrada cor */


localparam VERMELHO = 3'b001, VERDE = 3'b010, AZUL = 3'b100, AMARELO = 3'b011, APAGADO = 3'b000,ms = 100000;

reg [18:0] timer;

always @* begin
    if (timer < ms - 1) begin
        led0 = VERDE;
        led1 = VERMELHO;
        led2 = AZUL;
        led3 = AMARELO;
    end
    else begin
        led0 = APAGADO;
        led1 = APAGADO;
        led2 = APAGADO;
        led3 = APAGADO;
    end
    if (enable) begin
        case(cor)
            0: led0 = VERDE;
            1: led1 = VERMELHO;
            2: led2 = AZUL;
            3: led3 = AMARELO;
        endcase
    end
end

always @(posedge clk) begin
    if (timer ==  0)
        timer <= 5*ms -1;
    else
        timer <= timer - 1;
end


endmodule
