# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require 'yaml'

%w(
    controller
    variable
    value
    maker
    maker_sas
    maker_spss
    maker_stata
    maker_sts
).each do |f|
    require File.expand_path(File.join(File.dirname(__FILE__), 'syntax_file', f))
end
