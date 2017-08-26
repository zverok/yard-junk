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
      puts message
    end

    def start_file(name)
      @current_parsed_file = name
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
          JunkYard::Logger.instance.start_file($1)
        end
        super
      end

      def warn(msg)
        #pp caller.grep_v(%r{gems/rspec}) -- TODO?
        #_, type = TYPES.detect { |re, _| msg =~ re } || [nil, 'OtherError']

        #JunkYard::Logger.instance.messages <<
          #if msg =~ /^(.+?)\s+in file `([^`']+)[`'] near line (\d+)$/
            #Message.new(level: :warn, type: type, message: $1, file: $2, line: $3.to_i)
          #elsif msg =~ /\AIn file `([^']+)':(\d+):\s+(.+)\z/m
            #Message.new(level: :warn, type: type, message: $3, file: $1, line: $2.to_i)
          #else
            #Message.new(level: :warn, type: type, message: msg, file: @current_parsed_file)
          #end
        #puts '%{file}:%{line}: [%{type}] %{message}' % JunkYard::Logger.instance.messages.last.to_h
        JunkYard::Logger.instance.register(msg)
      end
    end
  end
end
