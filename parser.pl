#! /bin/perl -sw

####################################################
# Copyright (C) 2000 Greg London
# All Rights Reserved.
####################################################

use Hardware::Verilog::Parser;

$parse = new Hardware::Verilog::Parser;

$::RD_AUTOSTUB = undef;

$::RD_ERRORS = 1;
$::RD_WARN = 1;
$::RD_HINT = 1;
$::RD_TRACE = 1;


$parse->Filename(@ARGV);



