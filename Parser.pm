##################################################################
# Copyright (C) 2000 Greg London   All Rights Reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
##################################################################


##################################################################
package Hardware::Verilog::Parser;
use PrecompiledParser;
use Parse::RecDescent;
use vars qw ( $VERSION  @ISA);
@ISA = ( 'PrecompiledParser' , 'Parse::RecDescent' );
##################################################################
$VERSION = '0.10';
##################################################################

##################################################################
##################################################################
##################################################################
##################################################################

##################################################################
sub new
##################################################################
{
 my ($pkg) = @_;

 my $parser = PrecompiledParser->new();

 # bless it as a verilog_parser object
 bless $parser, $pkg;
 return $parser;
} 




#########################################################################
sub decomment_given_text
#########################################################################
{
 my ($obj,$text)=@_;

 my $filtered_text='';

 my $state = 'code';

 my ( $string_prior_to_line_comment, $string_after_line_comment);
 my ( $string_prior_to_block_comment, $string_after_block_comment);
 my ( $string_prior_to_quote, $string_after_quote);
 my ( $comment_string, $string_after_comment);
 my ( $quoted_string, $string_after_quoted_string);

 my $index_to_line_comment=0;
 my $index_to_block_comment=0;
 my $index_to_quote =0;
my $lc_lt_bc;
my $lc_lt_q;
my $bc_lt_q;
my $bc_lt_lc;
my $q_lt_lc;
my $q_lt_bc;

my $could_be_line_comment;
my $could_be_block_comment;
my $could_be_quote;

 while (1)
  {
  #print "#################################################### \n";
  #print "state = $state \n";
  if ($state eq 'code')
	{

	unless ( ($text =~ /\/\*/) or  ($text =~ /\/\//) or ($text =~ /\"/) )
		{ 
		$filtered_text .= $text ;
		last;
		}


	# look for comment or quoted string
	( $string_prior_to_line_comment, $string_after_line_comment)
		= split( '//' , $text, 2 );

	( $string_prior_to_block_comment, $string_after_block_comment)
		= split( /\/\*/ , $text, 2 );

	( $string_prior_to_quote, $string_after_quote)
		= split( /\"/ , $text, 2 );

	$index_to_line_comment = length($string_prior_to_line_comment);
	$index_to_block_comment = length($string_prior_to_block_comment);
	$index_to_quote   = length($string_prior_to_quote  );

	$lc_lt_bc = ($index_to_line_comment  < $index_to_block_comment);
	$lc_lt_q  = ($index_to_line_comment  < $index_to_quote);

	$bc_lt_q  = ($index_to_block_comment < $index_to_quote);
	$bc_lt_lc = ($index_to_block_comment < $index_to_line_comment);

	$q_lt_lc  = ($index_to_quote         < $index_to_line_comment);
	$q_lt_bc  = ($index_to_quote         < $index_to_block_comment);
	
	

	#print "length_remaining_text = $length_of_entire_text \n";
	#print " line_comment index=$index_to_line_comment  ". "text= $string_prior_to_line_comment \n";
	#print "block_comment index=$index_to_block_comment  "."text= $string_prior_to_block_comment \n";
	#print "quote         index=$index_to_quote  ".        "text= $string_prior_to_quote \n";
	#print "\n";

	if($lc_lt_bc and $lc_lt_q)
		{ 
		$state = 'linecomment';
		$filtered_text .= $string_prior_to_line_comment;
		$text = '//' . $string_after_line_comment;
		}

	elsif($bc_lt_q and $bc_lt_lc)
		{ 
		$state = 'blockcomment';
		$filtered_text .= $string_prior_to_block_comment;
		$text = '/*' . $string_after_block_comment;
		}

	elsif($q_lt_lc and $q_lt_bc)
		{
		$state = 'quote'; 
		$filtered_text .= $string_prior_to_quote;
		$text =  $string_after_quote;
		$filtered_text .= '"' ;
		}
	}

  elsif ($state eq 'linecomment')
	{
	# strip out everything from here to the next \n charater
	( $comment_string, $string_after_comment)
		= split( /\n/ , $text, 2  );

	$text = "\n" . $string_after_comment;

	$state = 'code';
	}

  elsif ($state eq 'blockcomment')
	{
	# strip out everything from here to the next */ pattern
	( $comment_string, $string_after_comment)
		= split( /\*\// , $text, 2  );

	$comment_string =~ s/[^\n]//g;

	$text = $comment_string . $string_after_comment;

	$state = 'code';
	}

  elsif ($state eq 'quote')
	{
	# get the text until the next quote mark and keep it as a string
	( $quoted_string, $string_after_quoted_string)
		= split( /"/ , $text, 2  );

	$filtered_text .= $quoted_string . '"' ;
	$text =  $string_after_quoted_string;

	$state = 'code';
	}
  }


 return $filtered_text;

}


#########################################################################
#
# the %define_hash variable keeps track of all `define values.
# it is class level variable because it needs to keep track of
# `defines that may cross file boundaries due to `includes.
# i.e.
# main.v
# `include "defines.inc"
# wire [`width:1] mywire;
#
# defines.inc
# `define width 8
#
# since each new included file calls filename_to_text, which in turn
# calls convert_compiler_directives_in_text, the %define_hash cannot
# be declared inside convert_compiler_directives_in_text because it
# will cease to exist once the included file is spliced in.
# for `defines to exists after the included file, the define_hash
# must be class level data.
# it could be stored in $obj->{'define_hash'}, but that seems overkill.
#
#########################################################################
 my %define_hash;

#########################################################################
sub convert_compiler_directives_in_text
#########################################################################
{
 my ($obj,$text)=@_;

 return $text unless ($text=~/`define/);

 my $filtered_text='';

 my ( $string_prior_to_tick, $string_after_tick);

my $temp_string;
my ($key, $value);
my $sub_string;

while(1)
	{
	unless ($text =~ /`/) 
		{ 
		$filtered_text .= $text ;
		last;
		}


	( $string_prior_to_tick, $string_after_tick)
		= split( '`' , $text, 2 );

	$filtered_text .= $string_prior_to_tick;

	# if new define
	if ($string_after_tick =~ /^define/)
		{
		$string_after_tick =~ /^define\s+(.*)/;
		$temp_string = $1;
		($key, $value) = split(/\s+/, $temp_string, 2);
		$define_hash{$key}=$value;

		#print "defining key=$key   value=$value \n";############

		$sub_string = '^define\s+'.$temp_string;

		$string_after_tick =~ s/$sub_string//;
		$text = $string_after_tick;
		}

	# else if `undef
	elsif ($string_after_tick =~ /^undef/)
		{
		$string_after_tick =~ /^undef\s+(\w+)/;
		$key = $1;
		$temp_string = '^undef\s+'.$key;
		$string_after_tick =~ s/$temp_string//;

		$define_hash{$key}=undef;
		$text = $string_after_tick;

		#print "undefining key=$key \n";#########
		}

	# else if `include
	elsif ($string_after_tick =~ /^include/)
		{
		$string_after_tick =~ /^include\s+(.*)/;
		$temp_string = $1;

		$sub_string = '^include\s+'.$temp_string;
		$string_after_tick =~ s/$sub_string//;

		$temp_string =~ s/"//g;
		# print "including file $temp_string\n";
		$string_after_tick = 
			$obj->filename_to_text($temp_string) .
			$string_after_tick;

		$text = $string_after_tick;
		}


	# else must be a defined constant, replace `NAME with $value
	else
		{
		$string_after_tick =~ /^(\w+)/;
		my $key = $1;
		unless(	defined($define_hash{$key}) )
			{die "undefined macro `$key\n";}
		$string_after_tick =~ s/$key//;
		$value = $define_hash{$key};
		
		$filtered_text .= $value;

		$text = $string_after_tick;
		#print "replacing key=$key   value=$value\n";#######

		}
	}

 return $filtered_text;
}

#########################################################################
sub Filename
#########################################################################
{
 my $obj = shift;

 while(@_)
	{
	my $filename = shift;
 	my $text = $obj->filename_to_text($filename);

	#print "text to parse is \n$text\n";

 	$obj->design_file($text);
	}
}

#########################################################################
sub filename_to_text
#########################################################################
#
{
 my ($obj,$filename)=@_;
 open (FILE, $filename) or die "Cannot open $filename for read\n";
 my $text;
 while(<FILE>)
  {
  $text .= $_;
  }

 $text = $obj->decomment_given_text($text);
 $text = $obj->convert_compiler_directives_in_text($text);

 return $text;
}


##################################################################
##################################################################
##################################################################
##################################################################




##################################################################
##################################################################
##################################################################
##################################################################

1;

##################################################################
##################################################################
##################################################################
##################################################################

__END__

=head1 NAME

Hardware::Verilog::Parser - A complete grammar for parsing Verilog code using perl

=head1 SYNOPSIS

  use Hardware::Verilog::Parser;
  $parser = new Hardware::Verilog::Parser;

  $parser->Filename(@ARGV);

=head1 DESCRIPTION

This module defines the complete grammar needed to parse any Verilog code.
By overloading this grammar, it is possible to easily create perl scripts
which run through Verilog code and perform specific functions.

For example, a Hierarchy.pm uses Hardware::Verilog::Parser to overload the
grammar rule for module instantiations. This single modification
will print out all instance names that occur in the file being parsed.
This might be useful for creating an automatic build script, or a graphical
hierarchical browser of a Verilog design.

This module is currently in alpha release. All code is subject to change.
Bug reports are welcome.


DSLI information:


D - Development Stage

	a - alpha testing

S - Support Level

	d - developer

L - Language used

	p - perl only, no compiler needed, should be platform independent

I - Interface Style

	O - Object oriented using blessed references and / or inheritance




=head1 AUTHOR

Copyright (C) 2000 Greg London   All Rights Reserved.

This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

email contact: greg42@bellatlantic.net

=head1 SEE ALSO

Parse::RecDescent, version 1.77

perl(1).

=cut

