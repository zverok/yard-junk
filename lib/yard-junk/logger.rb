# frozen_string_literal: true

require 'singleton'
require 'pp'

module YardJunk
  class Logger
    require_relative 'logger/message'

    include Singleton

    DEFAULT_IGNORE = %w[Undocumentable].freeze

    def messages
      @messages ||= []
    end

    def register(msg, severity = :warn)
      message = Message.registry
                       .map { |t| t.try_parse(msg, severity: severity, file: @current_parsed_file) }
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
      @ignore = DEFAULT_IGNORE
    end

    def format=(fmt)
      @format = fmt.to_s
    end

    def ignore=(list)
      @ignore = Array(list).map(&:to_s)
                           .each { |type| Message.valid_type?(type) or fail(ArgumentError, "Unrecognized message type to ignore: #{type}") }
    end

    private

    def output?(message)
      !@format.empty? && !@ignore.include?(message.type)
    end

    module Mixin
      def debug(msg)
        YardJunk::Logger.instance.notify(msg)
        super
      end

      def warn(msg)
        YardJunk::Logger.instance.register(msg, :warn)
      end

      def error(msg)
        YardJunk::Logger.instance.register(msg, :error)
      end

      def backtrace(exception, level_meth = :error)
        super if %i[error fatal].include?(level_meth)
      end
    end
  end
end

YardJunk::Logger.instance.clear
