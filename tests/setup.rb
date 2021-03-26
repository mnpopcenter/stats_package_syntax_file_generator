# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require 'test/unit'

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/stats_package_syntax_file_generator.rb'))

module StatsPackageSyntaxFileGeneratorTestSetup

# YAML metadata used to initialize new SyntaxFile::Controller objects.

PATH = File.expand_path(File.dirname(__FILE__))
YAML_FILES = [
    'input_all_vars.yaml',
    'input_controller.yaml',
].map { |f| File.join(PATH, f) }

# Methods to create new objects with known values.

def new_controller
    SyntaxFile::Controller.new(:yaml_files => YAML_FILES)
end

def new_variable
    SyntaxFile::Variable.new params_variable()
end

def new_value
    SyntaxFile::Value.new params_value()
end

def new_maker(syntax_type = '')
    maker_class = 'SyntaxFile::Maker' + syntax_type.upcase
    eval(maker_class).new(new_controller, syntax_type)
end

# Parameters used when creating objects with known values.

def params_variable
    {
        # Parameters needed to create the Variable.
        :name              => 'FOO',
        :label             => 'Test variable',
        :start_column      => 100,
        :width             => 4,
        :is_string_var     => false,
        :is_common_var     => false,
        :record_type       => 'P',
        :implied_decimals  => 0,
        :suppress_labels   => false,
        :values            => [],
        # Expected values used by tests.
        :end_column            => 103,
        :column_locations_as_s => '100-103',
    }
end

def params_value(val = 99, lab = 'bar')
    {
        :value => val,
        :label => 'Test value: ' + lab,
    }
end

# Methods to add a bunch of Values to a Variable.

def params_values
    [0,1,2,9,9999].map { |v| params_value(v, 'bar' + v.to_s) }
end

def add_new_values_to_var(var)
    params_values.each { |pv| var.add_value(pv) }
end

# Helper functions.

def params_variable_lookup(k)
    params_variable[k]
end

def vars_to_names(var_list)
    return nil if var_list.nil?
    var_list.map { |v| v.name }
end

def names_to_vars(sfc, var_list)
    var_list.map { |nm| sfc.get_var_by_name(nm) }
end

def dir_contents(dir_name)
    Dir.entries(dir_name).sort.reject { |f| f[0,1] == '.' }
end

def remove_file_from_dir(d, files)
    files.each do |f|
        full_path = File.join(d, f)
        File.delete(full_path) if File.file?(full_path)
    end
end

end
