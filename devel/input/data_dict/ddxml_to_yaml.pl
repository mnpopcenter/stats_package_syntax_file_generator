#!/usr/bin/perl

# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

# This script reads an XML dump of a data dictionary and converts
# it into the type of YAML needed by the syntax file utility.
#
# Takes XML file name.
# Writes YAML to STDOUT.
#
# If 'select' is supplied as a 2nd argument, the script processes 
# only those variables with a <select> attribute set to 1.

use warnings;
use strict;
use XML::Twig;

# Concordance between YAML keys and XML keys.
my %KEY_MAP = (
    # YAML               # XML
    name              => 'var',
    label             => 'lab',
    start_column      => 'col',
    width             => 'wid',
    is_string_var     => 'frm',
    is_common_var     => 'recordtype',
    record_type       => 'recordtype',
    implied_decimals  => 'frm',
    suppress_labels   => 'notes',
);

# Order in which to write the YAML keys.
my @KEY_ORDER = qw(
    name
    label
    start_column
    width
    is_string_var
    is_common_var
    record_type
    implied_decimals
    suppress_labels
);

die "Command-line arguments: XML_FILE [select [RT]]\n" unless @ARGV and -f $ARGV[0];
main(@ARGV);

sub main {
    my ($data_dict_xml, $all, $rectype) = @_;
    $all = (defined $all and $all eq 'select') ? 0 : 1;
    $rectype = '' unless defined $rectype;
    my @variables_as_yaml;
    my $twig = XML::Twig->new;
    die "Unable to read data dict XML.\n"
        unless $twig->safe_parsefile($data_dict_xml);

    for my $variable ($twig->root->children('variable')){
        my $rt = $variable->first_child_trimmed_text('recordtype');
        next unless $rectype eq '' or $rectype eq $rt or $rt eq 'C';
        next unless $all or
                    $variable->first_child_trimmed_text('sel') == 1;
        push @variables_as_yaml, variable_as_yaml($variable);
    }

    print $_, "\n" for
        '---',
        '',
        'variables:',
        '',
        @variables_as_yaml
    ;
}

# Takes an XML <variable> as a twig and returns a list of YAML lines.
sub variable_as_yaml {
    my $variable = shift;

    # Get the variable attributes.
    my %ym = map {
        $_ => $variable->first_child_trimmed_text( $KEY_MAP{$_} )
    } @KEY_ORDER;

    # Cleanup some of the attributes, converting the conventions used
    # in data dictionaries to those needed in the YAML.
    cleanup_rectype(\%ym);
    cleanup_var_type(\%ym);
    $ym{label} = cleanup_label($ym{label});
    $ym{name} = uc $ym{name};
    $ym{suppress_labels} = $ym{suppress_labels} eq 'suppress' ? 'true' : 'false';
    my $is_string_var = $ym{is_string_var} eq 'true' ? 1 : 0;

    # Get the values as YAML.
    my @values_as_yaml = ('  values:');
    for my $value ( $variable->children('value') ){
        push @values_as_yaml, value_as_yaml($value, $is_string_var);
    }
    $values_as_yaml[0] .= ' []' unless @values_as_yaml > 1;

    return
        '-',
        map( "  $_: $ym{$_}", @KEY_ORDER),
        @values_as_yaml,
        '',
    ;
}

# Takes an XML <value> as a twig and returns a list of YAML lines.
sub value_as_yaml {
    my $value = shift;
    my $is_string_var = shift;
    my $v = $value->first_child_trimmed_text('val');
    if ($is_string_var){
        my $q = '"';
        $v =~ s/$q/\\$q/g;
        $v = $q . $v . $q;
    }
    return
        '  -',
        '    value: ' . $v,
        '    label: ' . cleanup_label($value->first_child_trimmed_text('lab')),
        '    is_missing_value: false',
    ;
}

sub cleanup_label {
    my $lab = shift;
    my $q = q{\"};
    $lab =~ s/\"/$q/g;
    return qq{"$lab"};
}

# Cleanup attributes relating to record type.
sub cleanup_rectype {
    my $r = shift;
    if ( substr($r->{record_type}, 0, 1) eq 'C' ){
        $r->{record_type} = 'H';
        $r->{is_common_var} = 'true';
    }
    else {
        $r->{is_common_var} = 'false';
    }
}

# Cleanup attributes relating to stats package variable type.
sub cleanup_var_type {
    my $r = shift;
    if ( lc($r->{is_string_var}) eq 'a' ){
        $r->{is_string_var}    = 'true';
        $r->{implied_decimals} = 0;
    }
    elsif ($r->{is_string_var} eq ''){
        $r->{is_string_var}    = 'false';
        $r->{implied_decimals} = 0;
    }
    else {
        $r->{is_string_var}    = 'false';
    }
}
