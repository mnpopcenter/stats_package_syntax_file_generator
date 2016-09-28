# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require File.expand_path(File.join(File.dirname(__FILE__), 'setup.rb'))

module StatsPackageSyntaxFileGeneratorTest
class Variable < Test::Unit::TestCase

include StatsPackageSyntaxFileGeneratorTestSetup

def test_create_variable
    msg = 'Try to create an object.'
    v = new_variable()
    assert_instance_of SyntaxFile::Variable, v, msg

    msg = 'Try to create an object with required parameters missing.'
    assert_raise(ArgumentError, msg) { SyntaxFile::Variable.new }
end

def test_column_locations_as_s
    msg = 'Compare against hardcoded result.'
    v = new_variable()
    e = params_variable_lookup(:column_locations_as_s)
    assert_equal e, v.column_locations_as_s, msg
end

def test_end_column
    msg = 'Compare against hardcoded result.'
    v = new_variable()
    e = params_variable_lookup(:end_column)
    assert_equal e, v.end_column, msg
end

def test_add_and_clear_values
    v = new_variable()

    msg = 'New variable should have no values.'
    assert_equal 0, v.values.size, msg

    msg = 'Adding a value N times should yield a variable with N values.'
    n = params_values().size
    add_new_values_to_var(v)
    assert_equal n, v.values.size, msg

    msg = 'After clearing its values, a variable should have no values.'
    v.clear_values
    assert_equal 0, v.values.size, msg
end

end
end
