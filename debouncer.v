module debouncer (output apertado, solto, segurado, input button, clk, reset);
/* Módulo para evitar o efeito de debounce, evitando que sejam identificados
múltiplos apertos do botão quando ele só foi pressionado uma única vez.
Indica se o botão foi pressionado , solto ou segurado */

	localparam sampletime = 1999999;
	reg [20:0] timer;
	reg button_temp, button_debounced, button_debounced_temp;

//Aplica um delay, diminuindo o sampletime a cada descida do clock
	always @(posedge clk)
	if (reset)
		timer <= sampletime;
	else begin
		timer <= timer - 1;
		if (timer == 0)
			timer <= sampletime;
	end


	always @(posedge clk) begin
		button_debounced_temp <= button_debounced; //Estado anterior do botão

        //Se o delay tiver passado:
		if (timer == 0) begin
			button_temp <= button;
			if (button == button_temp)
				button_debounced <= button;
		end
	end

	assign segurado = button_debounced; // Se o botao está ativo
	assign apertado = button_debounced & ~button_debounced_temp; //Se o botão não estava ativo e ficou ativo
	assign solto = ~button_debounced & button_debounced_temp; // Se o botão estava ativo e ficou inativo
endmodule