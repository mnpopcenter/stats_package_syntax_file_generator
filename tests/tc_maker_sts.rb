# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require File.expand_path(File.join(File.dirname(__FILE__), 'setup.rb'))

module StatsPackageSyntaxFileGeneratorTest
class MakerSTS < Test::Unit::TestCase

include StatsPackageSyntaxFileGeneratorTestSetup

def test_create_maker_sts
    msg = 'Try to create an object.'
    mk = new_maker('sts')
    assert_instance_of SyntaxFile::MakerSTS, mk, msg
end

def test_syn_quoting
    msg = 'Quoting empty string.'
    mk = new_maker('sts')
    expected = "\"\""
    actual = mk.q('')
    assert_equal expected, actual, msg

    msg = 'Quoting string with quotes.'
    expected = "\"before''this is a ''test''after\""
    actual = mk.q('before"this is a "test"after')
    assert_equal expected, actual, msg
end

def test_syn_var_fmt
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sts')
    expected = [
        ' (A)',
        ' (F3.1)',
        '',
        ' (F4.3)',
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE CANTON URBAN RESPREV2) )
    actual = var_list.map { |v| mk.var_fmt(v) }
    assert_equal expected, actual, msg
end

def test_syn_var_loc_with_fmt
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sts')
    expected = [
        '1-1 (A)',
        '67 (F3.1)',
        '80-80',
        '80 (F4.3)',
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE CANTON URBAN RESPREV2) )
    actual = var_list.map { |v| mk.var_loc_with_fmt(v) }
    assert_equal expected, actual, msg
end

def test_supported_val
    msg = 'Incompat value label -- empty label'
    mk = new_maker('sts')
    expected = false
    actual = mk.supported_val?(SyntaxFile::Value.new(:value => 'FOO', :label => ''))
    assert_equal expected, actual, msg

    msg = 'Incompat value label -- pure whitespace label'
    mk = new_maker('sts')
    expected = false
    actual = mk.supported_val?(SyntaxFile::Value.new(:value => 'FOO', :label => '     '))
    assert_equal expected, actual, msg

    msg = 'Incompat value value -- pure whitespace value'
    mk = new_maker('sts')
    expected = false
    actual = mk.supported_val?(SyntaxFile::Value.new(:value => '   ', :label => 'FOO'))
    assert_equal expected, actual, msg

    msg = 'Incompat value value -- blank value'
    mk = new_maker('sts')
    expected = false
    actual = mk.supported_val?(SyntaxFile::Value.new(:value => '', :label => 'FOO'))
    assert_equal expected, actual, msg

    msg = 'Incompat value value -- nonalphanumeric value'
    mk = new_maker('sts')
    expected = false
    actual = mk.supported_val?(SyntaxFile::Value.new(:value => '@#(BAR)', :label => 'FOO'))
    assert_equal expected, actual, msg

    msg = 'Incompat value value -- value with space'
    mk = new_maker('sts')
    expected = false
    actual = mk.supported_val?(SyntaxFile::Value.new(:value => 'a thing', :label => 'FOO'))
    assert_equal expected, actual, msg

    msg = 'Compat value'
    mk = new_maker('sts')
    expected = true
    actual = mk.supported_val?(SyntaxFile::Value.new(:value => 'BAR', :label => 'FOO'))
    assert_equal expected, actual, msg
end

def test_syn_val_labs_for_var
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sts')
    expected = [
        [
            "  \\URBAN",
            "    1 \"Urban\"",
            "    2 \"Rural\""
        ],
        [
            "  \\RECTYPE",
            "    'H' \"Household\"",
            "    'P' \"Person\""
        ],
        [
        ],
        ["  \\RENT",
 "    '......................................40........50........60........70........80........90.......100.......110.......120.......130.......140.......150.......160.......170.......180.......190.......200.......210.......220.......230.......240.......250.......260.......270.......280.......290.......300' \"[no label]............................40........50........60........70........80........90.......100.......110.......120.......130.......140.......150.......160.......170.......180.......190.......200.......210.......220.......230.......240.......250.......260.......270.......280.......290.......300\"",
 "    '0070'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0075'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0080'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0085'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0100'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0120'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0125'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0130'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0140'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0150'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0160'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0175'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0200'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0210'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0225'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0240'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0250'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0300'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0400'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0425'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0454'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0500'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0550'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '0700'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '1800'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '2000'                                                                                                                                                                                                                                                                                                       \"[no label]\"",
 "    '8501'                                                                                                                                                                                                                                                                                                       \"[no label]\""]
    ]
    var_list = names_to_vars( mk.sfc, %w(URBAN RECTYPE DWNUM RENT) )
    var_list.each_index { |i|
        actual = mk.syn_val_labs_for_var(var_list[i])
        assert_equal expected[i], actual, msg
    }
end

def test_syn_var_labs
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sts')
    expected = ["VARIABLE LABELS",
    "  HHNUM     \"''Household number''\"",
    "  HDFIRSTD  \"Head not first [''dwelling-wide''] {note}\"",
    "  CANTON    \"Canton ''geo area''\"",
    "  SEX       \".........x.........x.........x.........x.........x.........x.........x.........x.........x.........x.........x.........x.........x.........x.........x\"",
    "",
    ""]
    var_list = names_to_vars( mk.sfc, %w(HHNUM HDFIRSTD CANTON SEX) )
    var_list[-1].label = '.........x' * 15
    actual = mk.syn_var_labs(var_list)
    assert_equal expected, actual, msg
end

def test_syn_var_locations
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sts')
    expected = [
       "VARIABLES",
       "  RECTYPE   1-1 (A)  \\RECTYPE",
       "  CANTON    67 (F3.1)  ",
       "  AGE       69-71  ",
       "  LIT       101-101  \\LIT"
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE CANTON AGE LIT) )
    actual = mk.syn_var_locations(var_list)
    assert_equal expected, actual, msg
end

end
end