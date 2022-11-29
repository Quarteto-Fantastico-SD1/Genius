/* controle do lcd pelos pinos lcd_*** */
module lcd_ctrl(output reg lcd_regsel, // registrador do pino seletor do lcd
                output lcd_read, // leitor do pino lcd (não usado nesse projeto)
				output reg lcd_enable, // pino de saída lcd, controlado por este módulo
				output reg ready, // indica se a instanciação do módulo está pronta
				inout [7:0] lcd_data, // dados do lcd (podem ser lidos ou alterados)
                input [7:0] din, // dados a serem envidados para o lcd
				input activate, // sinal indicativo para iniciar o enable de 2ms
				input  regsel, // A entrada do regsel
				input reset, 
				clk);

    /* 
    Sinal de ativação => ativar o enable e esperar 1ms (para satisfazer ao timing do lcd)
    Na realidade, basta apenas 450ns, mas, como várias instruções levam pouco mais de 1.64ms, é
    vantajoso e seguro impor um tempo de espera de 2ms. A demora não é evidente no display.
    */

    reg [27:0] timer;
    reg activate_d;
    reg [7:0] data; // copia do din
    wire activate_pulse = activate & ~activate_d; // detector de borda de subida

    assign lcd_read = 0;
    assign lcd_data = lcd_read?8'bz:data;

    always @ (posedge clk or posedge reset) begin
      if (reset) begin
    	 timer <= 0;
    	 lcd_enable <= 0;
    	 lcd_regsel <= 0;
    	 ready <= 1;
    	 data <= 0;
      end
      else begin
        activate_d <= activate; // salva o sinal de ativação para a borda de subida
        /* com o pulsar do sinal de ativação, desativar o ready e escrever no lcd 
        colocar os inputs nos registradores (data e lcd_regsel) para salvá-los para duração da escrita.
        Aqui, estamos interessados apenas nas bordas de subida. Quando o ready desliga, esperamos pelo
        próximo pulso de ativação. Se a ativação acontece, mas não estamos preparados, apenas o ignoramos */

        if (activate_pulse & ready) begin
    		ready <= 0;
    		data <= din;
    		lcd_regsel <= regsel;
    	 end
    
         // iniciar a escrita no lcd, quando o ready desligar
    	 if (!ready ) begin
    	   timer <= timer+1; // contador em ciclos de 20ns
    		if (timer == 6) begin
    		  lcd_enable <= 1; // espera de 120ns antes de ligar o enable para garantir tempo para setup dos dados
    		end
    	   if (timer == 100000) begin // desliga o lcd após 1ms (450ns basta, mas 1ms deixa margem de segurança)
    		  lcd_enable <= 0;
    	   end
    		// Então, em 2ms, finalizar a transição e ligar o ready novamente  
    	   if (timer >= 200000) begin
    	     timer <= 0;
    		  ready <= 1;
    	   end
    	 end
      end
    end

    endmodule