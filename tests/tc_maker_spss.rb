# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require File.expand_path(File.join(File.dirname(__FILE__), 'setup.rb'))

module StatsPackageSyntaxFileGeneratorTest
class MakerSPSS < Test::Unit::TestCase

include StatsPackageSyntaxFileGeneratorTestSetup

def test_create_maker_spss
    msg = 'Try to create an object.'
    mk = new_maker('spss')
    assert_instance_of SyntaxFile::MakerSPSS, mk, msg
end

def test_syn_dfh_file_type
    msg = 'Compare against hardcoded result.'
    mk = new_maker('spss')
    expected = [
        'file type mixed',
        '  /file = "xx9999a.dat"',
        '  /record = 1-1 (a)',
        '.',
        '',
    ]
    assert_equal expected, mk.syn_dfh_file_type, msg
end

def test_syn_dfh_data_block_start
    msg = 'Compare against hardcoded result.'
    mk = new_maker('spss')
    expected = [
        'record type "H".',
        'data list /',
    ]
    actual = mk.syn_dfh_data_block_start('H')
    assert_equal expected, actual, msg
end

def test_syn_var_locations
    msg = 'Compare against hardcoded result.'
    mk = new_maker('spss')
    expected = [
        '  RECTYPE   1-1 (a)',
        '  CANTON    67-69 (1)',
        '  AGE       69-71',
        '  LIT       101-101',
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE CANTON AGE LIT) )
    actual = mk.syn_var_locations(var_list)
    assert_equal expected, actual, msg
end

def test_syn_var_labs
    msg = 'Compare against hardcoded result.'
    mk = new_maker('spss')
    expected = [
        'variable labels',
        '  HHNUM       """Household number"""',
        '  HDFIRSTD    "Head not first [""dwelling-wide""] {note}"',
        '  CANTON      "Canton ""geo area"""',
        '  SEX         ".........x.........x.........x.........x.........x.........x.........x.........x.........x.........x"',
        '            + ".........x.........x"',
        '.',
        '',
    ]
    var_list = names_to_vars( mk.sfc, %w(HHNUM HDFIRSTD CANTON SEX) )
    var_list[-1].label = '.........x' * 15
    actual = mk.syn_var_labs(var_list)
    assert_equal expected, actual, msg
end

def test_syn_val_labs_for_var
    msg = 'Compare against hardcoded result.'
    mk = new_maker('spss')
    expected = [
        [
            '  /RECTYPE',
            '    "H"   "Household"',
            '    "P"   "Person"',
        ],
        [
            '  /URBAN',
            '    1   "Urban"',
            '    2   "Rural"',
        ],
        [
            '  /SEX',
            '    1   "Male"',
            '    2   ".........x.........x.........x.........x.........x.........x.........x.........x.........x.........x"',
            '      + ".........x.........x"',
        ],
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE URBAN SEX) )
    var_list[-1].values[-1].label = '.........x' * 15
    var_list.each_index { |i|
        actual = mk.syn_val_labs_for_var(var_list[i])
        assert_equal expected[i], actual, msg
    }
end

def test_var_fmt
    msg = 'Compare against hardcoded result.'
    mk = new_maker('spss')
    expected = [
        ' (a)',
        ' (1)',
        '',
        ' (3)',
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE CANTON URBAN RESPREV2) )
    actual = var_list.map { |v| mk.var_fmt(v) }
    assert_equal expected, actual, msg
end

def test_csv_import
    msg = 'Compare against hardcoded result.'
    mk = new_maker('spss', csv: true)
    syn_df = mk.syn_df
    assert_equal 'GET DATA  /TYPE=TXT', syn_df[0], msg
    assert_equal '  /FILE="data.csv"', syn_df[1], msg
    assert_equal '  RECTYPE   A', syn_df[9], msg
    assert_equal '  /MAP.', syn_df[-2], msg
    assert_equal 'execute.', syn_df[-1], msg
end


end
end
