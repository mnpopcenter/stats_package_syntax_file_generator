# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require File.expand_path(File.join(File.dirname(__FILE__), 'setup.rb'))

module StatsPackageSyntaxFileGeneratorTest
class MakerSAS < Test::Unit::TestCase

include StatsPackageSyntaxFileGeneratorTestSetup

def test_create_maker_sas
    msg = 'Try to create an object.'
    mk = new_maker('sas')
    assert_instance_of SyntaxFile::MakerSAS, mk, msg
end

def test_syn_fmt_big_nums
  msg = "Compare against hardcoded result."
  mk = new_maker('sas')
  expected = [
      "  BIGDEC    11.5",
      "  BIGINT    19."
  ]
  var_list = names_to_vars( mk.sfc, %w(BIGDEC BIGINT) )
  actual = mk.syn_fmt_big_nums_for_var_list(var_list)
  assert_equal expected, actual, msg
end

def test_syn_val_labs_for_var_start
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sas')
    expected = [
        'value $ RECTYPE_f',
        'value SEX_f',
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE SEX) )
    var_list.each_index { |i|
        actual = mk.syn_val_labs_for_var_start(var_list[i])
        assert_equal expected[i], actual, msg
    }
end

def test_syn_val_labs_for_var
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sas')
    expected = [
        [
          '  "H" = "Household"',
          '  "P" = "Person"',
        ],
        [
          '  1 = "Directly covered person"',
          '  2 = "Covered through family member"',
          '  3 = "Not covered"',
        ],
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE SOCSEC) )
    var_list.each_index { |i|
        actual = mk.syn_val_labs_for_var(var_list[i])
        assert_equal expected[i], actual, msg
    }
end

def test_syn_val_lab_for_val
    msg = 'Compare against hardcoded result.'
    fmt = "  %-8s %s %s"
    mk = new_maker('sas')
    var = new_variable()
    var.values[0] = new_value()
    tests = [
        [ false,  99, 'fubb',  ['  99       = "fubb"'] ],
        [ false,   9, 'fubb',  ['  9        = "fubb"'] ],
        [ true,  'a', 'fubb',  ['  "a"      = "fubb"'] ],
        [
            true,
            'x' * 120,
            'fubb' * 30,
            [
                '  "' + ('x' * 100) + '"   ',
                '  "' + ('x' *  20) + '" = "' + ('fubb' * 25) + '"',
                '             "'              + ('fubb' *  5) + '"',
            ]
        ],
    ]
    tests.each_index { |i|
        var.is_string_var   = tests[i][0]
        var.values[0].value = tests[i][1]
        var.values[0].label = tests[i][2]
        actual = mk.syn_val_lab_for_val(var, var.values[0], fmt)
        assert_equal tests[i][3], actual, msg
    }
end

def test_syn_var_locations
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sas')
    expected = [
        '  RECTYPE  $ 1-1',
        '  DWNUM      2-7',
        '  SEX        68-68',
        '  AGE        69-71',
        '  RESPREV2   80-83 .3',
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE DWNUM SEX AGE RESPREV2) )
    actual = mk.syn_var_locations(var_list)
    assert_equal expected, actual, msg
end

def test_syn_dfh_retain
    mk = new_maker('sas')

    msg = 'Compare against hardcoded result.'
    expected = [
        'retain',
        '  CANTON',
        '  URBAN',
        '  DWTYPE',
        '  OWNERSHP',
        '  RENT',
        ';',
        '',
    ]
    mk.sfc.rectangularize = true
    assert_equal expected, mk.syn_dfh_retain, msg

    msg = 'Should be empty list if rectangularize option is not set.'
    expected = []
    mk.sfc.rectangularize = false
    assert_equal expected, mk.syn_dfh_retain, msg

    msg = 'Should be empty list if there are no variables.'
    expected = []
    mk.sfc.rectangularize = true
    mk.sfc.clear_variables
    assert_equal expected, mk.syn_dfh_retain, msg
end

def test_syn_dfh_rec_type_block
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sas')
    expected = [
        'input',
        '  RECTYPE  $ 1-1 @',
        ';',
    ]
    actual = mk.syn_dfh_rec_type_block
    assert_equal expected, actual, msg
