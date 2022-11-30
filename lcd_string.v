/*O módulo recebe duas strings, com caractéres ASCII (como as do exemplo abaixo) , e as imprime

reg [8*16-1:0] topline, bottomline;
topline    = "0123456789ABCDEF";
bottomline = "  HELLO WORLD!  "; 
*/
module lcd_string(output lcd_regsel, lcd_read, lcd_enable, inout [7:0] lcd_data, 
                  output reg available,
                  input print, input [8*16-1:0] topline, bottomline, input reset, clk );
  
  localparam INIT = 0, FUNCTION_SET = 1, WAIT = 2, ENTRY_MODE_SET = 3, 
             DISPLAY_ON = 4, ENABLE = 5, CLEAR_DISPLAY = 6, RETURN_HOME = 7, 
          PRINT_LINE_1 = 8, PRINT_LINE_1_ADDR = 9, PRINT_LINE_1_CHAR = 10,
          PRINT_LINE_2 = 11, PRINT_LINE_2_ADDR = 12, PRINT_LINE_2_CHAR = 13;
  reg [7:0] state, next_state;
  reg [7:0] pending_state, next_pending_state;
  reg [7:0] data;
  reg activate, regsel;
  reg [7:0] address, next_address;
  reg [8*16-1:0] line1, line2, next_line1, next_line2;

  /*"chama" o lcd_ctrl. */
  lcd_ctrl lcd1 (.lcd_regsel(lcd_regsel), .lcd_read(lcd_read), .lcd_enable(lcd_enable), .lcd_data(lcd_data), 
                 .ready(ready), .din(data), .activate(activate), .regsel(regsel), 
            .reset(reset), .clk(clk) );

  always @* begin
    next_state = state;
    next_address = address;
    next_pending_state = pending_state;
    next_line1 = line1;
    next_line2 = line2;
    activate = 0;
    regsel = 0;
    data = 0;
    available = 0;
    case (state) 
      INIT: begin
       next_state = FUNCTION_SET;
     end
     FUNCTION_SET: begin
       regsel = 0;
       data = 8'b00111000; // Seta a interface de 8 bits
      activate = 1;
      next_state = ENABLE;
      next_pending_state = ENTRY_MODE_SET;
     end
     ENTRY_MODE_SET: begin
       regsel = 0;
       data = 8'b00000110; // Seta o cursor para realizar a movimentação para a direita
      activate = 1;
      next_state = ENABLE;	  
      next_pending_state = DISPLAY_ON;	
     end
     DISPLAY_ON: begin
       regsel = 0;
       data = 8'b00001111; //Liga o display e o cursor, indicando as ações
      activate = 1;
      next_state = ENABLE;
        next_pending_state = CLEAR_DISPLAY;
     end	
     CLEAR_DISPLAY: begin
       regsel = 0;
       data = 8'b00000001; // Reseta o display e a RAM para o 0
      activate = 1;
      next_state = ENABLE;
        next_pending_state = RETURN_HOME;
     end	
     RETURN_HOME: begin
       regsel = 0;
       data = 8'b00000010; // Seta o cursor para a posição 0,0
      activate = 1;
      next_state = ENABLE;
        next_pending_state = WAIT;
     end		 
      
     ENABLE: begin  
        activate = 0;
      if (ready)
        next_state = pending_state;
     end

     /* Ficará nesse ponto do códio até receber um comando para imprimir */
     WAIT: begin
       available = 1;
       if (print) begin
        next_state = PRINT_LINE_1;
        next_line1 = topline;
        next_line2 = bottomline;		
      end
     end
     PRINT_LINE_1: begin
      next_address = 8'h80;
      next_state = PRINT_LINE_1_ADDR;
     end
     PRINT_LINE_1_ADDR: begin
       activate = 1;
      data = address;
      next_state = ENABLE;
      next_pending_state = PRINT_LINE_1_CHAR;
     end
     PRINT_LINE_1_CHAR: begin
       activate = 1;
      regsel = 1;
       data = line1[16*8-1:16*8-8]; // Seta os dados para imprimir o próximo caractére
      next_state = ENABLE;
      next_address = address+1;
      next_line1 = line1 << 8; 
      if (address[3:0] == 4'hf) 
        next_pending_state = PRINT_LINE_2; // Avança para a próxima linha
      else 
        next_pending_state = PRINT_LINE_1_CHAR; 
     end
     PRINT_LINE_2: begin
      next_address = 8'hC0;
      next_state = PRINT_LINE_2_ADDR;
     end
     PRINT_LINE_2_ADDR: begin
       activate = 1;
      data = address;
      next_state = ENABLE;
      next_pending_state = PRINT_LINE_2_CHAR;
     end
     PRINT_LINE_2_CHAR: begin
       activate = 1;
      regsel = 1;
      data = line2[16*8-1:16*8-8];
      next_state = ENABLE;
      next_address = address+1;
      next_line2 = line2 << 8;
      if (address[3:0] == 4'hf) 
        next_pending_state = WAIT; // Volta para o início do WAIT
      else 
        next_pending_state = PRINT_LINE_2_CHAR;
     end
    endcase
  end

  always @ (posedge clk or posedge reset) begin
    if (reset) begin
      state <= INIT;
     pending_state <= INIT;
     address <= 0;
     line1 <= 0;
     line2 <= 0;
    end
    else begin
      state <= next_state;
     pending_state <= next_pending_state;
     address <= next_address;
     line1 <= next_line1;
     line2 <= next_line2;
    end
  end

endmodule
