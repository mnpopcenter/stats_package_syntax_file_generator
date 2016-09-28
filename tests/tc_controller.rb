# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require File.expand_path(File.join(File.dirname(__FILE__), 'setup.rb'))

module StatsPackageSyntaxFileGeneratorTest
class Controller < Test::Unit::TestCase

VARS_C = %w(RECTYPE DWNUM HHNUM HDFIRSTD FBIG_ND BADDW)
VARS_H = %w(CANTON URBAN DWTYPE OWNERSHP RENT)
VARS_P = %w(RELATE SEX AGE RESPREV2 SOCSEC EDLEVEL LIT BIGDEC BIGINT BIGSTR)
VARS_ALL = [VARS_C, VARS_H, VARS_P].flatten

include StatsPackageSyntaxFileGeneratorTestSetup

def test_create_controller
    msg = 'Try to create an object.'
    sfc = new_controller()
    assert_instance_of SyntaxFile::Controller, sfc, msg
end

def test_add_variable
    sfc = new_controller()
    n = sfc.variables.size
    var = sfc.add_variable( params_variable )

    msg = 'The method should increase the N of variables.'
    assert_equal n + 1, sfc.variables.size, msg

    msg = 'The method should return the added variable.'
    assert_instance_of SyntaxFile::Variable, var, msg
    assert_equal params_variable_lookup(:name), var.name, msg
    assert_equal params_variable_lookup(:label), var.label, msg
end

def test_clear_variables
    msg = 'The method should remove all variables.'
    sfc = new_controller()
    assert_equal VARS_ALL.size, sfc.variables.size, msg
    sfc.clear_variables
    assert_equal 0, sfc.variables.size, msg
end

def test_get_var_by_name
    sfc = new_controller()

    msg = 'The method should return the correct variable.'
    nm = 'RELATE'
    var = sfc.get_var_by_name(nm)
    assert_equal nm, var.name, msg

    msg = 'The method should return nil if given an invalid name.'
    nm = 'fubb'
    var = sfc.get_var_by_name(nm)
    assert_nil var, msg

    msg = 'The method should return the FIRST variable that matches.'
    pv = params_variable()
    nm = 'RELATE'
    pv[:name] = nm
    sfc.add_variable(pv)
    var = sfc.get_var_by_name(nm)
    assert_equal     "Relationship to household head", var.label, msg
    assert_not_equal pv[:label],                       var.label, msg
end

def test_get_vars_by_record_type
    sfc = new_controller()

    var_lists = {
        'H' => [VARS_C, VARS_H].flatten,
        'P' => [VARS_C, VARS_P].flatten,
    }

    msg = 'The method should return the correct variables '
    var_lists.each { |k, v|
        vars = sfc.get_vars_by_record_type(k)
        assert_equal var_lists[k], vars_to_names(vars), msg + "(#{k} record)"
    }

    msg = 'The method should return common variables if given an invalid record type.'
    vars = sfc.get_vars_by_record_type('.')
    assert_equal VARS_C, vars_to_names(vars), msg

    msg = 'The method should return the correct variables (no common vars).'
    pv = params_variable()
    sfc.clear_variables
    sfc.add_variable(pv)
    sfc.add_variable(pv)
    vars = sfc.get_vars_by_record_type('P')
    assert_equal [pv[:name], pv[:name]], vars_to_names(vars), msg

    msg = 'The method should return [] if given an invalid record type (no common vars).'
    vars = sfc.get_vars_by_record_type('H')
    assert_equal [], vars, msg
end

def test_get_vars_with_var_labels
    sfc = new_controller()

    without_labels = %w(SOCSEC)
    var_list = VARS_ALL.reject { |v| without_labels.include?(v) }

    msg = 'The method should return the correct variables.'
    vars = sfc.get_vars_with_var_labels
    assert_equal var_list, vars_to_names(vars), msg
end

def test_get_vars_with_values
    sfc = new_controller()

    without_values = %w(AGE DWNUM CANTON RESPREV2 BIGDEC BIGINT BIGSTR)
    var_list = VARS_ALL.reject { |v| without_values.include?(v) }

    msg = 'The method should return the correct variables.'
    vars = sfc.get_vars_with_values
    assert_equal var_list, vars_to_names(vars), msg
