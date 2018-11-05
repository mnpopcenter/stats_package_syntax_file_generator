# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

module SyntaxFile
class Controller

VERSION = "1.1.2"

ATTR = {
    :project                    => { :req => false, :rw => 'rw', :def => '',          :yaml => true  },
    :caller                     => { :req => false, :rw => 'rw', :def => '',          :yaml => true  },
    :data_dir_name              => { :req => false, :rw => 'rw', :def => '.',         :yaml => true  },
    :data_file_name             => { :req => false, :rw => 'rw', :def => 'DATA_FILE', :yaml => true  },
    :output_formats             => { :req => false, :rw => 'rw', :def => nil,         :yaml => true  },
    :output_dir_name            => { :req => false, :rw => 'rw', :def => '.',         :yaml => true  },
    :output_file_stem           => { :req => false, :rw => 'rw', :def => '%s',        :yaml => true  },
    :output_file_ext            => { :req => false, :rw => 'rw', :def => nil,         :yaml => true  },
    :output_overwrite           => { :req => false, :rw => 'rw', :def => false,       :yaml => true  },
    :data_structure             => { :req => false, :rw => 'rw', :def => 'rect',      :yaml => true  },
    :record_types               => { :req => false, :rw => 'rw', :def => nil,         :yaml => true  },
    :record_type_var_name       => { :req => false, :rw => 'rw', :def => '',          :yaml => true  },
    :rectangularize             => { :req => false, :rw => 'rw', :def => false,       :yaml => true  },
    :all_vars_as_string         => { :req => false, :rw => 'rw', :def => false,       :yaml => true  },
    :select_vars_by_record_type => { :req => false, :rw => 'rw', :def => false,       :yaml => true  },
    :variables                  => { :req => false, :rw => 'r',  :def => nil,         :yaml => false },
    :yaml_files                 => { :req => false, :rw => 'r',  :def => nil,         :yaml => false },
    :output_encoding            => { :req => false, :rw => 'r',  :def => "iso-8859-1",:yaml => true },
}

ATTR.each_key do |k|
    attr_reader k if ATTR[k][:rw].include? 'r'
    attr_writer k if ATTR[k][:rw].include? 'w'
end

def initialize (args = {})
    ATTR.each_key { |k|
        raise(ArgumentError, "Missing required parameter: '#{k}'.") if
            ATTR[k][:req] and not args.has_key?(k)
        v = args.has_key?(k) ? args[k] : ATTR[k][:def]
        instance_variable_set("@#{k}".to_sym, v)
    }

    @output_file_ext = {
        'sas'   => '.sas',
        'spss'  => '.sps',
        'stata' => '.do',
        'sts'   => '.sts',
        'rddi'  => '.R'
    } if @output_file_ext.nil?
    @output_formats  = [] if @output_formats.nil?
    @record_types    = [] if @record_types.nil?
    @variables       = [] if @variables.nil?
    @yaml_files      = [] if @yaml_files.nil?
    read_metadata_from_yaml
end


# Methods to import metadata from YAML files into the Controller object.

def yaml_files= (file_names)
    # Caller can supply a file name or an array of file names.
    @yaml_files = file_names.to_a
    read_metadata_from_yaml
end

def read_metadata_from_yaml
    return if @yaml_files.empty?
    md = {}
    @yaml_files.each { |f| md.merge! YAML.load_file(f) }
    md = symbolize_keys(md)
    load_yaml_md(md)
end

def load_yaml_md (md)
    # Uses metadata from yaml to set metadata-related instance variables.
    ATTR.each_key do |k|
        next unless md.has_key?(k) and ATTR[k][:yaml]
        instance_variable_set("@#{k}".to_sym, md[k])
    end
    return unless md.has_key?(:variables)
    @variables = []
    return unless md[:variables].size > 0
    md[:variables].each do |md_var|
        vals = md_var.delete(:values)
        var = add_variable(md_var)
        vals.each { |v| var.add_value(v) } unless vals.nil?
    end
end

def symbolize_keys (h)
    # Recursively converts hash keys from strings to symbols.
    if h.instance_of? Hash
        h.inject({}) { |return_hash,(k,v)| return_hash[k.to_sym] = symbolize_keys(v); return_hash }
    elsif h.instance_of? Array
        h.map { |v| symbolize_keys(v) }
    else
        h
    end
end

# Methods to add or get variables.

def add_variable (args)
    @variables.push Variable.new(args)
    @variables[-1]
end

def clear_variables
    @variables = []
end

def get_var_by_name (n)
    @variables.find { |v| v.name == n }
end

def get_vars_by_record_type (rt)
    @variables.find_all { |v| v.record_type == rt or v.is_common_var }
end

def get_vars_with_var_labels
    @variables.find_all { |v| v.label.length > 0 }
end

def get_vars_with_values
    @variables.find_all { |var|
        var.values.size > 0 and
        not var.suppress_labels
    }
end

def get_big_nums
    @variables.find_all { |var|
        var.width > 8 and
        not var.is_string_var
    }
end


