// Gerador de números pseudoaleatórios (Pseudorandom number generator)
// Utiliza duas instâncias de lfsr's para compor p prng, o qual irá gerar uma sequência de dois bits pseudoaleatórios

module PRNG (output [5:0] cheatRandom, output [1:0] random, input step, rerun, randomize, clk,reset);


  LFSR u1 (.cheatRandom({cheatRandom[4], cheatRandom[2], cheatRandom[0]}), .random(random[0]), .step(step), .rerun(rerun), .randomize(randomize), .clk(clk), .reset(reset));

  LFSR #(.FILL(16'h0001)) u3 (.cheatRandom({cheatRandom[5], cheatRandom[3], cheatRandom[1]}), .random(random[1]), .step(step), .rerun(rerun), .randomize(randomize), .clk(clk), .reset(reset));
 

endmodule
