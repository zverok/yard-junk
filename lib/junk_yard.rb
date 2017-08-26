# frozen_string_literal: true

require_relative 'junk_yard/logger'

# class YARD::CLI::Yardoc
#   alias parse_options_no_junk parse_options
#
#   def parse_options(opts, *arg)
#     opts.separator ""
#     opts.separator "JunkYard plugin options"
#
#     opts.on('--junk-logger-format [FORMAT]', 'JunkYard::Logger format string') do
#       p "HERE we go!"
#     end
#
#     opts.separator ""
#     opts.separator "Generic options"
#
#     parse_options_no_junk(opts, *arg)
#   end
# end

YARD::Logger.prepend JunkYard::Logger::Mixin
