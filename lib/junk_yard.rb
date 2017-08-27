# frozen_string_literal: true

require_relative 'junk_yard/logger'
require_relative 'junk_yard/command_line'

YARD::Logger.prepend JunkYard::Logger::Mixin
YARD::CLI::Command.prepend JunkYard::CommandLineOptions
