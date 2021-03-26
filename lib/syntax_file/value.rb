# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

module SyntaxFile
  class Value

    ATTR = {
      :value => { :req => true, :rw => 'rw', :def => nil },
      :label => { :req => false, :rw => 'rw', :def => '' },
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
    end

  end
end
