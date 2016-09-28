#!/usr/bin/ruby

# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator


# An script used in end-to-end acceptance testing.
# It exercises the syntax file utility via its API
# rather than through a YAML config file.

require File.expand_path(File.dirname(__FILE__)) + '/../lib/stats_package_syntax_file_generator.rb'

# Controller metadata.
sfc = SyntaxFile::Controller.new
sfc.project                    = 'ipumsi'
sfc.caller                     = 'dcp'
sfc.data_dir_name              = 'data'
sfc.data_file_name             = '__my_data.dat'
sfc.output_formats             = %w(sas spss stata sts)
sfc.output_dir_name            = 'devel/output_result'
sfc.output_file_stem           = '_%s'
sfc.output_overwrite           = false
sfc.data_structure             = 'rect'
sfc.record_types               = %w(H P)
sfc.record_type_var_name       = 'RECTYPE'
sfc.rectangularize             = false
sfc.all_vars_as_string         = false
sfc.select_vars_by_record_type = false

# Add a variable.
sfc.add_variable(
    :name              => 'RECTYPE',
    :label             => 'Record type',
    :start_column      => 1,
    :width             => 1,
    :is_string_var     => true,
    :is_common_var     => true,
    :record_type       => 'H',
    :implied_decimals  => 0,
    :suppress_labels   => false
)

# The add_value() method adds a Value to the last variable (the
# variable most recently added).
[
    {:value => 'H', :label => 'Household record'},
    {:value => 'P', :label => 'Person record'},
].each { |v| sfc.add_value(v) }

# Add another variable.
# In this case, values are supplied via new_values().
sfc.add_variable(
    :name              => 'EMPSTAT',
    :label             => 'Employment status',
    :start_column      => 2,
    :width             => 2,
    :is_string_var     => false,
    :is_common_var     => false,
    :record_type       => 'P',
    :implied_decimals  => 0,
    :suppress_labels   => false,
    :values            => sfc.new_values(
        # The list of hashes can be passed like this, or as an Array.
        {:value =>  1, :label => 'Employed'},
        {:value =>  2, :label => 'Unemployed'},
        {:value => 98, :label => 'Unknown'},
        {:value => 99, :label => 'Not in universe'}
    )
)

# Generate the syntax files.
sfc.generate_syntax_files
