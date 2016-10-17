# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require File.expand_path(File.join(File.dirname(__FILE__), 'setup.rb'))

module StatsPackageSyntaxFileGeneratorTest
class MakerSTATA < Test::Unit::TestCase

include StatsPackageSyntaxFileGeneratorTestSetup

def test_create_maker_stata
    msg = 'Try to create an object.'
    mk = new_maker('stata')
    assert_instance_of SyntaxFile::MakerSTATA, mk, msg
end

def test_syn_infix_start
    msg = 'Compare against hardcoded result.'
    mk = new_maker('stata')
    expected = [
        'clear',
        'quietly infix                ///',
    ]
    actual = mk.syn_infix_start
    assert_equal expected, actual, msg
end

def test_syn_infix_var_locs
    msg = 'Compare against hardcoded result.'
    mk = new_maker('stata')
    expected = [
        '  str     rectype   1-1      ///',
        '  long    dwnum     2-7      ///',
        '  byte    hhnum     8-8      ///',
        '  int     fbig_nd   45-48    ///',
        '  double  canton    67-69    ///',
        '  byte    lit       101-101  ///',
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE DWNUM HHNUM FBIG_ND CANTON LIT) )
    actual = mk.syn_infix_var_locs(var_list)
    assert_equal expected, actual, msg
end

def test_syn_dfh_infix_gen
    mk = new_maker('stata')

    msg = 'Compare against hardcoded result: rectangularize=false.'
    expected = [
        'gen  _line_num = _n',
    ]
    mk.sfc.rectangularize = false
    actual = mk.syn_dfh_infix_gen
    assert_equal expected, actual, msg

    msg = 'Compare against hardcoded result: rectangularize=true.'
    expected = [
        'gen _line_numH = _n',
        'gen _line_numP = _n',
        'replace _line_numH = _line_numH[_n - 1] if _n > 1 & rectype != `"H"\'',
        'replace _line_numP = _line_numP[_n - 1] if _n > 1 & rectype != `"P"\'',
    ]
    mk.sfc.rectangularize = true
    actual = mk.syn_dfh_infix_gen
    assert_equal expected, actual, msg
end

def test_syn_dfh_combine_append
    mk = new_maker('stata')

    msg = 'Compare against hardcoded result: rectangularize=false.'
    expected = [
        'use __temp_ipums_hier_H.dta',
        'append using __temp_ipums_hier_P.dta',
    ]
    mk.sfc.rectangularize = false
    actual = mk.syn_dfh_combine_append
    assert_equal expected, actual, msg

    msg = 'Compare against hardcoded result: rectangularize=true.'
    expected = [
        'use __temp_ipums_hier_P.dta',
        'merge m:1 _line_numH using __temp_ipums_hier_H.dta, keep(master match)',
        'drop _merge',
    ]
    mk.sfc.rectangularize = true
    actual = mk.syn_dfh_combine_append
    assert_equal expected, actual, msg
end

def test_syn_dfh_combine_save
    mk = new_maker('stata')

    msg = 'Compare against hardcoded result: rectangularize=false.'
    expected = [
        'sort _line_num',
        'drop _line_num',
        # 'save xx9999a.dta',
    ]
    mk.sfc.rectangularize = false
    actual = mk.syn_dfh_combine_save
    assert_equal expected, actual, msg

    msg = 'Compare against hardcoded result: rectangularize=true.'
    expected = [
        'sort _line_numH _line_numP',
        'drop _line_numH _line_numP',
        # 'save xx9999a.dta',
    ]
    mk.sfc.rectangularize = true
    actual = mk.syn_dfh_combine_save
    assert_equal expected, actual, msg
end

def test_syn_dfh_combine_erase
    mk = new_maker('stata')

    msg = 'Compare against hardcoded result.'
    expected = [
        'erase __temp_ipums_hier_H.dta',
        'erase __temp_ipums_hier_P.dta',
    ]
    mk.sfc.rectangularize = false
    actual = mk.syn_dfh_combine_erase
    assert_equal expected, actual, msg
end

def test_syn_convert_implied_decim
    msg = 'Compare against hardcoded result.'
    mk = new_maker('stata')
    expected = [
        'replace canton   = canton   / 10',
        'replace resprev2 = resprev2 / 1000',
        "replace bigdec   = bigdec   / 100000"
    ]
    actual = mk.syn_convert_implied_decim
    assert_equal expected, actual, msg
end

def test_syn_display_format
    msg = 'Compare against hardcoded result.'
    mk = new_maker('stata')
    expected = [
        "format canton   %3.1f",
        "format resprev2 %4.3f",
        "format bigdec   %10.5f",
        "format bigint   %19.0f"
    ]
    actual = mk.syn_display_format
    assert_equal expected, actual, msg
end

def test_syn_var_labs
    msg = 'Compare against hardcoded result.'
    mk = new_maker('stata')
    expected = [
        'label var rectype  `"Record type"\'',
        'label var hdfirstd `"Head not first ["dwelling-wide"] {note}"\'',
        'label var canton   `"Canton "geo area""\'',
        'label var age      `"Age"\'',
    ]
    var_list = names_to_vars( mk.sfc, %w(RECTYPE HDFIRSTD CANTON AGE) )
    actual = mk.syn_var_labs(var_list)
    assert_equal expected, actual, msg
end

def test_syn_val_labs_for_var
    msg = 'Compare against hardcoded result.'
    mk = new_maker('stata')
    expected = [
        [
            'label define urban_lbl 1 `"Urban"\'',
            'label define urban_lbl 2 `"Rural"\', add',
        ],
        [
            'label define sex_lbl 1 `"Male"\'',
            'label define sex_lbl 2 `"Female"\', add',
        ],
    ]
    var_list = names_to_vars( mk.sfc, %w(URBAN SEX) )
    var_list.each_index { |i|
        actual = mk.syn_val_labs_for_var(var_list[i])
        assert_equal expected[i], actual, msg
    }
end

def test_temp_file_names
    msg = 'Compare against hardcoded result.'
    mk = new_maker('stata')
    expected = [
        '__temp_ipums_hier_H.dta',
        '__temp_ipums_hier_P.dta',
    ]
    actual = mk.temp_file_names
    assert_equal expected, actual, msg

    msg = 'Should return [] if there are no record types.'
    mk.sfc.record_types = []
    actual = mk.temp_file_names
    assert_equal [], actual, msg
end

def test_sort_vars
    msg = 'Compare against hardcoded result.'
    mk = new_maker('stata')
    mk.sfc.rectangularize = true
    expected = ['_line_numH', '_line_numP']
    assert_equal expected, mk.sort_vars, msg

    mk.sfc.rectangularize = false
    expected = ['_line_num']
    assert_equal expected, mk.sort_vars, msg
end

def test_rt_ne_statement
    msg = 'Compare against hardcoded result.'
    mk = new_maker('stata')
    expected = 'rectype != `"H"\''
    assert_equal expected, mk.rt_ne_statement('H'), msg
end

end
end
