# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require 'test/unit'

%w(
    setup
    tc_controller
    tc_variable
    tc_value
    tc_maker
    tc_maker_sas
    tc_maker_spss
    tc_maker_stata
    tc_maker_sts
	tc_maker_rddi
).each do |f|
    require File.expand_path(File.join(File.dirname(__FILE__), f))
end
