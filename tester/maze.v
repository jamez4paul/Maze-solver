`timescale 1ns / 1ps

module maze(
input 				clk,
input[5:0] 			starting_col, starting_row, 		// indicii punctului de start
input 				maze_in, 							// oferă informații despre punctul de coordonate [row, col]
output reg [5:0] 	row, col, 							// selectează un rând si o coloană din labirint
output reg			maze_oe,							// output enable (activează citirea din labirint la rândul și coloana date) - semnal sincron	
output reg			maze_we, 							// write enable (activează scrierea în labirint la rândul și coloana  date) - semnal sincron
output reg			done);		 						// ieșirea din labirint a fost gasită; semnalul rămane activ 

`define start 'd10
`define skip 'd19
`define citire 'd20
`define verif_dreapta 'd21
`define verif_inainte 'd22
`define verif 'd25

`define sus 0
`define dreapta 1
`define jos 2
`define stanga 3

reg [5:0] state = `start, next_state;
reg [1:0] directie; //directia actuala in labirint
reg [5:0] poz_row, poz_col; //pozitia actuala in labirint
reg [5:0] etapa, next_etapa; //etapa verificarii actuale inainte/dreapta

always @(posedge clk) begin
	state <= next_state;
	etapa <= next_etapa;
end

always @(*) begin
	maze_oe = 0;
	maze_we = 0;

	case(state)
		
		`start: begin
			//directia initiala
			directie = `dreapta;

			poz_row = starting_row;
			poz_col = starting_col;

			//marcarea pozitiei initiale
			row = starting_row;
			col = starting_col;
			maze_we = 1;

			next_etapa = `verif_dreapta;
			next_state = `verif;
		end

		`verif: begin
			case(etapa)
				`verif_dreapta: begin
					case(directie)
						`sus: begin
							row = poz_row;
							col = poz_col + 1;
						end
						`dreapta: begin
							row = poz_row + 1;
							col = poz_col;
						end
						`jos: begin
							row = poz_row;
							col = poz_col - 1;
						end
						`stanga: begin
							row = poz_row - 1;
							col = poz_col;
						end
					endcase
				end
				`verif_inainte: begin
					case(directie)
						`sus: begin
							row = poz_row - 1;
							col = poz_col;
						end
						`dreapta: begin
							row = poz_row;
							col = poz_col + 1;
						end
						`jos: begin
							row = poz_row + 1;
							col = poz_col;
						end
						`stanga: begin
							row = poz_row;
							col = poz_col - 1;
						end
					endcase
				end
			endcase

			//urmeaza citirea rezultatului setat prin row si col
			maze_oe = 1;
			next_state = `skip;
		end

		//sar un ciclu de ceas(debug)
		`skip: next_state = `citire;

		//stare pentru citirea lui maze_in si luarea unei decizii
		`citire: begin
			case(etapa)
			`verif_dreapta: begin
				//daca avem drum la dreapta rotim directia spre dreapta si avansam
				if(maze_in == 0) begin
					directie = directie + 1;
				
					maze_we = 1;

					//actualizare pozitie curenta
					poz_row = row;
					poz_col = col;
					
					next_etapa = `verif_dreapta;
					next_state = `verif;
					
				end
				//daca nu avem drum la dreapta ne uitam inainte
				else if(maze_in == 1) begin
						next_etapa = `verif_inainte;
						next_state = `verif;
					end
				end
			`verif_inainte: begin
				//daca avem drum inainte avansam
				if(maze_in == 0) begin
			
					maze_we = 1;

					//actualizare pozitie curenta
					poz_row = row;
					poz_col = col;
					
					next_etapa = `verif_dreapta;
					next_state = `verif;
					
				end
				//daca nu avem drum inainte rotim directia 180 grade si verificam dreapta
				else if(maze_in == 1) begin
						directie = directie - 2;

						next_etapa = `verif_dreapta;
						next_state = `verif;
					end
				end
			endcase

			//verificare final
			if(poz_row == 63 || poz_row == 0 || poz_col == 63 || poz_col == 0) begin
				row = poz_row;
				col = poz_col;
				done = 1;
				//stare finala
				next_state = 'b0;
			end
		end
		'b0: ;
		default: ;
	endcase
end

endmodule