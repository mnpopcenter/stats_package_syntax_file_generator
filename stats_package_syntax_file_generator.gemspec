require 'rubygems'

require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'syntax_file', 'controller'))

spec = Gem::Specification.new do |s| 
  s.name              = "stats_package_syntax_file_generator"
  s.version           = SyntaxFile::Controller::VERSION
  s.licenses          = 'MPL-2.0'
  s.author            = "Monty Hindman, Marcus Peterson, Colin Davis, Dan Elbert, Jayandra Pokharel"
  s.email             = "mpcit@umn.edu"
  s.homepage          = 'https://github.com/mnpopcenter/stats_package_syntax_file_generator'
  s.rubyforge_project = '[none]'
  s.summary           = "Produces statistical package syntax files for fixed-column data."
  s.description       = "A tool for producing statistical package syntax files for fixed-column data files"
  s.files             = Dir.glob("{lib,tests}/**/*")
  s.require_path      = "lib"
  s.test_file         = 'tests/ts_all.rb'
  s.has_rdoc          = true
  s.extra_rdoc_files  = ['README']

  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'test-unit'
end
