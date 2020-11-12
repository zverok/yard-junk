# frozen_string_literal: true

require 'tty/color'
require 'rainbow'

module YardJunk
  class Janitor
    # Reporter that just outputs everything in plaintext format. Useful
    # for commandline usage. See {BaseReporter} for details about reporters.
    #
    class TextReporter < BaseReporter
      private

      def _stats(**stat)
        @io.puts "\n#{colorized_stats(**stat)}"
      end

      def colorized_stats(errors:, problems:, duration:)
        colorize(
          format('%i failures, %i problems', errors, problems), status_color(errors, problems)
        ) + format(' (%s to run)', duration)
      end

      def colorize(text, color)
        return text unless TTY::Color.supports?

        Rainbow(text).color(color)
      end

      def status_color(errors, problems)
        case
        when errors.positive? then :red
        when problems.positive? then :yellow
        else :green
        end
      end

      def header(title, explanation)
        @io.puts
        @io.puts title
        @io.puts '-' * title.length
        @io.puts "#{explanation}\n\n"
      end

      def row(msg)
        @io.puts msg.to_s # default Message#to_s is good enough
      end
    end
  end
end
