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
      #puts msg
      #p caller[1..3]
      message = Message.registry
        .map { |t| t.try_parse(msg, file: @current_parsed_file) }
        .compact.first || Message.new(message: msg, file: @current_parsed_file)
      messages << message
      puts message
    end

    def start_file(name)
      @current_parsed_file = name
    end

    module Mixin
      def debug(msg)
        # TODO: fragile regexp; cleanup it after everything is parsed.
        if msg =~ /Parsing (\w\S+)$/
          JunkYard::Logger.instance.start_file($1)
        end
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