end

def test_syn_dfh_if_start
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sas')
    expected = [
        'if RECTYPE = "H" then do;',
        'else if RECTYPE = "P" then do;',
    ]
    actual = [
        mk.syn_dfh_if_start('if',      'H'),
        mk.syn_dfh_if_start('else if', 'P'),
    ]
    expected.each_index { |i| assert_equal expected[i], actual[i], msg }
end

def test_syn_dfh_if_end
    msg = 'Compare against hardcoded result: no rectangularize, '
    mk = new_maker('sas')
    expected = {
        'H' => [ 'output;', 'end;', '' ],
        'P' => [ 'output;', 'end;', '' ],
    }
    mk.sfc.rectangularize = false
    expected.each { |k,v|
        assert_equal expected[k], mk.syn_dfh_if_end(k), msg + k
    }

    msg = 'Compare against hardcoded result: rectangularize, '
    mk.sfc.rectangularize = true
    expected['H'].shift
    expected.each { |k,v|
        assert_equal expected[k], mk.syn_dfh_if_end(k), msg + k
    }
end

def test_syn_var_lab_for_var
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sas')
    expected = [
        [ '  RECTYPE  = "Record type"' ],
        [ '  HDFIRSTD = "Head not first [""dwelling-wide""] {note}"' ],
        [
          '  SEX      = "' + ('fubb' * 25) + '"',
          '             "' + ('fubb' *  5) + '"',
        ],
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE HDFIRSTD SEX) )
    var_list[2].label = 'fubb' * 30
    expected.each_index { |i|
        actual = mk.syn_var_lab_for_var(var_list[i])
        assert_equal expected[i], actual, msg
    }
end

def test_syn_fmt_link_for_var_list
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sas')
    expected = [
        '  RECTYPE   RECTYPE_f.',
        '  HDFIRSTD  HDFIRSTD_f.',
        '  SEX       SEX_f.',
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE HDFIRSTD SEX) )
    actual = mk.syn_fmt_link_for_var_list(var_list)
    assert_equal expected, actual, msg

    msg = 'Should return [] if there are no variables.'
    mk.sfc.clear_variables
    assert_equal [], mk.syn_fmt_link, msg
end

def test_implied_decimal_fmt
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sas')
    expected = [
        '',
        '',
        ' .1',
        ' .3',
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE SEX CANTON RESPREV2) )
    actual = var_list.map { |v| mk.implied_decimal_fmt(v) }
    assert_equal expected, actual, msg
end

def test_non_last_non_common_vars
    mk = new_maker('sas')

    msg = 'Compare against hardcoded result.'
    expected = ['CANTON', 'URBAN', 'DWTYPE', 'OWNERSHP', 'RENT']
    var_list = mk.non_last_non_common_vars
    assert_equal expected, vars_to_names(var_list), msg

    msg = 'Should return empty list if there are no variables.'
    mk.sfc.clear_variables
    var_list = mk.non_last_non_common_vars
    assert_equal [], vars_to_names(var_list), msg
end

def test_csv_import
    msg = 'Compare against hardcoded result.'
    mk = new_maker('sas', csv: true)
    expected = [
      'data IPUMS.data;',
      'infile CSV missover dsd delimiter="," firstobs=2;',
      '',
      'input',
      "  RECTYPE  $ ",
      "  DWNUM      ",
      "  HHNUM      ",
      "  HDFIRSTD   ",
      "  FBIG_ND    ",
      "  BADDW      ",
      "  CANTON     ",
      "  URBAN      ",
      "  DWTYPE     ",
      "  OWNERSHP   ",
      "  RENT     $ ",
      "  RELATE     ",
      "  SEX        ",
      "  AGE        ",
      "  RESPREV2   ",
      "  SOCSEC     ",
      "  EDLEVEL    ",
      "  LIT        ",
      "  BIGDEC     ",
      "  BIGINT     ",
      "  BIGSTR   $ ",
      ";",
      ''
    ]
    assert_equal expected, mk.syn_df, msg

    expected2 = []
    assert_equal expected2, mk.syn_fmt_link, msg
end

end
end
