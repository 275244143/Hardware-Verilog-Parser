##################################################################
# Copyright (C) 2000 Greg London   All Rights Reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
##################################################################

Hardware::Verilog::Parse.pm is currently in "beta" status

The Hardware::Verilog::Parser.pm file contains a Verilog grammar.
This grammar is used by Parse::RecDescent to parse any
Verilog design file.You will need the latest version of 
Parse::RecDescent to use this grammar.

verilog.pl is a script which uses this module to do the actual parsing.  
a test Verilog file is included called test1.v

to parse the file, type:

verilog.pl test1.v

This should print out a report on test1.v that looks something like this:

module testmodule 


contained the following input ports:
	clock
	myin
	reset_n


contained the following inout ports:


contained the following output ports:
	myout
	outwire


contained the following wires:
	 type wire 	clock
	 type wire 	myin
	 type wire 	mywire
	 type wire 	outwire
	 type wire 	reset_n


contained the following regs:
	myout
	temp_reg1 [ 23 : 0 ] 
	temp_reg2 [ 35 : 0 ] 


contained the following instances:



The parser is now precompiled, and runs much faster than
the previous versions. Without precompilation, it took
about 60 seconds to run, with precompilation, it takes
roughly 6 seconds. An order of magnitude improvement.




Directory structure / installation information:

once you untarred the file, you can install
the files by creating a directory structure
similar to this:

~home/Hardware/Verilog

inside that directory, copy the following files:

Hierarchy.pm
Parser.pm
PrecompiledParser.pm
StdLogic.pm

The remaining files go into ~home.
This would be where you run your perl scripts from.




If you have any corrections or questions,
please send them to me at
greg42@bellatlantic.net

thanks,
Greg London
