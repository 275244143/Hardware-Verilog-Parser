//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

//=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
module testmodule (
	clock, reset_n,
	myin, myout);

	input clock;
	input reset_n;
	input myin;
	output outwire;
	output myout;
	reg myout;


	wire mywire;
	assign mywire = myin;

	assign outwire = mywire;

	always @(posedge clock or negedge reset_n)
	begin
		if (!reset_n)
			begin
			myout <= 1'b0;
			end
		else
			begin
			myout <= myin;
			end 
	end 



endmodule