end

def test_record_type_var
    sfc = new_controller()

    msg = 'The method should return the correct variable.'
    assert_equal 'RECTYPE', sfc.record_type_var.name, msg

    msg = 'The method should return nil if there is no record type variable.'
    sfc.record_type_var_name = ''
    assert_nil sfc.record_type_var, msg
end

def test_add_value
    sfc = new_controller()

    msg = 'The method should increase the N of values.'
    var = sfc.add_variable( params_variable )
    n = 5
    (1..n).each { |v| sfc.add_value(:value => v) }
    assert_equal n, var.values.size, msg
end

def test_new_values
    sfc = new_controller()

    msg = 'The method should result in a variable with values.'
    var = sfc.add_variable(
        :name              => 'foo',
        :start_column      => 1,
        :width             => 4,
        :values            => sfc.new_values(
            {:value => 1},
            {:value => 2},
            {:value => 3}
        )
    )
    assert_equal 3, var.values.size, msg

    msg = 'The method should also accept an array.'
    val_list = (1..10).map {|i| {:value => i}}
    var = sfc.add_variable(
        :name              => 'bar',
        :start_column      => 22,
        :width             => 4,
        :values            => sfc.new_values(val_list)
    )
    assert_equal val_list.size, var.values.size, msg
end

def test_is_last_record_type
    sfc = new_controller()

    msg = 'Compare against hardcoded result.'
    sfc.record_types = %w(F U B A R)
    assert_equal true,  sfc.is_last_record_type('R'), msg
    assert_equal false, sfc.is_last_record_type('A'), msg
    assert_equal false, sfc.is_last_record_type('x'), msg

    msg = 'Should return false if there are no record types'
    sfc.record_types = []
    assert_equal false, sfc.is_last_record_type(1), msg
end

def test_rec_types_except_last
    sfc = new_controller()

    msg = 'Compare against hardcoded result.'
    sfc.record_types = %w(F U B A R)
    assert_equal %w(F U B A), sfc.rec_types_except_last, msg

    msg = 'Calling the method should not affect @record_types.'
    sfc.record_types = %w(F U B A R)
    assert_equal %w(F U B A R), sfc.record_types, msg

    msg = 'Should return empty array if there are no record types.'
    sfc.record_types = []
    assert_equal [], sfc.rec_types_except_last, msg
end

def test_max_var_name_length
    sfc = new_controller()

    msg = 'The method should return the correct value.'
    assert_equal 8, sfc.max_var_name_length, msg

    msg = 'The method should return 0 if there are no Variables.'
    sfc.clear_variables
    assert_equal 0, sfc.max_var_name_length, msg
end

def test_max_col_loc_width
    sfc = new_controller()

    msg = 'Compare against hardcoded result.'
    assert_equal 3, sfc.max_col_loc_width, msg

    msg = 'The method should return 0 if there are no Variables.'
    sfc.clear_variables
    assert_equal 0, sfc.max_col_loc_width, msg
end

def test_generate_syntax_files
    output_dir = File.join(
        File.expand_path(File.dirname(__FILE__)),
        'output'
    )
    Dir.mkdir(output_dir) unless File.directory?(output_dir)

    msg = 'Make sure the testing output directory exists.'
    assert File.directory?(output_dir), msg

    # Remove files generated during any previous test.
    stem = 'testing'
    expected_files = %w(do sas sps sts).map { |e| stem + '.' + e }
    remove_file_from_dir(output_dir, expected_files)

    msg = 'Make sure the testing output directory is empty.'
    assert_equal [], dir_contents(output_dir), msg

    msg = 'Make sure the method creates the expected files.'
    sfc = new_controller()
    sfc.output_dir_name  = output_dir
    sfc.output_file_stem = '%s'
    sfc.data_file_name   = stem
    sfc.generate_syntax_files
    assert_equal expected_files, dir_contents(output_dir), msg

    msg = 'Remove the files and make sure no files remain.'
    remove_file_from_dir(output_dir, expected_files)
    assert_equal [], dir_contents(output_dir), msg
    Dir.delete(output_dir)
