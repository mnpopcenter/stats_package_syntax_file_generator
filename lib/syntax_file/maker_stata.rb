# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

module SyntaxFile
class MakerSTATA < Maker

def initialize (sfc, syntax_type)
    super
    

    mx_var = @sfc.max_var_name_length
    mx_col = 2 * @sfc.max_col_loc_width + 1
    @var_loc_format     = "  %-7s %-#{mx_var}s  %-#{mx_col}s %s"
    @var_lab_format     = "label var %-#{mx_var}s %s"
    @infix_format       = "%#{mx_col + mx_var + 4}s"
    @replace_format     = "replace %-#{mx_var}s = %-#{mx_var}s / %d"
    @display_format     = "format %-#{mx_var}s %%%d.%df"
    @cmd_end            = ''
    @cmd_continue       = ' ///'
    @var_label_max_leng = 80
    @val_label_max_leng = 244
    @sort_var_stem      = '_line_num'
end

def syntax
    r = [
        comments_start,
        'set more off',
        blank,
        syn_df,
        blank,
        syn_convert_implied_decim,
        blank,
        syn_display_format,
        blank,
        syn_var_labs,
        blank,
        syn_val_labs,
        blank,
        comments_end,
    ]
    r.flatten
end

def comments_start
    convert_to_comments(super)
end

def comments_end
    convert_to_comments(super)
end

def convert_to_comments (lines)
    return [] if lines.empty?
    [
        lines.map { |ln| '* ' + ln },
        blank,
    ].flatten
end

def syn_df
    @sfc.data_structure == 'hier' ? syn_dfh : syn_dfr
end

def syn_dfr
    syn_infix(@sfc.variables)
end

def syn_dfh
    r = [
        syn_dfh_infix_blocks,
        syn_dfh_combine,
    ]
    r.flatten
end

def syn_infix (var_list)
    r = [
        syn_infix_start,
        syn_infix_var_locs(var_list),
        syn_infix_end,
    ]
    r.flatten
end

def syn_infix_start
    [
        'clear',
        'quietly infix' + sprintf(@infix_format, @cmd_continue),
    ]
end

def syn_infix_var_locs (var_list)
    var_list.map { |v|
        sprintf @var_loc_format,
                var_fmt(v),
                v.name.downcase,
                v.column_locations_as_s,
                @cmd_continue
    }
end

def syn_infix_end
    '  using ' + q(@sfc.data_file_name)
end

def syn_dfh_infix_blocks
    r = []
    @sfc.record_types.each { |rt|
        var_list = @sfc.get_vars_by_record_type(rt)
        r.push(
            syn_infix(var_list),
            syn_dfh_infix_block_end(rt)
        ) if var_list.size > 0
    }
    r.flatten
end

def syn_dfh_infix_block_end (rt)
    r = [
        syn_dfh_infix_gen,
        'drop if ' + rt_ne_statement(rt),
        'sort ' + sort_vars.join(' '),
        'save ' + temp_file_name(rt),
        blank,
    ]
    r.flatten
end

def syn_dfh_infix_gen
    return ["gen  #{@sort_var_stem} = _n"] unless @sfc.rectangularize
    sv = sort_vars()
    r = [
        sv.map { |v| "gen #{v} = _n" },
        sv.zip(@sfc.record_types).map { |z|
            'replace '              +
            z[0]                    +
            ' = '                   +
            z[0]                    +
            '[_n - 1] if _n > 1 & ' +
            rt_ne_statement(z[1])
        }
    ]
    r.flatten!
end

def syn_dfh_combine
    r = [
        'clear',
        syn_dfh_combine_append,
        syn_dfh_combine_save,
        syn_dfh_combine_erase,
    ]
    r.flatten
end

def syn_dfh_combine_append
    r = []
    tf = temp_file_names()
    if @sfc.rectangularize
        sv = sort_vars.reverse
        tf = tf.reverse
        sv.shift
        r.push 'use ' + tf.shift
        sv.zip(tf).each { |z|
            r.push 'merge m:1 ' + z[0] + ' using ' + z[1] + ', keep(master match)'
            r.push 'drop _merge'
        }
    else
        r.push 'use ' + tf.shift
        tf.each { |t| r.push 'append using ' + t }
    end
    r
end

def syn_dfh_combine_save
    [
        'sort ' + sort_vars.join(' '),
        'drop ' + sort_vars.join(' '),
    ]
end

def syn_dfh_combine_erase
    temp_file_names.map { |t| 'erase ' + t }
end

def syn_convert_implied_decim
    var_list = @sfc.variables.find_all { |var| var.implied_decimals > 0 }
    return [] if var_list.empty?
    var_list.map { |var|
        v = var.name.downcase
        sprintf @replace_format, v, v, 10 ** var.implied_decimals
    }
end

def syn_display_format
    var_list = @sfc.variables.find_all { |var|
        vf = var_fmt(var)
        vf == 'double' or vf == 'float'
    }
    return [] if var_list.empty?
    var_list.map { |var|
        v = var.name.downcase
        sprintf @display_format, v, var.width, var.implied_decimals
    }
end

def syn_var_labs (var_list = [])
    var_list = @sfc.get_vars_with_var_labels if var_list.empty?
    return [] if var_list.empty?
    var_list.map { |var|
        sprintf @var_lab_format,
                var.name.downcase,
                q( label_trunc(var.label, @var_label_max_leng) )
    }
end

def syn_val_labs
    var_list = @sfc.get_vars_with_values.find_all { |var| not var.is_string_var }
    return [] if var_list.empty?
    r = var_list.map { |var|
        [
            syn_val_labs_for_var(var),
            "label values " + var.name.downcase + ' ' + label_handle(var),
            blank,
        ]
    }
    r.flatten
end

def syn_val_labs_for_var (var)
    val_list = labelable_values(var)
    return [] if val_list.empty?
    m = max_value_length(var, val_list)
    value_format = "label define %s %-#{m}s %s%s"
    add_cmd = ''
    r = []
    val_list.each { |val|
        label_truncated = label_trunc(val.label, @val_label_max_leng)
        # stata doesn't like blank value labels
        label_truncated = val.value if label_truncated.nil? || (label_truncated.strip.length == 0)
        r.push sprintf(
            value_format,
            label_handle(var),
            val.value,
            q( label_truncated ),
            add_cmd
        )
        add_cmd = ', add'
    }
    r.flatten
end

def q (s)
    '`"' + s.to_s + '"\''
end

def var_fmt (var)

    return 'str'   if var.is_string_var
    return  'double' if var.is_double_var
    return 'float' if var.implied_decimals > 0
    return 'byte'  if var.width <= 2
    return 'int'   if var.width <= 4
    return 'long'  if var.width <= 7
    
    return 'double'
end

def temp_file_names
    tf = []
    @sfc.record_types.each { |rt|
        var_list = @sfc.get_vars_by_record_type(rt)
        tf.push temp_file_name(rt) if var_list.size > 0
    }
    tf
end

def temp_file_name (rt)
    '__temp_ipums_hier_' + rt + '.dta'
end

def label_handle (var)
    var.name.downcase + '_lbl'
end

def sort_vars
    return [ @sort_var_stem ] unless @sfc.rectangularize
    return @sfc.record_types.map { |rt| @sort_var_stem + rt }
end

def rt_ne_statement (rt)
    rt_var = @sfc.record_type_var
    rt_var.name.downcase + ' != ' + val_q(rt_var, val_as_s(rt_var, rt))
end

end
end
