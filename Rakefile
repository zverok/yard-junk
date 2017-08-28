require 'bundler/setup'
require 'rubygems/tasks'
Gem::Tasks.new

require_relative 'lib/yard-junk/rake'
YardJunk::Rake.define_task

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: %w[spec rubocop yard:junk]