end

def test_syntax
    msg = 'Make sure that syntax generation works same way, regardless of order.'
    sfc = new_controller()
    formats = sfc.output_formats
    syntax1 = {}
    syntax2 = {}
    formats.each         { |f| syntax1[f] = sfc.syntax(f) }
    formats.reverse.each { |f| syntax2[f] = sfc.syntax(f) }
    assert_equal formats.map { |f| [f, true] },
                 formats.map { |f| [f, syntax1[f] == syntax2[f]] },
                 msg
end

def test_modify_metadata_all_vars_as_string
    sfc = new_controller()

    # A Proc to count N of string variables.
    string_vars_n = lambda { sfc.variables.inject(0) { |n, v| n + (v.is_string_var ? 1 : 0) } }

    msg = 'Every variable should be a string variable: '
    orig = string_vars_n.call
    sfc.all_vars_as_string = true
    sfc.modify_metadata
    assert_not_equal(orig,           string_vars_n.call, msg + 'vs orig')
    assert_equal(sfc.variables.size, string_vars_n.call, msg + 'all')
end

def test_modify_metadata_select_vars_by_record_type
    sfc = new_controller()

    msg = 'Should have no effect if all record types are still present.'
    sfc.select_vars_by_record_type = true
    sfc.modify_metadata
    assert_equal(VARS_ALL.size, sfc.variables.size, msg)

    msg = 'Just person variables.'
    sfc.record_types = ['P']
    sfc.modify_metadata
    assert_equal(VARS_C.size + VARS_P.size, sfc.variables.size, msg)

    msg = 'Just common variables if there are no record types.'
    sfc.record_types = []
    sfc.modify_metadata
    assert_equal(VARS_C.size, sfc.variables.size, msg)

    msg = 'The rectangularize option requires select_vars_by_record_type.'
    sfc = new_controller()
    sfc.rectangularize = true
    assert_equal(false, sfc.select_vars_by_record_type, msg)
    sfc.modify_metadata
    assert_equal(true, sfc.select_vars_by_record_type, msg)
end

def test_validate_metadata
    msg = 'Invalid metadata: no variables'
    sfc = new_controller()
    sfc.clear_variables
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }

    msg = 'Invalid metadata: no output formats'
    sfc = new_controller()
    sfc.output_formats = []
    assert_raise(RuntimeError, msg) { sfc.generate_syntax_files }

    msg = 'Invalid metadata: hier without any record types'
    sfc = new_controller()
    sfc.record_types = []
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }

    msg = 'Invalid metadata: rectangularize without hier'
    sfc = new_controller()
    sfc.rectangularize = true
    sfc.data_structure = 'rect'
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }

    msg = 'Invalid metadata: hier without a record type variable'
    sfc = new_controller()
    sfc.record_type_var_name = ''
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }

    msg = 'Invalid metadata: hier with a variable that lacks a record type'
    sfc = new_controller()
    sfc.get_var_by_name('SEX').record_type = ''
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }

    msg = 'Invalid metadata: variable with invalid start_column'
    sfc = new_controller()
    sex_var = sfc.get_var_by_name('SEX')
    sex_var.start_column = -1
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }
    sex_var.start_column = 'a'
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }
    sex_var.start_column = 0
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }

    msg = 'Invalid metadata: variable with invalid width'
    sfc = new_controller()
    sex_var = sfc.get_var_by_name('SEX')
    sex_var.width = -1
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }
    sex_var.width = 'a'
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }
    sex_var.width = 0
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }

    msg = 'Invalid metadata: variable with implied_decimals'
    sfc = new_controller()
    sex_var = sfc.get_var_by_name('SEX')
    sex_var.implied_decimals = -1
    assert_raise(RuntimeError, msg) { sfc.syntax('spss') }
end

def test_rec_type_lookup_hash
    sfc = new_controller()

    msg = 'Compare against hardcoded result.'
    assert_equal( {'P' => 0, 'H' => 0}, sfc.rec_type_lookup_hash, msg )

    msg = 'Should return empty hash if there are no record types.'
    sfc.record_types = []
    assert_equal( {}, sfc.rec_type_lookup_hash, msg )
end

end
end
