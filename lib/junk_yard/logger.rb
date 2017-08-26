require 'singleton'
require 'pp'

module JunkYard
  class Logger
    include Singleton

    def messages
      @messages ||= []
    end

    TYPES = {
      /^Unknown tag/ => 'UnknownTag',
      /has unknown parameter/ => 'UnknownParam',
      /Cannot resolve link/ => 'InvalidLink'
    }

    module Mixin
      def debug(msg)
        # TODO: fragile regexp; cleanup it after everything is parsed.
        if msg =~ /Parsing (\w\S+)$/
          @current_parsed_file = $1
        end
        super
      end

      def warn(msg)
        #pp caller.grep_v(%r{gems/rspec}) -- TODO?
        _, type = TYPES.detect { |re, _| msg =~ re } || [nil, 'OtherError']

        JunkYard::Logger.instance.messages <<
          if msg =~ /^(.+?)\s+in file `([^`']+)[`'] near line (\d+)$/
            Message.new(level: :warn, type: type, message: $1, file: $2, line: $3.to_i)
          elsif msg =~ /\AIn file `([^']+)':(\d+):\s+(.+)\z/m
            Message.new(level: :warn, type: type, message: $3, file: $1, line: $2.to_i)
          else
            Message.new(level: :warn, type: type, message: msg, file: @current_parsed_file)
          end
        puts '%{file}:%{line}: [%{type}] %{message}' % JunkYard::Logger.instance.messages.last.to_h
      end
    end

    class Message
      attr_reader :type, :level, :message, :file, :line

      def initialize(type:, level:, message:, file: '???', line: '?')
        @type = type
        @level = level
        @message = message.gsub(/\s{2,}/, ' ')
        @file = file
        @line = line
      end

      def to_h
        {
          type: type,
          level: level,
          message: message,
          file: file,
          line: line
        }
      end

      def ==(other)
        other.is_a?(Message) && @type == other.type && @level == other.level && @message == other.message &&
          @file == other.file && @line == other.line
      end
    end
  end
end
