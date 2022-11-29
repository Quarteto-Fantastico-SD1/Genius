/* Converte  um número binário de 8 bits em 
um número BCD , formado por unidades (UNI), dezenas (DEZ)
e centenas (CENT)
entrada: 
saída: 
 */
module binary_to_BCD(A,UNI,DEZ,CENT);
/* .

Com 8 bits, podemos ter até o número 255. 
Assim, UNI e DEZ variam de 0 a 9, utilizando 4 bits
e CENT varia de 0 a 2, utilizando 2 bits.
*/


input [7:0] A; //Declara a entrada A de 8 bits
output [3:0] UNI, DEZ; // Declara as saídas UNI e DEZ de 4 bits
output [1:0] CENT; // Declara a saída CENT de 2 bits

// Declarando fios de 4 bits
wire [3:0] c1,c2,c3,c4,c5,c6,c7; 
wire [3:0] d1,d2,d3,d4,d5,d6,d7;


assign d1 = {1'b0,A[7:5]};  
assign d2 = {c1[2:0],A[4]};
assign d3 = {c2[2:0],A[3]};
assign d4 = {c3[2:0],A[2]};
assign d5 = {c4[2:0],A[1]};
assign d6 = {1'b0,c1[3],c2[3],c3[3]};
assign d7 = {c6[2:0],c4[3]};

// Corrigindo com o modulo add3
add3 m1(d1,c1);
add3 m2(d2,c2);
add3 m3(d3,c3);
add3 m4(d4,c4);
add3 m5(d5,c5);
add3 m6(d6,c6);
add3 m7(d7,c7);

assign UNI = {c5[2:0],A[0]};
assign DEZ = {c7[2:0],c5[3]};
assign CENT = {c6[3],c7[3]};
endmodule
