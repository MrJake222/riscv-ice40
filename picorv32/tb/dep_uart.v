reg tx = 0;

initial
begin
	// set pullup
	tx <= 1;
end


// functions


integer i;
task send_byte(input [7:0] b);
begin
	tx <= 0;
	#8681;
	for (i=0; i<8; i=i+1)
	begin
		tx <= b[i];
		#8681;
	end
	tx <= 1;
	#8681;
end endtask
