##################################################################
# Copyright (C) 2000 Greg London   All Rights Reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
##################################################################


##################################################################
package Hardware::Verilog::Parser;
use Parse::RecDescent;
@ISA = ( 'Parse::RecDescent' );
##################################################################
use vars qw ( $VERSION  @ISA);
$VERSION = '0.02';
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

 # get the verilog grammar defined in this file
 my $verilog_grammar = $pkg->grammar();



 # create a parser object, use SUPER:: to find the method via @ISA
 my $r_hash = $pkg->SUPER::new  ($verilog_grammar);

 # bless it as a verilog_parser object
 bless $r_hash, $pkg;
 return $r_hash;
} 




















































##################################################################
sub grammar
##################################################################
{

# note, q{  statement should be on line 100, 
# to make it easier to find referenced line numbers

return  q{

	eofile : /^\Z/

###############################
# source text
###############################

design_file :  
	design_unit(s) eofile { $return = $item[1] }

design_unit : 
        module_declaration | udp_declaration
	| <error>

module_declaration  : 
        module_keyword
        module_identifier
        list_of_ports(?)
        ';'
        module_item(s?)
        'endmodule'

module_keyword : 
        'module'  |  'macromodule'

list_of_ports  : 
        '(' 
        one_or_more_ports_separated_by_commas 
        ')'

port  : 
        optional_port_expression |
        dot_port_identifier_and_port_expression

dot_port_identifier_and_port_expression :
        '.'
        port_identifier
        '('
        port_expression(?)
        ')'
        

optional_port_expression :
        port_expression(?)

port_expression  : 
        one_or_more_port_references_separated_by_commas

port_reference  : 
        port_identifier
        port_bit_or_slice(?)

port_bit_or_slice :
        bit_or_slice

module_item : 
        module_item_declaration | 
        parameter_override | 
        continuous_assign | 
        gate_instantiation | 
        udp_instantiation | 
        module_instantiation | 
        specify_block | 
        initial_construct | 
        always_construct

module_item_declaration :
        parameter_declaration | 
        input_declaration | 
        output_declaration | 
        inout_declaration | 
        net_declaration | 
        reg_declaration | 
        integer_declaration | 
        real_declaration | 
        time_declaration | 
        realtime_declaration | 
        event_declaration | 
        task _declaration | 
        function_declaration

parameter_override :
        'defparam'
        list_of_param_assignments
        ';'



parameter_declaration  :  
        'parameter' 
        one_or_more_parameter_assignments_serparated_by_commas
        ';'

list_of_param_assignments :
        one_or_more_parameter_assignments_serparated_by_commas

param_assignment : 
        parameter_identifer
        '=' 
        constant_expression

input_declaration :
        'input'
        range(?)
        list_of_port_identifiers
        ';'

output_declaration :
        'output'
        range(?)
        list_of_port_identifiers
        ';'

inout_declaration :
        'inout'
        range(?)
        list_of_port_identifiers
        ';'


list_of_port_identifiers :
        one_or_more_port_identifiers_separated_by_commas



reg_declaration  :  
        'reg'
        range(?) 
        one_or_more_register_names_separated_by_commas
        ';'

time_declaration  :  
        'time'
        one_or_more_register_names_separated_by_commas
        ';'

integer_declaration  :  
        'time'
        one_or_more_register_names_separated_by_commas
        ';'

real_declaration  :  
        'real'
        one_or_more_real_identifiers_separated_by_commas
        ';'

realtime_declaration  :  
        'realtime'
        one_or_more_real_identifiers_separated_by_commas
        ';'


register_name  : 
        register_identifier | 
        memory_identifier     range(?)

range  :
        '[' 
        msb_constant_expression 
        ':'  
        lsb_constant_expression 
        ']'

                
net_declaration  : 
        net_type_vectored_scalared_range_delay3_list_of_net_identifiers | 
        trireg_vectored_scalared_charge_strength_range_delay3_list_of_net |
        net_type_vectored_scalared_drive_strength_range_delay3_list_of_net_decl

net_type_vectored_scalared_range_delay3_list_of_net_identifiers : 
        net_type
        vectored_or_scalared
        range(?)
        delay3(?)
        one_or_more_net_decl_assignments_separated_by_commas
        ';'

trireg_vectored_scalared_charge_strength_range_delay3_list_of_net : 
        'trireg'
        vectored_or_scalared
        charge_strength(?)
        range(?)
        delay3(?)                
        one_or_more_net_decl_assignments_separated_by_commas
        ';'

net_type_vectored_scalared_drive_strength_range_delay3_list_of_net_decl :
        net_type
        vectored_or_scalared
        drive_strength(?)
        range(?)
        delay3(?)
        one_or_more_net_decl_assignments_separated_by_commas
        ';'

vectored_or_scalared :
	'vectored' | 'scalared'

net_type :  
        'wire'  |  
        'tri'  |  
        'tril'  |  
        'supply0'  |
        'wand'  |  
        'triand'  |  
        'tri0'  |
        'supply1'  |  
        'wor'  |  
        'trior'


drive_strength  : 
        '('
        (
        strength0_comma_strength1 |
        strength1_comma_strength0 |
        strength0_comma_highz1 |

        strength1_comma_highz0 |
        highz1_comma_strength0 |
        highz0_comma_strength1 
        )
        ')'

strength0_comma_strength1 : 
        strength0 ',' strength1
                        
strength1_comma_strength0 : 
        strength1 ',' strength0

strength0_comma_highz1 : 
        strength0 ',' highz1

strength1_comma_highz0 : 
        strength1 ',' highz0


highz1_comma_strength0 : 
        highz1 ',' strength0


highz0_comma_strength1 : 
        highz0 ',' strength1

strength0 : 
	'supply0'  |  'strong0'  |  'pull0'  |  'weak0' 

strength1 : 
	'supply1'  |  'strong1'  |  'pull1'  |  'weak1' 

charge_strength  :  
	'small'    |  'medium'      |  'large'  


delay3  :  
        '#'
        '('
        ( one_delay_value |
          two_delay_values |
        three_delay_values )
        ')'

delay2  :  
        '#'
        '('
        ( one_delay_value |
          two_delay_values )
        ')'

delay1  :  
        '#'
        '('
        one_delay_value 
        ')'

one_delay_value : 
        delay_value

two_delay_values :
        delay_value ',' delay_value

three_delay_values :
        delay_value ',' delay_value ',' delay_value
        
delay_value  :  
	unsigned_number  |  
          parameter_identifier  | 
          constant mintypmax expression

net_decl_assignment :

        net_identifier 
        '='
        expression

function_declaration  : 
        'function'
        range_or_type(?)
        function_identifier 
        ';'
        function_item_declaration(s)
        statement
        'endfunction'

range_or_type :
	range  |  'integer'  |  'real'  |  'realtime'  |  'time'

function_item_declaration : 
        input_declaration |
        block_item_declaration

task_declaration  : 
        'task'
        task_identifier
        ';'
        task_item_declaration(s?)
        statement_or_null
        'endtask'

task_item_declaration : 
        block_item_declaration | 
        input_declaration | 
        output_declaration | 
        inout_declaration


block_item_declaration : 
        parameter_declaration | 
        reg_declaration | 
        integer_declaration | 
        real_declaration | 
        time_declaration | 
        realtime_declaration | 
        event_declaration


###################################################################
# primitive instances
###################################################################


gate_instantiation  : 
        n_input_gatetype_drive_strength_delay2_n_input_gate_instance | 
        n_output_gatetype_drive_strength_delay2_n_output_gate_instance | 
        enable_gatetype_drive_strength_delay3_enable_gate_instance | 
        mos_switchtype_delay3_mos_switch_instance | 
        pass_switchtype_pass_switch_instance | 
        pass_en_switchtype_delay3_pass_en_switch_instance | 
        cmos_switchtype_delay3_cmos_switch_instance | 
        pullup_pullup_strength_pull_gate_instance | 
        pulldown_pulldown_strength_pull_gate_instance 


n_input_gatetype_drive_strength_delay2_n_input_gate_instance :
        n_input_gatetype
        drive_strength(?)
        delay2(?)
        one_or_more_n_input_gate_instance_separated_by_commas
        ';'

n_output_gatetype_drive_strength_delay2_n_output_gate_instance : 
        n_output_gatetype
        drive_strength(?)
        delay2(?)
        one_or_more_n_output_gate_instance_separated_by_commas
        ';'

enable_gatetype_drive_strength_delay3_enable_gate_instance : 
        enable_gatetype
        drive_strength(?)
        delay3(?)
        one_or_more_enable_gate_instance_separated_by_commas
        ';'

mos_switchtype_delay3_mos_switch_instance :
        mos_switchtype
        delay3(?)
        one_or_more_mos_switch_instance_separated_by_commas
        ';'

pass_switchtype_pass_switch_instance : 
        pass_switchtype
        one_or_more_pas_switch_instance_separated_by_commas
        ';'

pass_en_switchtype_delay3_pass_en_switch_instance : 
        pass_en_switchtype
        delay3(?)
        one_or_more_pass_en_switch_instance_separated_by_commas
        ';'

cmos_switchtype_delay3_cmos_switch_instance : 
        cmos_switchtype
        delay3(?)
        one_or_more_cmos_switch_instance_separated_by_commas
        ';'

pullup_pullup_strength_pull_gate_instance : 
        'pullup'
        pullup_strength(?)
        one_or_more_pull_gate_instance_seperated_by_commas
        ';'

pulldown_pulldown_strength_pull_gate_instance : 
        'pulldown'
        pulldown_strength(?)
        one_or_more_pull_gate_instance_seperated_by_commas
        ';'

n_input_gate_instance  : 
        name_of_gate_instance(?) 
        '('
         output_terminal ','
         one_or_more_input_terminals_separated_by_commas ','
        ')'

n_output_gate_instance  : 
        name_of_gate_instance(?) 
        '('
        one_or_more_output_terminals_separated_by_commas ','
        input_terminal
        ')'

enable_gate_instance  : 
        name_of_gate_instance(?) 
        '('
        output_terminal ','
        input_terminal ','
        enable_terminal
        ')'


mos_switch_instance  : 
        name_of_gate_instance(?) 
        '('
         output_terminal ','
         input_terminal ','
         enable_terminal
        ')'


pass_switch_instance  : 
        name_of_gate_instance(?) 
        '('
         inout_terminal ','
         inout_terminal 
        ')'

pass_enable_switch_instance  : 
        name_of_gate_instance(?) 
        '('
         inout_terminal ','
         inout_terminal ','
         enable_terminal
        ')'

cmos_switch_instance  : 
        name_of_gate_instance(?) 
        '('
         output_terminal   ','
         input_terminal    ','
         ncontrol_terminal ','
         pcontrol_terminal
        ')'

pull_gate_instance  : 
        name_of_gate_instance(?) 
        '('
         output_terminal 
        ')'

name_Of_gate_instance  :  
        gate_instance_identifier
        range(?)



pullup_strength  : 
        '('
        (
        strength0_comma_strength1 |
        strength1_comma_strength0 |
        strength1
        )
        ')'


pulldown_strength  : 
        '('
        (
        strength0_comma_strength1 |
        strength1_comma_strength0 |
        strength0
        )
        ')'


input_terminal  :  
        scalar_expression 

enable_terminal  :   
        scalar_expression 

ncontrol_terminal :  
        scalar_expression 

pcontrol_tenninal :  
        scalar_expression 

output_terminal  :        
        terminal_identifier  constant_expression(?)

inout_terminal : 
        terminal_identifier  constant_expression(?)

n_input_gatetype  :  
	'and'  |  'nand'  |  'or'  |  'nor'  |  'xor'  |  'xnor'  

n_output_gatetype  :  
	'buf'  |  'not' 

enable_gatetype  :  
	'bufifo'  |  'bufdl'  |  'notifo'  |  'notifl'  

mos_switchtype :  
	'nmos'  |  'pmos'  |  'rnmos'  |  'rpmos'    

pass_switchtype  :  
	'tran'  |  'rtran'   

pass_en_switchtype :
	'tranif0' | 'tranif1' | rtranif1' | 'rtranif0'  

cmos_switchtype :
	'cmos' | 'rcmos'  



##################################################################
# module instantiation
##################################################################

module_instantiation : 
        module_identifier
        parameter_value_assignment(?)
        module_instance(s)
	';'

parameter_value_assignment :
        '#' 
        '(' 
        one_or_more_expressions_separated_by_commas 
        ')' 

module_instance :  
        name_of_instance 
        '('
        list_of_module_connections(?)
        ')'


name_of_instance  : 
         module_instance_identifier
        range(?)

list_of_module_connections :
	  one_or_more_ordered_port_connections_separated_by_commas 
	| one_or_more_named_port_connections_separated_by_commas 

ordered_port_connection  :  
        expression(?)

named_port_connection :
        '.' 
        port_identifier
        '(' port_expression ')'



##############################################################
# UDP declaration and instantiation
##############################################################

udp_declaration  : 
        'primitive'
        udp_identifier 
        '(' udp_port_list ')' ';'
        udp_port_declaration(s)
        udp_body
        'endprimitive'

udp_porlist  :  
        output_port_identifier ','
        one_or_more_input_port_identifier_separated_by_commas

udp_port_declaration : 
          output_declaration 
	| input_declaration 
	| reg_declaration
        

udp_body  : 
         combinational_body  |  sequential_body


combinational_body  : 
        'table' 
        combinational_entry(s) 
        'endtable'

combinational_entry :
        level_input_list ':' output_symbol ';'

sequential_body :
        udp_initial_statement(?)
        'table' 
        sequential_entry(s)
        'endtable'

udp_initial_statement  :  
        'initial' 
        udp_output_port_identifier 
        '=' 
        init_val
        ';'

init_val  : 
          "1'b0" | "1'b1" | "1'bx" | "1'bX " | 
          "1'B0" | "1'B1" | "1'Bx" | "1'BX " |
          '1' | '0' 

sequential_entry  :  
        seq_input_list ':' current_state ':' next_state


seq_input_list  :  
        level_input_list  |  edge_input_list

level_input_list :
        level_symbol(s)

edge_input_list :
        level_symbol(s?) 
        edge_indicator
        level_symbol(s?)

edge_indicator :
        level_symbol_level_symbol_in_paran  |  edge_symbol

level_symbol_level_symbol_in_paran :
        '(' level_symbol level_symbol ')'

current_state  : 
        level_symbol

next_state  : 
        output_symbol | '-'

output_ symbol : 
        /[01xX]/

level_symbol  :
        /[01xXbB?]/ 

edge_symbol :
        'r' | 'R' | 'f' | 'F' | 'p' | 'P' | 'n' | 'N' | '*'

udp_instantiation :
        udp_identifier
        drive_strength(?)
        delay2(?)
        one_or_more_udp_instances_separated_by_commas
        ';'

udp_instance :
        name_of_udp_instance(?)
        '('
        output_port_connection ','
        one_or_more_input_port_connections_separated_by_commas
        ';'


#####################################################################
# continuous assign
#####################################################################

continuous_assignment  : 
        'assign'
        drive_strength(?)
        delay3(?)
        one_or_more_net_assignments_separated_by_commas
        ';'

net_assignment : 
        net_lvalue '=' expression

initial_construct  : 
        'initial' statement

always_constuct  : 
        'always' statement

statement :
	  blocking_assignment_with_comma 
	| non_blocking_assignment_with_comma 
	| procedural_continuous_assignment_with_comma 
	| procedural_timing_control_statement 
	| conditional_statement 
	| case_statement 
	| loop_statement 
	| wait_statement 
	| disable_statement 
	| event_trigger 
	| seq_block 
	| par_block 
	| task_enable 
	| system_task_enable


statement_or_null  : 
        statement | ';'



blocking_assignment :
        reg_lvalue 
        '='
        delay_or_event_control(?)
        expression

nonblocking_assignment :
        reg_lvalue 
        '<='
        delay_or_event_control(?)
        expression


procedural_continuous_assignments :
          assign_reg_assignment 
	| deassign_reg_lvalue 
	| force_reg_assignment 
	| force_net_assignment 
	| release_reg_lvalue 
	| release_net_lvalue 

assign_reg_assignment :
        'assign' reg_assignment ';'

deassign_reg_lvalue :
        'deassign' reg_lvalue ';'

force_reg_assignment :
        'force' reg_assignment ';'

force_net_assignment :
        'force' net_assignment ';'

release_reg_lvalue :
        'release' reg_lvalue ';'

release_net_lvalue :
        'release' net_lvalue ';'

procedural_timing_control_statement  : 
        delay_or_event_control 
        statement_or_null

delay_or_event_control : 
          delay_control
        | event control


delay_control :
	'#' ( delay_value | mintypmax_expression_in_paren )                

mintypmax_expression_in_paren  : 
	 '(' mintypmax_expression ')'

event_expression_list :
	event_expression or_event_expression(s?)

or_event_expression :
	'or' event_expression

event_expression : 
	  expression 
	| event_identifier 
	| posedge_expression 
	| negedge_expression 

posedge_expression :
        'posedge' 
        expression

negedge_expression :
        'negedge' 
        expression


conditional_statement  : 
        'if' '(' expression ')'
        statement_or_null 
        else_statement_or_null(?)

else_statement_or_null :
        'else'
        statement_or_null


case_statement  : 
	  case_endcase  
	| casez_endcase  
	| casex_endcase

case_endcase :
        'case' expression_case_item_list 'endcase'

casez_endcase :
        'casez' expression_case_item_list 'endcase'

casex_endcase :
        'casex' expression_case_item_list 'endcase'

expression_case_item_list :
        '(' expression ')' case_item(s)

case_item  : 
	  expression_list_statement_or_null 
	| default_statement_or_null 

expression_list_statement_or_null : 
        one_or_more_expressions_separated_by_commas 
        ':'
        statement_or_null

default_statement_or_null : 
        'default' 
        ':'
        statement_or_null


loop_statement  : 
	  forever_statement 
	| repeat_expression_statement  
	| while_expression_statement  
	| for_reg_assignment_expression_reg_assignment_statement

forever_statement :
        'forever'
        statement

repeat_expression_statement : 
        'repeat'
        '(' expression ')'
        statement 

while_expression_statement : 
        'while'
        '(' expression ')'
        statement

for_reg_assignment_expression_reg_assignment_statement :
        'for' '(' 
        reg_assignment ';'
        expression ';'
        reg_assignment ')'
        statement


reg_assignment : 
        reg_lvalue '=' expression 

wait_statement  : 
        'wait' 
        '(' 
        expression 
        ')' 
        statement_or_null

event_trigger  : 
        '->' event_identifier ';'

disable_statement  : 
        'disable' 
        ( task_identifier | block_identifer ) 
        ';'                

seq_block  : 
        'begin' 
        block_identifier_block_item_declaration(?)      
        statement(s?)
        'end'

par_block  : 
        'fork' 
        block_identifier_block_item_declaration(?)      
        statement(s?)
        'join'

task_enable  : 
        task_identifier
        expression_list_in_paren(?)
        ';'

expression_list_in_paren :
        '('
        one_or_more_expressions_separated_by_commas
        ')'

system_task_enable :
        system_task_name
        expression_list_in_paren(?)
        ';'

system_task_name :
        '$' identifier   # note a space should not be allowed between $ and ident





##########################################################################
# specify section 
##########################################################################

specify_block :
        'specify'
        specify_item(?)
        'endspecify'

specify_item :
	  specparam_declaration   
	| path_declaration  
	| system_timing_check 

specparam_declaration :
        'specparam'
        one_or_more_specparam_assignments_separated_by_commas
        ';'

specparam_assignment :
 	  specparam_identifier_equal_constant_expression  
	| pulse_control_specparam
 
specparam_identifier_equal_constant_expression :
        specparam_identifier
        '='
        constant_expression

pulse_control_specparam :
	  pathpulse_reject_limit_value 
	| pathpulse_specify_input_terminal_descriptor

pathpulse_reject_limit_value :
        'PATHPULSE$'
        '='
        '('
        reject_limit_value
        comma_erro_limit_value(?)
        ')' ';'

comma_erro_limit_value :
        ','
        error_limit_value

pathpulse_specify_input_terminal_descriptor :
        'PATHPULSE$'
        specify_input_terminal_descriptor
        '$'
        specify_output_terminal_descriptor
        '='
        '(' 
        reject_limit_value
        comma_erro_limit_value(?)
        ')' ';'

limit_value :
        constant_mintypmax_expression

path_declaration :
	(
	  simple_path_declaration |
	| edge_sensitive_path_declaration |
	| state_dependent_path_declaration 
	)
        ';'

simple_path_declaration :
        (
        parallel_path_description |
        full_path_description
        )
        '='
        path_delay_value

parallel_path_description :
        '('
        specify_input_terminal_descriptor
        polarity_operator(?)
        '=>'
        specify_output_terminal_descriptor 
        ')'

full_path_description :
        '('
        list_of_path_inputs 
        polarity_operator(?)
        '*>'
        list_of_path_outputs
        ')'

list_of_path_inputs :
        one_or_more_specify_input_terminal_descriptors_separated_by_commas

list_of_path_outputs :
        one_or_more_specify_output_terminal_descriptors_separated_by_commas

specify_input_terminal_descriptor : 
        input_identifier 
        bit_or_slice(?)

specify_output_terminal_descriptor : 
        output_identifier 
        bit_or_slice(?)

input_identifier : 
	  input_port_identifier 
	| inout_port_identifier

output_identifier : 
	  output_port_identifier  
	| inout_port_identifier

polarity_operator :
          '+' | '-'  


path_delay_value : 
        '('
        list_of_path_delay_expressions
        ')'


list_of_path_delay_expressions : 
	  one_path_delay_expression 
	| two_path_delay_expressions 
	| three_path_delay_expressions 
	| six_path_delay_expressions 
	| twelve_path_delay_expressions

one_path_delay_expression :
        t_pde

two_path_delay_expressions :
        trise_pde ',' pfall_pde

three_path_delay_expressions :
        trise_pde ',' pfall_pde ',' tz_pde

six_path_delay_expressions :
        t01_pde ',' t10_pde ',' t0z_pde ','

        tz1_pde ',' p1z_pde ',' pz0_pde

twelve_path_delay_expressions :
        t01_pde ',' t10_pde ',' t0z_pde ','
        tz1_pde ',' p1z_pde ',' pz0_pde ','
        t0x_pde ',' txa_pde ',' t1x_pde ','
        tx0_pde ',' pxz_pde ',' pzx_pde

t_pde :
        path_delay_expression

trise_pde :
        path_delay_expression


tfall_pde :
        path_delay_expression

tz_pde :
        path_delay_expression

t01_pde :
        path_delay_expression

t10_pde :
        path_delay_expression

t0z_pde :
        path_delay_expression

tz1_pde :
        path_delay_expression

t1z_pde :
        path_delay_expression

tz0_pde :
        path_delay_expression

t0x_pde :
        path_delay_expression

tx1_pde :
        path_delay_expression

t1x_pde :
        path_delay_expression

tx0_pde :
        path_delay_expression

txz_pde :
        path_delay_expression

tzx_pde :
        path_delay_expression

path_delay_expression :
        constant_mintypmax_expression

edge_sensitive_path_declaration :
	  parallel_edge_sensitive_path_description_equal_path_delay_value
	| full_edge_sensitive_path_description_equal_path_delay_value

parallel_edge_sensitive_path_description_equal_path_delay_value :
        parallel_edge_sensitive_path_description 
        '=' 
        path_delay_value 

full_edge_sensitive_path_description_equal_path_delay_value : 
        full_edge_sensitive_path_description
        '='
        path_delay_value

# check this
parallel_edge_sensitive_path : 
        '('
        edge_identifier(?)
        specify_input_terminal_descriptor
        '=>'
        specify_output_terminal_descriptor
        polarity_operator(?)
        ':'
        data_source_expression
        ')'

# check this rule
full_edge_sensitive_path : 
        '('
        edge_identifier(?)
        list_of_path_inputs
        '*>'
        list_of_path_outputs
        polarity_operator(?)
        ':'
        data_source_expression 
        ')'
        

data_source_expression :
        expression

edge_identifier : 
        'posedge' | 'negedge'

state_dependent_path_declaration : 
	  if_conditional_expression_simple_path_declaration 
	| if_conditional_expression_edge_ensitive_path_declaration 
	| ifnone_simple_path_declaration 

if_conditional_expression_simple_path_declaration :
        'if' 
        '(' conditional_expression ')'
        simple_path_declaration 

if_conditional_expression_edge_ensitive_path_declaration :
        'if'
        '(' conditional_expression ')'
        edge_ensitive_path_declaration

ifnone_simple_path_declaration :
        'ifnone'
        simple_path_declaration

system_timing_check : 
	  setup_timing_check  
	| hold_timing_check  
	| period_timing_check  
	| width_timing_check  
	| skew_timing_check   
	| recovery_timing_check  
	| setuphold_timing_check


setup_timing_check :
        '$setup'
        '(' 
        timing_check_event ','
        timing_check_event ','
        timing_check_limit 
        comma_notify_register(?)
        ')' 
        ';'

hold_timing_check :
        '$hold'
        '(' 
        timing_check_event ','
        timing_check_event ','
        timing_check_limit 
        comma_notify_register(?)
        ')' 
        ';'

period_timing_check :
        '$period'
        '(' 
        controlled_timing_check_event ','
        timing_check_limit 
        comma_notify_register(?)
        ')' 
        ';'

width_timing_check :
        '$width'
        '(' 
        controlled_timing_check_event ','
        timing_check_limit ','
        constant_expression 
        comma_notify_register(?)
        ')' 
        ';'

skew_timing_check :
        '$skew'
        '(' 
        timing_check_event ','
        timing_check_event ','
        timing_check_limit 
        comma_notify_register(?)
        ')' 
        ';'


recovery_timing_check :
        '$recovery'
        '(' 
        controlled_timing_check_event ','
        timing_check_event ','
        timing_check_limit 
        comma_notify_register(?)
        ')' 
        ';'


setuphold_timing_check :
        '$setuphold'
        '(' 
        timing_check_event ','
        timing_check_event ','
        timing_check_limit ','
        timing_check_limit 
        comma_notify_register(?)
        ')' 
        ';'

comma_notify_register :
         ',' notify_register

timing_check_event :
        timing_check_event_control(?)        
        specify_terminal_descriptor
        ampersand_timing_check_condition(?)

ampersand_timing_check_condition : 
        '&&&' timing_check_condition

specify_terminal_descriptor :
	  specify_input_terminal_descriptor 
	| specify_output_terminal_descriptor

controlled_timing_check_event : 
        timing_check_event_control
        specify_terminal_descriptor
        ampersand_timing_check_condition(?)

timing_check_event_control :
	  'posedge'  
	| 'negedge'  
	| edge_control_specifier

edge_control_specifier : 
        'edge'
        '['
        edge_descriptor
        comma_edge_descriptor(?)
        ']'

comma_edge_descriptor : 
        ',' edge_descriptor

edge_descriptor :  
          '01' | '10' | '0x' | 'x1' | ' 1x' | 'x0'  

timing_check_condition : 
	  scalar_timing_check_condition  
	| scalar_timing_check_condition_in_parens

scalar_timing_check_condition_in_parens : 
        '(' scalar_timing_check_condition ')'

scalar_timing_check_condition : 
	  expression  
	| tilde_expression 
	| double_equal_expression
	| triple_equal_expression 
	| double_not_equal_expression 
	| triple_not_equal_expression 

tilde_expression :
        '~' expression

double_equal_expression :
        expression '==' scalar_constant

triple_equal_expression :
        expression '===' scalar_constant

double_not_equal_expression :
        expression '!=' scalar_constant

triple_not_equal_expression :
        expression '!==' scalar_constant


timing_check_limit : 
        expression

scalar_constant :
          "1'b0" | "1'b1" | "1'B0" | "1'B1" | 
           "'b0" |  "'b1" |  "'B0" |  "'B1" | 
             '1' | '0' 

notify_register : 
        register_identifier


##############################################################
# expressions
##############################################################


net_lvalue : 
	  net_identifier  
	| net_identifier_with_bit_select 
	| net_identifier_with_slice_select  
	| net_cancatentation

net_identifier_with_bit_select :
        net_identifier '[' expression ']'

net_identifier_with_slice_select :
        net_identifier range

net_concatenation : 
        '{' one_or_more_expressions_separated_by_commas '}'

reg_lvalue :
	  reg_identifier   
	| reg_identifier_with_bit_select  
	| reg_identifier_with_slice_select   
	| reg_cancatentation

reg_identifier_with_bit_select :
        reg_identifier '[' expression ']'

reg_identifier_with_slice_select :
        reg_identifier range

reg_concatenation : 
        '{' one_or_more_expressions_separated_by_commas '}'

constant_expression : 
	constant_bin_expr '?' constant_expression ':' constant_expression 
	| constant_bin_expr

constant_bin_expr : 
	constant_uni_expr binary_operator constant_bin_expr
	| constant_uni_expr

constant_uni_expr : 
	unary_operator constant_primary 
	| constant_primary


constant_primary : 
	  number  
	| parameter_identifier  
	| constant_concatenation  
	| constant_multiple_concatenation

constant_mintypmax_expression :
        constant_expression 
        colon_constant_expression_colon_constant_expression(?)

colon_constant_expression_colon_constant_expression :
        ':'
        constant_expression 
        ':'
        constant_expression 

mintypmax_expression :        
        expression 
        colon_expression_colon_expression(?)

colon_expression_colon_expression :
        ':'
        expression 
        ':'
        expression 

expression : 
	bin_expr '?' expression ':' expression 
	| bin_expr

bin_expr : 
	uni_expr binary_operator bin_expr
	| uni_expr

uni_expr : 
	unary_operator primary 
	| primary



unary_operator : 
	'+' | '-' | '!' | '~' | '&' | '~&' | '|' |
        '~|' | '^' | '~^' | '^~' 

binary_operator : 
        '+' | '-' | '*' | '/' | '%' | 
        '==' | '!=' | '===' | '!==' | 
        '&&' | '||' | '<' | '<=' | 
        '>' | '>=' | '&' | '|' | '^' |
        '^~' | '~^' | '>>' | '<<'

primary : 
	  number 
	| identifier_bit_or_slice 
	| concatenation 
	| multiple_concatenation 
	| function_call  
	| mintypmax_expression_in_paren 
        
identifier_bit_or_slice :
        identifier bit_or_slice(?) 

mintypmax_expression_in_paren :
        '(' mintypmax_expression ')'

number : 
	  decimal_number  
	| octal_number  
	| binary_number  
	| hex_number  
	| real_number

real_number : 
        sign(?) 
        ( two_unsigned_numbers_separated_by_decimal_point |
          unsigned_number_with_exponent |
         two_unsigned_numbers_separated_by_decimal_point_with_exponent 
        )


two_unsigned_numbers_separated_by_decimal_point :
        /[0-9_].*\.[0-9_].*/

unsigned_number_with_exponent :
        unsigned_number ( 'e' | 'E' ) sign(?) unsigned_number

two_unsigned_numbers_separated_by_decimal_point_with_exponent : 
        two_unsigned_numbers_separated_by_decimal_point
         ( 'e' | 'E' ) sign(?) unsigned_number

decimal_number : 
	  sign_unsigned_number 
	| size_decimal_base_unsigned_number

sign_unsigned_number :
        sign(?) 
	unsigned_number

size_decimal_base_unsigned_number :
        size(?) 
	decimal_base 
	unsigned_number

binary_number : 
	size(?)  
        binary_base 
        one_or_more_binary_digits_separated_by_optional_underscore

octal_number : 
	size(?) 
        octal_base 
        one_or_more_octal_digits_separated_by_optional_underscore


hex_number : 
        size(?) 
        hex_base 
        one_or_more_hex_digits_separated_by_optional_underscore

sign :
        '+' | '-'

size  : 
	unsigned_number

unsigned_number : 
	one_or_more_decimal_digits_possibly_separated_by_underscore


decimal_base :
	 "'d"  |  "'D"   

binary_base : 
	 "'b"  |  "'B"  

octal_base  : 
	 "'o"  |  "'O" 

hex_base  : 
	"'h"  |  "'H"  

decimal _digit : 
        /[0-9]/

binary_digit : 
        /[xXzZ01]/

octal_digit : 
        /[xXzZ0-7]/

hex_digit : 
        /[xXzZ0-9a-fA-F]/

        
concatenation : 
        '{' 
        one_or_more_expressions_separated_by_commas
        '}'

multiple_concatenation : 
        expression_catenation(s)

expression_concatenation :
        expression
        concatenation 

function_call : 
	  function_identifier_parameter_list 
	| name_of_system_function_parameter_list

function_identifier_parameter_list : 
        function_identifier 
          '(' 
        one_or_more_expressions_separated_by_commas
        ')'

name_of_system_function_parameter_list :
        name_of_system_function
        '(' 
        one_or_more_expressions_separated_by_commas
        ')'

# note, do not allow space between dollar and function name
name_of_system_function : 
        '$' identifier

string : 
        '"' any_string_character(s?) '"'

any_string_character : 
	/[a-zA-Z0-9_]/

#################################################################
# general
#################################################################


identifier :
        /[a-zA-Z][a-zA-Z_]*/






#################################################################
# lists with separators
#################################################################


one_or_more_binary_digits_separated_by_optional_underscore : 
	<leftop: binary_digit /(,)/ binary_digit>(?)

one_or_more_cmos_switch_instance_separated_by_commas : 
	<leftop: cmos_switch_instance /(,)/ cmos_switch_instance>(?)

one_or_more_decimal_digits_possibly_separated_by_underscore : 
	<leftop: decimal_digit /(,)/ decimal_digit>(?)

one_or_more_enable_gate_instance_separated_by_commas : 
	<leftop: enable_gate_instance /(,)/ enable_gate_instance>(?)

one_or_more_expressions_separated_by_commas : 
	<leftop: expression /(,)/ expression>(?)

one_or_more_hex_digits_separated_by_optional_underscore : 
	<leftop: hex_digit /(,)/ hex_digit>(?)

one_or_more_input_terminals_separated_by_commas : 
	<leftop: input_terminal /(,)/ input_terminal>(?)

one_or_more_input_port_identifier_separated_by_commas : 
	<leftop: input_port_identifier /(,)/ input_port_identifier>(?)

one_or_more_input_port_connections_separated_by_commas : 
	<leftop: input_port_connection /(,)/ input_port_connection>(?)

one_or_more_mos_switch_instance_separated_by_commas : 
	<leftop: mos_switch_instance /(,)/ mos_switch_instance>(?)

one_or_more_named_port_connections_separated_by_commas : 
	<leftop: named_port_connection /(,)/ named_port_connection>(?)

one_or_more_net_assignments_separated_by_commas : 
	<leftop: net_assignment /(,)/ net_assignment>(?)

one_or_more_net_decl_assignments_separated_by_commas : 
	<leftop: net_decl_assignment /(,)/ net_decl_assignment>(?)

one_or_more_n_input_gate_instance_separated_by_commas : 
	<leftop: n_input_gate_instance /(,)/ n_input_gate_instance>(?)

one_or_more_n_output_gate_instance_separated_by_commas : 
	<leftop: n_output_gate_instance /(,)/ n_output_gate_instance>(?)

one_or_more_octal_digits_separated_by_optional_underscore : 
	<leftop: octal_digit /(,)/ octal_digit>(?)

one_or_more_output_terminals_separated_by_commas : 
	<leftop: output_terminal /(,)/ output_terminal>(?)

one_or_more_ordered_port_connections_separated_by_commas : 
	<leftop: ordered_port_connection /(,)/ ordered_port_connection>(?)

one_or_more_parameter_assignments_serparated_by_commas : 
	<leftop: parameter_assignment /(,)/ parameter_assignment>(?)

one_or_more_pass_en_switch_instance_separated_by_commas : 
	<leftop: pass_en_switch_instance /(,)/ pass_en_switch_instance>(?)

one_or_more_pas_switch_instance_separated_by_commas : 
	<leftop: pas_switch_instance /(,)/ pas_switch_instance>(?)

one_or_more_ports_separated_by_commas : 
	<leftop: port /(,)/ port>(?)

one_or_more_port_identifiers_separated_by_commas : 
	<leftop: port_identifier /(,)/ port_identifier>(?)

one_or_more_port_references_separated_by_commas : 
	<leftop: port_reference /(,)/ port_reference>(?)

one_or_more_pull_gate_instance_seperated_by_commas : 
	<leftop: pull_gate_instance /(,)/ pull_gate_instance>(?)

one_or_more_real_identifiers_separated_by_commas : 
	<leftop: real_identifier /(,)/ real_identifier>(?)

one_or_more_register_names_separated_by_commas : 
	<leftop: register_name /(,)/ register_name>(?)

one_or_more_specify_input_terminal_descriptors_separated_by_commas : 
	<leftop: specify_input_terminal_descriptor /(,)/ specify_input_terminal_descriptor>(?)

one_or_more_specify_output_terminal_descriptors_separated_by_commas : 
	<leftop: specify_output_terminal_descriptor /(,)/ specify_output_terminal_descriptor>(?)

one_or_more_specparam_assignments_separated_by_commas : 
	<leftop: specparam_assignment /(,)/ specparam_assignment>(?)

one_or_more_udp_instances_separated_by_commas : 
	<leftop: udp_instance /(,)/ udp_instance>(?)


	};   # end of return statement



} #end of sub grammar

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

	unless ( ($text =~ /\\\*/) or  ($text =~ /\\\\/) or ($text =~ /\"/) )
		{ 
		$filtered_text .= $text ;
		last;
		}


	# look for comment or quoted string
	( $string_prior_to_line_comment, $string_after_line_comment)
		= split( /\\\\/ , $text, 2 );

	( $string_prior_to_block_comment, $string_after_block_comment)
		= split( /\\\*/ , $text, 2 );

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
		$text = '\\' . $string_after_line_comment;
		}

	elsif($bc_lt_q and $bc_lt_lc)
		{ 
		$state = 'blockcomment';
		$filtered_text .= $string_prior_to_block_comment;
		$text = '\*' . $string_after_block_comment;
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
		= split( /\*\\/ , $text, 2  );

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

 ###################
 # make everything lower case, VHDL identifiers are case insensitive
 ###################
 ### $filtered_text = lc($filtered_text);  
  ## well, maybe this isn't such a good solution after all.

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
 	$text = $obj->decomment_given_text($text);
 	$obj->design_file($text);
	}
}

#########################################################################
sub filename_to_text
#########################################################################
{
 my ($obj,$filename)=@_;
 open (FILE, $filename) or die "Cannot open $filename for read\n";
 my $text;
 while(<FILE>)
  {
  $text .= $_;
  }
 return $text;
}





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

Hardware::Verilog::Parser - Perl extension for parsing Verilog code

=head1 SYNOPSIS

  use Hardware::Verilog::Parser;
  $parser = new Hardware::Verilog::Parser;

  $parser->Filename(@ARGV);

=head1 DESCRIPTION

This module defines the complete grammar needed to parse any Verilog code.
By overloading this grammar, it is possible to easily create perl scripts
which run through VHDL code and perform specific functions.

This module is currently in PRE-RELEASE state, and subject to
change without notice. Once the grammar is ironed out, I hope
to declare it relatively stable.

=head1 AUTHOR

Greg London  greg42@bellatlantic.net

##################################################################
# Copyright (C) 2000 Greg London   All Rights Reserved.
# This program is free software; you can redistribute it and/or
# modify it under the same terms as Perl itself.
##################################################################

=head1 SEE ALSO

perl(1).
Parse::RecDescent

=cut

