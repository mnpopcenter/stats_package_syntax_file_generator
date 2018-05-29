# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require File.expand_path(File.join(File.dirname(__FILE__), 'setup.rb'))

module StatsPackageSyntaxFileGeneratorTest
class MakerRDDI < Test::Unit::TestCase

include StatsPackageSyntaxFileGeneratorTestSetup

def test_create_maker_rddi
    msg = 'Try to create an object.'
    mk = new_maker('rddi')
    assert_instance_of SyntaxFile::MakerRDDI, mk, msg
end

def test_check_pkg
    msg = 'Compare against hardcoded result.'
    mk = new_maker('rddi')
    expected = [
        'if (!require("ipumsr")) stop("Reading IPUMS data into R requires the ipumsr package. It can be installed using the following command: install.packages(\'ipumsr\')")',
		''
    ]
    actual = mk.check_pkg
    assert_equal expected, actual, msg
end



end
end
