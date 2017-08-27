# frozen_string_literal: true

require 'singleton'
require 'pp'

module JunkYard
  class Logger
    require_relative 'logger/message'

    include Singleton

    def messages
      @messages ||= []
    end

    def register(msg)
      message = Message.registry
                       .map { |t| t.try_parse(msg, file: @current_parsed_file) }
                       .compact.first || Message.new(message: msg, file: @current_parsed_file)
      messages << message
      puts message.to_s(@format) if output?(message)
    end

    def notify(msg)
      case msg
      when /Parsing (\w\S+)$/
        # TODO: fragile regexp; cleanup it after everything is parsed.
        @current_parsed_file = Regexp.last_match(1)
      when /^Generating/ # end of parsing of any file
        @current_parsed_file = nil
      end
    end

    def clear
      messages.clear
      @format = Message::DEFAULT_FORMAT
    end

    def format=(fmt)
      @format = fmt.to_s
    end

    private

    def output?(message)
      !@format.empty? && !message.is_a?(Undocumentable)
    end

    module Mixin
      def debug(msg)
        JunkYard::Logger.instance.notify(msg)
        super
      end

      def warn(msg)
        JunkYard::Logger.instance.register(msg)
      end

      def error(msg)
        # FIXME: propagate severity?.. Though, it seems pretty arbitrary.
        JunkYard::Logger.instance.register(msg)
      end

      def backtrace(exception, level_meth = :error)
        super if %i[error fatal].include?(level_meth)
      end
    end
  end
end

JunkYard::Logger.instance.clear
