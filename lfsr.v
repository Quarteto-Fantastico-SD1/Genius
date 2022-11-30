/* Linear-Feedback shift register: usado como gerador de números pseudoaleatórios */

module LFSR #(parameter FILL=16'hACE1)(output [2:0] cheatRandom, output random, input step, rerun, randomize, clk, reset);

reg [15:0] lfsr, rerun_reg; // define estruturas de 16 posições para serem utilizadas 
reg randomize_d; // auxilia no armazenamento de um estado anterior do randomize
wire fb = lfsr[0] ^ lfsr[2] ^ lfsr[3] ^ lfsr[5]; // faz uma operação de XOR com alguns dos bits que estão no registrador principal
wire falling_edge_randomize  = ~randomize & randomize_d; // realiza uma combinação de dois estados da entrada randomize, sendo positiva quando há uma borda de descida 
assign random = lfsr[0]; // o último bit do lfsr será o número pseudoaleatório gerado pela operação
assign cheatRandom = lfsr[3:1]; // sequência de três bits pseudoaleatórios

always @(posedge clk) begin // realiza processo após borda de subida do clock
  if (reset) begin // reseta lfsr e rerun_reg para valor pré definido como parâmetro
    lfsr <= FILL; 
    rerun_reg <= FILL;
  end
  else begin
    randomize_d <= randomize;

    if (step | randomize) begin // coloca um novo bit pseudoaleatório na posição mais significativa do lfsr
      lfsr <={fb, lfsr[15:1]}; 
    end

    if (rerun) begin // armazena no lfsr um estado anterior dele armazenado previamente
      lfsr <= rerun_reg;
    end

    if (falling_edge_randomize) begin // armazena em uma estrutura auxiliar o estado do lfsruma borda de descida
      rerun_reg <= lfsr;
    end
  end
end
endmodule
