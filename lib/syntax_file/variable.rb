# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

module SyntaxFile
  class Variable

    ATTR = {
      :name              => { :req => true,  :rw => 'rw', :def =>  ''    },
      :label             => { :req => false, :rw => 'rw', :def =>  ''    },
      :start_column      => { :req => true,  :rw => 'rw', :def =>  nil   },
      :width             => { :req => true,  :rw => 'rw', :def =>  nil   },
      :is_string_var     => { :req => false, :rw => 'rw', :def =>  false },
      :is_double_var     => { :req => false, :rw => 'rw', :def =>  false },
      :is_common_var     => { :req => false, :rw => 'rw', :def =>  false },
      :record_type       => { :req => false, :rw => 'rw', :def =>  ''    },
      :implied_decimals  => { :req => false, :rw => 'rw', :def =>  0     },
      :suppress_labels   => { :req => false, :rw => 'rw', :def =>  false },
      :values            => { :req => false, :rw => 'r',  :def =>  nil   },
    }

    ATTR.each_key do |k|
      attr_reader k if ATTR[k][:rw].include? 'r'
      attr_writer k if ATTR[k][:rw].include? 'w'
    end

    def initialize(args = {})
      ATTR.each_key { |k|
        raise(ArgumentError, "Missing required parameter: '#{k}'.") if ATTR[k][:req] and not args.has_key?(k)
        v = args.has_key?(k) ? args[k] : ATTR[k][:def]
        instance_variable_set("@#{k}".to_sym, v)
      }
      @values = [] if @values.nil?
    end

    def column_locations_as_s
      @start_column.to_s + '-' + end_column.to_s
    end

    def end_column
      @start_column + @width - 1
    end

    def add_value(args)
      @values.push Value.new(args)
      @values[-1]
    end

    def clear_values
      @values = []
    end

  end
end
