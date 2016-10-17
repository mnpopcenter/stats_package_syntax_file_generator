require 'bundler/gem_tasks'

task :default => :test

task :test do
  script = File.expand_path('devel/run_all_checks.sh', File.dirname(__FILE__))
  sh(script)
end