/* módulo da peça principal, o próprio genius */
module top(output [2:0] genius_led0, genius_led1, genius_led2, genius_led3, output [3:0] an_n, input clk, btnC, btnU, input [3:0] genius_buttons_n,
           output [7:0] lcd_data, seg_n, output lcd_regsel, lcd_enable, buzzer, input [1:0] sw);

    /* VARIÁVEIS */ 
    // botões
    wire [3:0] genius_buttons = ~genius_buttons_n; // active high
    wire p0, p1, p2, p3, p4, r0, r1, r2, r3, r4, h0, h1, h2, h3, h4; // fios para o debounce
    wire reset = btnC; // reset
    
    // LCD 
    wire lcd_available = 1;
    reg lcd_print;
    reg [8*16-1:0] topLCD, bottomLCD; 
    reg [28:0] lcd_timer;
    reg [26:0] timer; 
    reg timerReset;
    reg [26:0] timerResetVal;
    reg timerEn;
    reg [26:0] buzTimer;
    
    // random number generator
    reg [2:0] cor; 
    
    // variáveis de estado
    reg [31:0] state, nextState; 
    localparam VERMELHO = 001, VERDE = 010, AZUL = 100, AMARELO = 011, UNIecond = 100000000;
    localparam welcome = 0, waitVERMELHO = 1, geniusPrint = 2, geniusPlay = 3, userPlay = 4, playVERMELHO = 5, playVERDE = 6, playAZUL = 7, playAMARELO = 8, waitForPress = 9, 
        randomize = 10, geniusRest = 11, geniusCmp = 12, playerInit = 13, playerWaitForPress = 14, playerWaitForRelease = 15, playerCheck = 16, wincrement = 17, losecrement = 18,
        loseTone = 19, winTone = 20, playAgain = 21, winTone1 = 22, winTone2 = 23, loseTone1 = 24, loseTone2 = 25, cheatRepeat = 24;
    
    // pontuação
    reg [31:0] score; // contador
    reg scoreReset;
    reg scoreEn;
    wire [3:0] UNI, DEZ;
    reg [2:0] tone;
    reg random, step, buzzerEn, ledEn;
    wire [1:0] randomOutput;
    reg rerun;

    reg [31:0] geniusCount; 
    reg geniusCountReset, geniusCountEnable;
    
    // salvando botões
    reg [1:0] decodedButton, buttonSave;
    
    // contador do buzzer
    reg buzCounterReset, buzCountEn;
    reg [31:0] buzCount;
    
    wire [5:0] cheatRandom;
    reg [1:0] D, C, B, A;

    led_ctrl genius_cors (.led0(genius_led0), .led1(genius_led1), .led2(genius_led2), .led3(genius_led3), .clk(clk), .cor(cor), .enable(ledEn));
    
    lcd_string lcd_printer (.lcd_regsel(lcd_regsel), .lcd_enable(lcd_enable), .lcd_data(lcd_data), 
                  .available(lcd_available), .print(lcd_print), .topLCD(topLCD), .bottomLCD(bottomLCD), .reset(reset), .clk(clk) );
                  
    debouncer d1 (.pressed(p0), .released(r0), .held(h0), .button(genius_buttons[0]), .clk(clk), .reset(reset));
    debouncer d2 (.pressed(p1), .released(r1), .held(h1), .button(genius_buttons[1]), .clk(clk), .reset(reset));
    debouncer d3 (.pressed(p2), .released(r2), .held(h2), .button(genius_buttons[2]), .clk(clk), .reset(reset));
    debouncer d4 (.pressed(p3), .released(r3), .held(h3), .button(genius_buttons[3]), .clk(clk), .reset(reset));
    debouncer d5 (.pressed(p4), .released(r4), .held(h4), .button(btnU), .clk(clk), .reset(reset));
    
    PRNG pseudo_random (.cheatRandom(cheatRandom), .random(randomOutput), .rerun(rerun), .step(step), .randomize(random), .clk(clk), .reset(reset));
    
    binary_to_BCD score_coverter (.A(score), .UNI(UNI), .DEZ(DEZ));
    
    buzzer s1 (.buzzer(buzzer), .thing(tone), .clk(clk), .SE(buzzerEn));
    
    seg_ctrl seven_seg (.seg_n(seg_n), .an_n(an_n), .D(D), .C(C), .B(B), .A(A), .clk(clk));

    /* TIMER */
    // controlador do estado
    always @(posedge clk) begin
        if(reset)
            state <= welcome; // estado inicial
        else
            state <= nextState;
    end

    // LCD Timer
    always @(posedge clk) begin
        if (lcd_available) begin
            lcd_timer <= lcd_timer + 1;
        end
        if (lcd_timer >= 400000000) begin
            lcd_timer <= 0;
        end
    end

    // timer
    always @(posedge clk) begin
        if (timerReset)
            timer <= timerResetVal;
        else if (timerEn)
            timer <= timer - 1;
    end

    // pontuação
    always @(posedge clk) begin
        if(scoreReset)
            score <= 0;
        else if (scoreEn)
            score <= score + 1;
    end

    // contador de rodadas
    always @(posedge clk) begin
        if (geniusCountReset)
            geniusCount <= 0;
        else if (geniusCountEnable)
            geniusCount <= geniusCount + 1;
    end

    // contador dos sons de vitória e de derrota 
    always @(posedge clk) begin
        if (buzCounterReset)
            buzCount <= 0;
        else if (buzCountEn)
            buzCount <= buzCount + 1;

    end

    // identificando o botão que foi apertado
    always @* begin
        if (genius_buttons[0])
            decodedButton = 0;
        else if (genius_buttons[1])
            decodedButton = 1;
        else if (genius_buttons[2])
            decodedButton = 2;
        else if (genius_buttons[3])
            decodedButton = 3;
    end

    // geração de bits pseudo-aletórios
    always @* begin
            D = 0;
            C = 0;
            B = 0;
            A = 0;
        if (sw[0]) begin
            C = cheatRandom[1:0];
            B = cheatRandom[3:2];
            A = cheatRandom[5:4];
            D = randomOutput;
        end

    end

    /* MÁQUINA DE ESTADOS */
    always @* begin
        nextState = state;
        lcd_print = 0;
        scoreReset = 0;
        buzzerEn = 0;
        scoreEn = 0;
        timerResetVal = 0;
        timerReset = 0;
        timerEn = 0;
        random = 0;
        step = 0;
        geniusCountReset = 0;
        geniusCountEnable = 0;
        rerun = 0;
        ledEn = 0;
        buzCountEn = 0;
        buzCounterReset = 0;

        case(state)
            welcome: begin // Estágio inicial, apresentando o jogo
                if (lcd_available) begin
                    lcd_print = 1;
                    topLCD  =   "  GENIUS!  ";
                    bottomLCD = "    APERTE VERMELHO   "; 
                end

                if (p1) begin
                    scoreReset = 1;
                    nextState = randomize;
                    end
                end

            randomize: begin
                random = 1;
                if (r1) begin // soltar VERMELHO
                    timerResetVal = UNIecond;
                    timerReset = 1;
                    nextState = geniusPrint;
                end
                end    

            geniusPrint: begin
                if (lcd_available) begin
                    lcd_print = 1;
                    topLCD  =   "VEJA E REPITA!";
                    bottomLCD = {"SCORE: ", 4'b0011, DEZ, 4'b0011, UNI, "       "};
                    timerEn = 1;
                    end
                if(timer == 0) begin
                    geniusCountReset = 1;
                    timerResetVal = 0.75*UNIecond;
                    timerReset = 1;
                    nextState = geniusPlay;
                end
                end

            geniusPlay: begin
                if (lcd_available) begin
                    lcd_print = 1;
                    topLCD  =   "  VEZ DO GENIUS ";
                    bottomLCD = {"SCORE: ", 4'b0011, DEZ, 4'b0011, UNI, "       "};
                end
                tone = randomOutput;
                buzzerEn = 1;
                ledEn = 1;
                timerEn = 1;
                cor = randomOutput;
                if (timer == 0) begin
                    nextState = geniusRest;
                    timerResetVal = 0.25*UNIecond;
                    timerReset = 1;
                end
                end

            geniusRest: begin
                timerEn = 1;
                if (timer == 0)
                    nextState = geniusCmp;
            end

            geniusCmp: begin
                if (geniusCount == score) begin
                    geniusCountReset = 1;
                    nextState = playerInit;
                end
                else begin
                    geniusCountEnable = 1;
                    step = 1;
                    timerReset = 1;
                    timerResetVal = 0.75*UNIecond;
                    nextState = geniusPlay;
                end
            end

            playerInit: begin
                if (lcd_available) begin
                    lcd_print = 1;
                    topLCD  =   "   SUA VEZ!   ";
                    bottomLCD = {"SCORE: ", 4'b0011, DEZ, 4'b0011, UNI, "       "};
                end
                rerun = 1;
                geniusCountReset = 1;
                nextState = playerWaitForPress;
            end

            playerWaitForPress: begin
                if (p0 | p1 | p2 | p3) begin
                    buttonSave = decodedButton;
                    nextState = playerWaitForRelease;
                end
                else if (p4) begin 
                    rerun = 1;
                    geniusCountReset = 1;
                    timerResetVal = UNIecond;
                    timerReset = 1;
                    nextState = geniusPrint;

                end
            end

            playerWaitForRelease: begin
                tone = buttonSave;
                buzzerEn = 1;
                ledEn = 1;
                cor = buttonSave;
                if (r0 | r1 | r2 | r3)
                    nextState = playerCheck;
            end

            playerCheck: begin
                if (buttonSave == randomOutput) begin
                    step = 1;
                    geniusCountEnable = 1;
                    if (score == geniusCount) begin
                       nextState = wincrement;
                    end
                    else nextState = playerWaitForPress;
                end
                else begin
                    nextState = losecrement;
                end
            end

            wincrement: begin
                rerun = 1;
                scoreEn = 1;
                geniusCountReset = 1;
                timerResetVal = 0.5*UNIecond;
                timerReset = 1;
                nextState = winTone;
            end

            winTone: begin
                timerEn = 1; 
                tone = 5; 
                buzzerEn = 1;
                if (timer == 0) begin
                    timerResetVal = 0.5*UNIecond;
                    timerReset = 1;
                    nextState = winTone1;
                end
            end

            winTone1: begin
                timerEn = 1; 
                tone = 6; 
                buzzerEn = 1;
                if (timer == 0) begin
                    timerResetVal = 0.5*UNIecond;
                    timerReset = 1;
                    nextState = winTone2;
                end
            end

            winTone2: begin
                timerEn = 1; 
                tone = 7; 
                buzzerEn = 1;
                if (timer == 0) begin
                    timerResetVal = 0.5*UNIecond;
                    timerReset = 1;
                    nextState = geniusPrint;
                end
            end

            losecrement: begin
                rerun = 1;
                scoreReset = 1;
                geniusCountReset = 1;
                if (lcd_available) begin
                    lcd_print = 1;
                    topLCD  =   "      ERROUU!!     ";
                    bottomLCD = "         :(       ";
                end
                nextState = loseTone;
            end

            loseTone: begin
                timerEn = 1;
                tone = 7;
                buzzerEn = 1;       
                if (timer == 0)
                    nextState = loseTone1;
            end

             loseTone1: begin
                timerEn = 1; 
                tone = 6; 
                buzzerEn = 1;
                if (timer == 0) begin
                    timerResetVal = 0.5*UNIecond;
                    timerReset = 1;
                    nextState = loseTone2;
                end
            end

            loseTone2: begin
                timerEn = 1; 
                tone = 5; 
                buzzerEn = 1;
                if (timer == 0) begin
                    timerResetVal = 0.5*UNIecond;
                    timerReset = 1;
                    nextState = playAgain;
                end
            end

            playAgain: begin
            if (lcd_available) begin
                    lcd_print = 1;
                    topLCD  =   "  APERTE VERMELHO  ";
                    bottomLCD = "  PARA JOGAR DE NOVO   ";
                end
            if (p1) nextState = randomize;
            end
        endcase
    end
endmodule