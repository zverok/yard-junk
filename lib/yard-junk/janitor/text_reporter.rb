# frozen_string_literal: true

require 'rainbow'

module YardJunk
  class Janitor
    # Reporter that just outputs everything in plaintext format. Useful
    # for commandline usage. See {BaseReporter} for details about reporters.
    #
    class TextReporter < BaseReporter
      private

      def _stats(**stat)
        @io.puts "\n#{template_for(stat) % stat}"
      end

      NO_ISSUES_TEMPLATE = [
        Rainbow('%<errors>i failures, %<problems>i problems').green,
        Rainbow(', (%<duration>s to run)').gray
      ].join('').freeze

      ERROR_COUNT_TEMPLATE = [
        Rainbow('%<errors>i failures').red,
        Rainbow(',').gray,
        Rainbow(' %<problems>i problems').yellow,
        Rainbow(', (%<duration>s to run)').gray
      ].join('').freeze

      def template_for(stat)
        if stat[:errors].zero? && stat[:problems].zero?
          NO_ISSUES_TEMPLATE
        else
          ERROR_COUNT_TEMPLATE
        end
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
