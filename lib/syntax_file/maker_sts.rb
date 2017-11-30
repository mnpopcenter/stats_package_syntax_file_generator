# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

module SyntaxFile
class MakerSTS < Maker

def initialize (sfc, syntax_type)
    super

    m = @sfc.max_var_name_length
    @var_lab_format   = "  %-#{m}s  %s"
    @var_loc_format   = "  %-#{m}s  %s  %s"
    
    @vars_with_values = get_vars_with_sts_supported_values     # cache
end

def syntax
    r = [
        syn_df,
        syn_var_labs,
        syn_val_labs,
    ]
    r.flatten
end

def convert_to_comments (lines)
    return [] if lines.empty?
    [
        lines.map { |ln| '// ' + ln },
        blank,
    ].flatten
end

def syn_df
    r = [
        syn_df_start,
        syn_var_locations(@sfc.variables),
        syntax_end,
    ]
    r.flatten
end

def syn_df_start
    ['FORMAT fixed', '', (@sfc.data_structure == 'hier') ? hier_fyi : '']
end

def hier_fyi
  convert_to_comments([ '',
    'Hierarchical data structures are not directly supported by Stat/Transfer.',
    'Please see the README for the stats_package_syntax_file_generator gem for more information.', ''
  ])
end

def syn_var_locations (var_list)
    r = [
        'VARIABLES',
        var_list.map { |v| sprintf @var_loc_format, v.name, var_loc_with_fmt(v), var_val_lbl_id(v) }
    ]
    r.flatten
end

def var_val_lbl_id (var)
    return '' unless @vars_with_values.include?(var)
    '\\' + var.name
end

def syn_var_labs (var_list = [])
    var_list = @sfc.get_vars_with_var_labels if var_list.empty?
    var_list = var_list.reject { |var| !supported_var_label?(var) }
    return [] if var_list.empty?
    r = [
        'VARIABLE LABELS',
        var_list.map { |var| syn_var_lab_for_var(var) },
        syntax_end,
    ]
    r.flatten
end

def syn_var_lab_for_var (var)
    sprintf @var_lab_format, var.name, esc(q(var.label))
end

def syn_val_labs
    var_list = @vars_with_values
    return [] if var_list.empty?
    r = [
        'VALUE LABELS',
        syn_val_labs_for_var_list(var_list),
        syntax_end,
    ]
    r.flatten
end

def syn_val_labs_for_var_list (var_list)
    var_list.map { |var| syn_val_labs_for_var(var) }
end

def syn_val_labs_for_var (var)
    val_list = labelable_values(var)
    return [] if val_list.empty?
    
    m = max_value_length(var, val_list.select {|x| supported_val?(x)})  
    value_format = "    %-#{m}s %s"
    r = [
        syn_val_labs_for_var_start(var),
        val_list.reject{ |val| !supported_val?(val) }.map { |val| syn_val_lab_for_val(var, val, value_format) }
    ]
    r.flatten
end

def syn_val_labs_for_var_start (var)
    '  \\' + var.name
end

def syn_val_lab_for_val (var, val, fmt)
    return if !supported_val?(val)
    sprintf fmt, sts_val_q(var, val_as_s(var, val.value.to_s)), esc(q(val.label))
end

# value codes (aka value values) need to be quoted with single quotes if they are strings
def sts_val_q (var, v)
    var.is_string_var ? "'#{v}'" : v.to_s
end

def var_loc_with_fmt (var)
    return var.column_locations_as_s + var_fmt(var) unless var.implied_decimals > 0
    var.start_column.to_s + var_fmt(var)
end

def var_fmt (var)
    return ' (A)' if var.is_string_var
    return '' unless var.implied_decimals > 0
    ' (F' + var.width.to_s + '.' + var.implied_decimals.to_s + ')'
end

def q (s)
    '"' + s.to_s.gsub('"', '\'\'') + '"'
end

def esc (s)
    s.gsub(/\n/, " [New line.] ")
end

# Stat/Transfer does not like blank value labels
def get_vars_with_sts_supported_values()
    @sfc.get_vars_with_values.select do |var|
        sts_supported_values(var).size > 0
    end
end

def sts_supported_values(var)
    return [] if (var.nil? || var.values.nil?)
    var.values.select { |val| supported_val?(val) }
end

def supported_val?(val)
    supported_val_label?(val) && supported_val_value?(val)
end

def supported_val_label?(val)
    !(val.nil?) && !(val.label.nil?) && !(val.label.strip.empty?)
end

def supported_val_value?(val)
    !(val.nil?) && !(val.value.nil?) && !!(val.value.to_s =~ /^[A-Za-z0-9\-\_\.]+$/)
end

def supported_var_label?(var)
    !(var.nil?) && !(var.label.nil?) && !(var.label.strip.empty?)
end

end
end
