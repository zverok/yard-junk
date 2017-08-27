# frozen_string_literal: true

module JunkYard
  class Janitor
    # Reporter that just outputs everything in plaintext format. Useful
    # for commandline usage. See {BaseReporter} for details about reporters.
    #
    class TextReporter < BaseReporter
      private

      def _stats(**stat)
        line =
          format(
            '%<errors>i failures, %<problems>i problems (%<duration>s to run)',
            stat
          )
        @io.puts "\n#{line}"
      end

      def header(title, explanation)
        @io.puts
        @io.puts title
        @io.puts '-' * title.length
        @io.puts explanation + "\n\n"
      end

      def row(msg)
        @io.puts msg.to_s # default Message#to_s is good enough
      end
    end
  end
end
