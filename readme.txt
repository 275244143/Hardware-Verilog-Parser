This module is an attempt to make it easy for hardware engineers
to create scripts that parse Verilog files intelligently.

The Hardware::Verilog::Parser.pm file contains a Verilog grammar.
This grammar is used by Parse::RecDescent to parse any
Verilog design file.

verilog.pl is a script which uses this module to do the
actual parsing.  a test Verilog file is included,
called test1.v

to parse the file, type:

verilog.pl test1.v

The verilog.pl script doesn't do anything except parse the file.



PLEASE NOTE: the script takes some time to simply load the grammar.
the it takes about a minute (yes, 60 seconds) to run the 
verilog.pl test1.v command shown above when run on an Ultra 60.
your performance may vary.

the Parse::RecDescent has some features which will eventually 
allow me to speed up this execution time. I'll get to that
when the grammar is ironed out.


The module is currently in "debug" status.
There are a number of problems in the grammar.
I'm putting the file on CPAN to get some help 
finding all the bugs.

If you have any corrections or questions,
please send them to me at
greg42@bellatlantic.net

thanks,
Greg London
