# This file is part of the Minnesota Population Center's stats_package_syntax_file_generator project.
# For copyright and licensing information, see the NOTICE and LICENSE files
# in this project's top-level directory, and also on-line at:
#   https://github.com/mnpopcenter/stats_package_syntax_file_generator

require File.expand_path(File.join(File.dirname(__FILE__), 'setup.rb'))

module StatsPackageSyntaxFileGeneratorTest
class Value < Test::Unit::TestCase

include StatsPackageSyntaxFileGeneratorTestSetup

def test_create_value
    msg = 'Try to create an object.'
    v = SyntaxFile::Value.new(:value => 1234)
    assert_instance_of SyntaxFile::Value, v, msg

    msg = 'Try to create an object with required parameters missing.'
    assert_raise(ArgumentError, msg) { SyntaxFile::Value.new }
end

end
end