def record_type_var
    get_var_by_name(@record_type_var_name)
end


# Methods for adding values to variables.

def add_value (args)
    @variables[-1].values.push Value.new(args)
    @variables[-1].values[-1]
end

def new_values (*vals)
    vals.flatten!
    vals.map { |v| Value.new(v) }
end


# Methods for record types.

def is_last_record_type (rt)
    return true if @record_types.size > 0 and @record_types[-1] == rt
    return false
end

def rec_types_except_last
    r = Array.new(@record_types)
    r.pop
    r
end


# Helper methods.

def max_var_name_length
    return 0 if @variables.empty?
    @variables.map { |v| v.name.length }.max
end

def max_col_loc_width
    return 0 if @variables.empty?
    @variables.map { |v| v.end_column.to_s.length }.max
end

def data_file_name_stem
    File.basename(@data_file_name, '.*')
end

def rec_type_lookup_hash
    Hash[ * @record_types.map { |rt| [rt, 0] }.flatten ]
end

def last_column_used
    return 0 if @variables.empty?
    @variables.map { |v| v.end_column }.max
end

# Output methods.

def to_s
    YAML.dump(self)
end

def generate_syntax_files
    bad_metadata('no output formats')if @output_formats.empty?
    @output_formats.each { |t| generate_syntax_file(t) }
end

def generate_syntax_file (syntax_type)
    msg = "output directory does not exist => #{@output_dir_name}"
    bad_metadata(msg) unless File.directory?(@output_dir_name)
    file_name = File.join(
        @output_dir_name,
        sprintf(@output_file_stem, data_file_name_stem) + @output_file_ext[syntax_type]
    )
    if File.file?(file_name) and not @output_overwrite
        $stderr.puts "Skipping file that aready exists => #{file_name}."
    else
        if RUBY_VERSION.start_with? "1.8"
          File.open(file_name, 'w') { |f| f.puts syntax(syntax_type) }
        else
          File.open(file_name, "w:#{self.output_encoding}") { |f|

          lines =  syntax(syntax_type)
          lines.each do |line|
              begin
                  f.puts line.rstrip.encode(self.output_encoding, line.encoding.to_s,{:invalid=>:replace, :undef=>:replace,:replace => '?'})
              rescue Exception=>msg
                  puts "Failed encoding on line #{line} #{msg}"
              end
          end
          }
        end

    end
end

def syntax (syntax_type)
    validate_metadata(:minimal => true)
    modify_metadata
    validate_metadata

    maker_class = 'Maker' + syntax_type.upcase
    syntax_maker = eval(maker_class).new(self, syntax_type)
    syntax_maker.syntax
end


# Before generating syntax, we need to handle some controller-level
# options that require global modification of the metadata.

def modify_metadata
    # Force all variables to be strings.
    if @all_vars_as_string
        @variables.each do |var|
            var.is_string_var    = true
            var.is_double_var = false
            var.implied_decimals = 0
        end
    end

    # If the user wants to rectangularize hierarchical data, the
    # select_vars_by_record_type option is required.
    @select_vars_by_record_type = true if @rectangularize

    # Remove any variables not belonging to the declared record types.
    if @select_vars_by_record_type
        rt_lookup = rec_type_lookup_hash()
        @variables = @variables.find_all { |var| var.is_common_var or rt_lookup[var.record_type] }
    end
end


# Before generating syntax, run a sanity check on the metadata.

def validate_metadata (check = {})
    bad_metadata('no variables') if @variables.empty?

    if @rectangularize
        msg = 'the rectangularize option requires data_structure=hier'
        bad_metadata(msg) unless @data_structure == 'hier'
    end

    if @data_structure == 'hier' or @select_vars_by_record_type
        bad_metadata('no record types') if @record_types.empty?

        msg = 'record types must be unique'
        bad_metadata(msg) unless rec_type_lookup_hash.keys.size == @record_types.size

        msg = 'all variables must have a record type'
        bad_metadata(msg) unless @variables.find { |var| var.record_type.length == 0 }.nil?

        msg = 'with no common variables, every record type needs at least one variable ('
        if @variables.find { |var| var.is_common_var }.nil?
            @record_types.each do |rt|
                next if get_vars_by_record_type(rt).size > 0
                bad_metadata(msg + rt + ')')
            end
        end
    end

    if @data_structure == 'hier'
        bad_metadata('no record type variable') if record_type_var.nil?
    end

    return if check[:minimal]

    @variables.each do |v|
        v.start_column     = v.start_column.to_i
        v.width            = v.width.to_i
        v.implied_decimals = v.implied_decimals.to_i
        bad_metadata("#{v.name}, start_column"    ) unless v.start_column     >  0
        bad_metadata("#{v.name}, width"           ) unless v.width            >  0
        bad_metadata("#{v.name}, implied_decimals") unless v.implied_decimals >= 0
    end
end

def bad_metadata (msg)
    msg = 'Invalid metadata: ' + msg
    abort(msg) if @caller == 'vb' or @caller == 'dcp'
    raise(RuntimeError, msg)
end

end
end
