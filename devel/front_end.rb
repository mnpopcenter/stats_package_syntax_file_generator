#!/usr/bin/ruby

# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator


# A front-end used to run the syntax file utility during development.
# This is not a front-end for users.
#
# The optional ALL argument controlls this choice:
#    - Run once, performing the actions implied by the YAML config file.
#    - Runs for all data structures: rectangular and hierarchical.

require File.expand_path(File.dirname(__FILE__)) + '/../lib/stats_package_syntax_file_generator.rb'

def main
    mode = ''
    mode = ARGV.pop if ARGV[-1] == "ALL"

    yaml_files = check_command_line_args
    sfc = SyntaxFile::Controller.new(:yaml_files => yaml_files)

    if mode == 'ALL'
        run_all(sfc)    
    else
        run_once(sfc)
    end
end

def check_command_line_args
    usage_msg = "Usage: #{$0} YAML_FILES [ALL]"
    abort usage_msg unless ARGV.size > 0
    ARGV.each { |f| abort usage_msg unless File.file? f }
    ARGV
end

def run_all (sfc)
    %w(hier rect).each do |t|
        sfc.data_structure   = t
        sfc.output_file_stem = '_' + t + '_%s'
        sfc.generate_syntax_files    
    end
end

def run_once (sfc)
    sfc.generate_syntax_files
end

main()
