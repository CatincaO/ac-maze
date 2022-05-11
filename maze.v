`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:56:03 12/01/2021 
// Design Name: 
// Module Name:    maze 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module maze#(parameter maze_width = 6)( 
      input                        clk,
	  input [maze_width - 1:0]     starting_col, starting_row,
	  input                        maze_in,
      output reg[maze_width - 1:0] row, col,
      output reg                   maze_oe,
      output reg                   maze_we,
      output reg                   done		
    );

reg [maze_width:0] aux_row, aux_col;  //variabile auxiliare folosite pentru a retine starea anterioara
reg [1:0] dep; 
		//directie deplasare:
			//  0 -> E
			//  1 -> V
			//  2 -> S
			//  3 -> N
`define initializare                0
`define inceput                     1
`define deplasare                   3
`define verificare_pozitie          8
`define iesire                      9
`define pozitii                     10
`define rotire                      11
`define continuare_mers             12
`define pornire                     13
reg [maze_width-2:0] state=`initializare, next_state;
always @(posedge clk) begin
     if( done == 0)
        state <= next_state;
      else
	     state <= `iesire;
end			

always @(*) begin
       maze_we = 0;
	   maze_oe = 0;
	   done = 0;
      case(state)
		    `initializare: begin
		        maze_we       = 1;
				row           = starting_row;
				col           = starting_col;
                next_state = `pornire;
			end	
			`pornire: begin
			    dep           = 0; //pozitionam spre deplasare dreapta
				aux_row       = starting_row; //salvam coordonatele plecarii pt a astii starea precedenta
				aux_col       = starting_col;
				next_state    = `inceput;
			
				
		     end
			 `pozitii : begin
			    maze_oe = 1;
				//directiile initiale posibile de pelcare
				case(dep)
					0: col = col +1 ; //e(dreapta)
					1: col = col - 1; //v (vest)
					2: row = row +1; //s(jos)
					3: row = row - 1;//n (nord)
				endcase
				next_state =  `inceput;

				end
			  
			  `inceput: begin //in starea asta verificam in ce directie se poate incepe traseul prin labiritn
			      maze_oe = 1;
					case(dep)
					   0: begin
							if(maze_in == 0)begin //incercam la E, daca e liber continuam deplasarea pe aici
								  aux_col = col;
								  aux_row = row;
								  maze_we = 1;
								  next_state = `deplasare;
							 end else if(maze_in == 1) begin // daca nu e liber la E, vrem sa incercam deplasarea la dreapta estului, anume la S
								  dep = 2; //incercam sa ne deplasam spre S
								  col = aux_col; 
								  row = row +1; // crese linia la S
								  next_state = `deplasare;
								  
							end
						end	
                       1: begin
                            if(maze_in == 0)begin // incercam la V, daca e liber continuam deplasarea aici
								  aux_col = col;
								  aux_row = row;
								  maze_we = 1;
								  next_state = `deplasare;
							 end else if(maze_in == 1) begin // daca nu e liber la V, vrem sa incercam deplasarea la drepata vestului, adica la N
								  dep = 3; // incercam sa ne deplasam spre N
								  col = aux_col;
								  row = row -1;//scade linia la N
								  next_state = `deplasare;
								  
							end
						end
						2: begin							
						    if(maze_in == 0)begin //incercam la S, daca e liber  continuam aici
								  aux_col = col;
								  aux_row = row;
								  maze_we = 1;
								  next_state = `deplasare;
							 end else if(maze_in == 1) begin // daca nu e liber la S, vrem sa incercam deplasarea la dreapta sudului, adica la V
								 dep = 1; //incercam sa ne deplasam spre V
								 row = aux_row;
								 col = col - 1;//scade coloana la V
								 next_state = `deplasare;
								 
							end
						end
						3: begin
						     if(maze_in == 0)begin//incercam la N, daca e liber continuam aici
								  aux_col = col;
								  aux_row = row;
								  maze_we = 1;
								  next_state = `deplasare;
							 end else if(maze_in == 1) begin // daca nu e liber la N, vrem sa incercam deplasarea la dreapta nordului, ci anume la E
								  dep = 0; //incercam sa ne deplasam la E
								  row = aux_row;
								  col = col +1; //crese coloana la E
								  next_state = `deplasare;
								  
							end
						end
						
					endcase
					end
					
            `deplasare: begin 
				maze_oe = 1;
				case(dep)
				    0: begin //Verific ce se afla la dreapta lui E, adica la S, daca la S avem 0 ne deplasam acolo altfel ne deplasam la dreapta(adica la E)
						row = row + 1;
						if(maze_in == 1) begin
							row = aux_row; 
							aux_col = col; 
							col = col + 1; 
						end else if(maze_in == 0)  begin 
							aux_row = row;
							aux_col = col;
							dep = 2; 
						end

			        end

					1: begin //Verific ce se afla la dreapta lui V, adica la N, daca la N avem 0 ne deplasam acolo altfel ne deplasam la stanga(adica la V)
						row = row - 1; 
						if(maze_in == 1) begin
							row = aux_row; 
							aux_col = col; 
							col = col - 1; 
                        end else if(maze_in == 0) begin 
							aux_row = row;
							aux_col = col;
							dep = 3; 
						end
					end

					2: begin //Verific ce se afla la dreapta lui S, adica la V, daca la V avem 0 ne deplasam acolo altfel ne deplasam in jos(adica la S)
						col = col - 1; 
						if(maze_in == 1) begin
							col = aux_col; 
							aux_row = row; 
							row = row + 1; 

						end else if(maze_in == 0) begin 
							aux_col = col;
							aux_row = row;
							dep = 1; 
						end
					end

					3: begin //Verific ce se afla la dreapta lui N, adica la E, daca la E avem 0 ne deplasam acolo altfel ne deplasam in sus(adica la N)
						
						col = col + 1; 
                        if(maze_in == 1) begin
							col = aux_col; 
							aux_row = row; 
							row = row - 1;

						end else if(maze_in == 0) begin 
							aux_col = col;
							aux_row = row;
							dep = 0; 
						end
					end

				endcase
				
				next_state = `verificare_pozitie;

			end
			
            `rotire :begin
			    if( maze_in == 1) begin
					    row = aux_row ;
						col = aux_col;
					   case(dep)
						  0: dep = 1;
						  1: dep = 0;
						  2: dep = 3;
						  3: dep = 2;
						endcase
               end						
					next_state = `deplasare;
             end

			`verificare_pozitie: begin //verificam daca suntem pe ultima linie/coloana a labirintului si putem sa iesim

				if(maze_in == 0 && (col == 0 || col == 63 || row == 0 || row == 63))  begin

						maze_we = 1;
						next_state = `iesire;
					 end else begin //verificam daca nu suntem la iesirea din labirint si ne continuam deplasarea
						next_state = `continuare_mers;
					end

				 if(maze_in == 1  ) begin //ma reintorc de unde am venit si schimb cazul de deplasare cand vad ca nu mai drum in ncio parte 
					 
					 next_state = `rotire;
				 end

			end

			`iesire: begin
			        done = 1;
				end	
			`continuare_mers: begin  
			        if(maze_in == 0 && (col != 0 || col != 63 || row != 0 || row != 63)) begin
					    aux_col = col; 
						aux_row = row;
						maze_we = 1;
						next_state = `deplasare;
					end	
				end	
					  

			default: ;

	endcase

end

endmodule
							
				
						
							
