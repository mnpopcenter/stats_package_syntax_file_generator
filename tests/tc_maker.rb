# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require File.expand_path(File.join(File.dirname(__FILE__), 'setup.rb'))

module StatsPackageSyntaxFileGeneratorTest
class Maker < Test::Unit::TestCase

include StatsPackageSyntaxFileGeneratorTestSetup

def test_create_maker
    msg = 'Try to create an object.'
    mk = new_maker()
    assert_instance_of SyntaxFile::Maker, mk, msg
end

def test_syntax_end
    msg = 'Compare against hardcoded result.'
    mk = new_maker()
    mk.cmd_end = '.'
    assert_equal ['.', ''], mk.syntax_end, msg
end

def test_q
    msg = 'Compare against hardcoded result.'
    mk = new_maker()
    orig   = %q{"A "quoted" 'string' with ""extra-quotes"""}
    quoted = %q{"""A ""quoted"" 'string' with """"extra-quotes"""""""}
    assert_equal quoted, mk.q(orig), msg
end

def test_val_q
    msg = 'Numeric variable: the method should convert to string.'
    mk = new_maker()
    v = new_variable()
    assert_equal '1234', mk.val_q(v, 1234), msg

    msg = 'String variable: the method should convert to string and quote.'
    v.is_string_var = true
    assert_equal '"123456"', mk.val_q(v, 123456), msg
    assert_equal '"-123456"', mk.val_q(v, -123456), msg
end

def test_val_as_s
    msg = 'Numeric variable: the method should convert to string.'
    mk = new_maker()
    v = new_variable()
    assert_equal '1234', mk.val_as_s(v, 1234), msg

    msg = 'String variable, non-integer value: the method should convert to string.'
    v.is_string_var = true
    assert_equal 'ab',    mk.val_as_s(v, 'ab'), msg
    assert_equal '123.2', mk.val_as_s(v, 123.2), msg
    assert_equal '',      mk.val_as_s(v, ''), msg

    msg = 'String variable, integer value: the method should convert to string and zero-pad.'
    assert_equal '0012',    mk.val_as_s(v, 12), msg
    assert_equal '-034',    mk.val_as_s(v, -34), msg
    assert_equal '123456',  mk.val_as_s(v, 123456), msg
    assert_equal '-123456', mk.val_as_s(v, -123456), msg
end

def test_label_trunc
    msg = 'Compare against hardcoded result.'
    mk = new_maker()
    assert_equal '12',   mk.label_trunc(123,  2), msg
    assert_equal '123',  mk.label_trunc(123, 12), msg
    assert_equal '',     mk.label_trunc('',  12), msg
    assert_equal 'foo_', mk.label_trunc('foo_bar', 4), msg
end

def test_label_segments
    mk = new_maker()

    msg = 'Non-string should be converted to string.'
    assert_equal ['12345'],     mk.label_segments(12345, 10), msg
    assert_equal ['123', '45'], mk.label_segments(12345, 3), msg

    msg = 'Empty string and nil should work.'
    assert_equal [''], mk.label_segments('',  10), msg
    assert_equal [''], mk.label_segments(nil, 10), msg

    msg = 'Compare against hardcoded result.'
    label = "A really long label"
    label_copy = String.new(label)
    expected = [
        'A reall',
        'y long ',
        'label',
    ]
    assert_equal expected, mk.label_segments(label, 7), msg

    msg = 'Make sure the original string was not destroyed.'
    assert_equal label_copy, label, msg
end

def test_weave_label_segments
    # Compare against hardcoded result
    mk = new_maker()
    fmt = "%-7s %s %-7s"
    a = [
        "a very",
        "long v",
        "alue",
    ]
    b = [
        "a very",
        "long l",
        "abel",
    ]
    expected = [
        "a very  +        ",
        "long v  +        ",
        "alue    = a very ",
        "        + long l ",
        "        + abel   ",
    ]
    assert_equal expected, mk.weave_label_segments(fmt, a, b, '=', '+')
end

def test_labelable_values
    msg = 'Non-integer values should not be treated as labelable values.'
    mk = new_maker()
    var = new_variable()
    add_new_values_to_var(var)
    n = var.values.size
    var.add_value(:value => 'X')
    var.add_value(:value => '123x')
    var.add_value(:value => '')
    var.add_value(:value => -123)
    assert_equal n + 4, var.values.size, msg
    assert_equal n + 1, mk.labelable_values(var).size, msg
end

def test_max_value_length
    msg = 'Compare against hardcoded result.'
    mk = new_maker()
    var = new_variable()

    msg = 'A variable with no values should have a max_value_length of zero.'
    assert_equal 0, mk.max_value_length(var, var.values), msg

    msg = 'The method should agree with direct computation.'
    add_new_values_to_var(var)
    mx = params_values().map { |pv| pv[:value].to_s.length }.max
    assert_equal mx, mk.max_value_length(var, var.values), msg

    msg = 'Compare against hardcoded result.'
    var.add_value( params_value(123456789012345) )
    assert_equal 15, mk.max_value_length(var, var.values), msg
end

def test_comments_start
    msg = 'Only web_app uses comments.'
    mk = new_maker()
    mk.sfc.caller = 'vb'
    assert_equal '', mk.comments_start.join(''), msg
    mk.sfc.caller = 'web_app'
    assert_not_equal '', mk.comments_start.join(''), msg
end

def test_comments_end
    msg = 'Compare against hardcoded result.'
    mk = new_maker()
    assert_equal [], mk.comments_end, msg
end


end
end
