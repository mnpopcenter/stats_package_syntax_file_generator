# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

module SyntaxFile
class Maker

attr_reader   :sfc, :syntax_type
attr_accessor :cmd_end

def initialize (sfc, syntax_type)
    @sfc         = sfc
    @syntax_type = syntax_type
    @cmd_end     = ''
end


# Syntax terminator.

def syntax_end
    [ @cmd_end, blank ]
end

def blank
    ''
end


# Quoting methods.

def q (s)
    '"' + s.to_s.gsub('"', '""') + '"'
end

def val_q (var, v)
    var.is_string_var ? q(v) : v.to_s
end

def val_as_s (var, val_orig)
    # Write a value in a syntax file varies by variable type:
    #   - Numeric variable: simply return the value as a string.
    #   - String  variable: zero-pad the value if it looks like an integer.
    v = val_orig.to_s
    return v unless var.is_string_var
    return v unless v =~ /^\-?\d+$/
    sprintf('%0' + var.width.to_s + 'i', v.to_i)
end


# Methods to deal with long labels.

def label_trunc (label, limit)
    label.to_s[0,limit]
end

def label_segments (label, max_length)
    # Takes a string and a max length.
    # Returns the array of strings that results from chopping the
    # original string into segments no longer than max length.
    # This is needed because some stats packages have max line lengths.
    label = label.to_s
    return [label] if label.length <= max_length
    label = String.new(label)
    r = []
    r.push( label.slice!(0,max_length) ) while label.length > 0
    r
end

def weave_label_segments (fmt, a, b, op_a, op_c)
    # The function takes a sprintf format, two lists (a, b), and
    # two strings (the assignment and concatenation operators used
    # by the stats package). The purpose of the function is to handle
    # long values and labels for stats packages that have a max syntax
    # line length. See unit tests for an illustration.
    r = []
    r.push(sprintf(fmt, a.shift, op_c, ''     )) while a.size > 1
    r.push(sprintf(fmt, a.shift, op_a, b.shift))
    r.push(sprintf(fmt, '',      op_c, b.shift)) while b.size > 0
    r
end


# Helper methods for values and their labels.

def labelable_values (var)
    # For non-string variables, only values that look
    # like integers can be labeled.
    return var.values if var.is_string_var
    var.values.find_all { |val| val.value.to_s =~ /^\-?\d+$/ }
end

def max_value_length (var, val_list)
    return 0 if val_list.empty?
    val_list.map { |val| val_as_s(var, val.value).length }.max
end


# Methods for comments at the start or end of the syntax file.

def comments_start
    # Comments not needed unless syntax file is for the web app.
    return [] unless @sfc.caller == 'web_app'

    return [
        'NOTE: You need to set the Stata working directory to the path',
        'where the data file is located.',
    ] if @syntax_type == 'stata'

    cmd = (@syntax_type == 'sas') ? 'libname' : 'cd'
    result = [
        "NOTE: You need to edit the `#{cmd}` command to specify the path to the directory",
        'where the data file is located. For example: "C:\ipums_directory".'
    ]
    if @syntax_type == 'sas'
      result << "Edit the `filename` command similarly to include the full path (the directory and the data file name)."
    end
    result
end

def comments_end
    []
end

end
end
