# frozen_string_literal: true

require_relative 'yard-junk/version'
require_relative 'yard-junk/logger'
require_relative 'yard-junk/command_line'
require_relative 'yard-junk/janitor'

YARD::Logger.prepend YardJunk::Logger::Mixin
YARD::CLI::Command.prepend YardJunk::CommandLineOptions
