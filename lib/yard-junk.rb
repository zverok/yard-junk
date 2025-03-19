# frozen_string_literal: true

# External gems
# When YardJunk is loaded via `.yardopts`, via Yarn,
#   loading Yarn again here would be circular.
require 'yard' unless defined?(YARD)

# This gem
require_relative 'yard-junk/version'
require_relative 'yard-junk/logger'
require_relative 'yard-junk/command_line'
require_relative 'yard-junk/janitor'

YARD::Logger.prepend YardJunk::Logger::Mixin
YARD::CLI::Command.prepend YardJunk::CommandLineOptions
