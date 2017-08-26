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
      attr_reader :message, :file, :line, :rest

      def initialize(message:, file: nil, line: nil, **rest)
        @message = message.gsub(/\s{2,}/, ' ')
        @file = file
        @line = line
        @rest = rest
      end

      def to_h
        {
          name: self.class.name,
          message: message,
          file: file,
          line: line&.to_i
        }.merge(rest)
      end

      def ==(other)
        other.is_a?(self.class) && to_h == other.to_h
      end

      DEFAULT_FORMAT = '%{file}:%{line}: [%{name}] %{message}'.freeze

      def to_s(format = DEFAULT_FORMAT)
        format % to_h
      end

      class << self
        def pattern(regexp)
          @pattern = regexp
        end

        def search_up(pattern)
          @search_up = pattern
        end

        def try_parse(line)
          @pattern or fail StandardError, "Pattern is not defined for #{self}"
          match = @pattern.match(line) or return nil
          data = match.names.map(&:to_sym).zip(match.captures).to_h
          data = guard_line(data)
          new(**data)
        end

        private

        def guard_line(data)
          data[:file] && data[:line] && @search_up or return data
          data = data.merge(line: data[:line].to_i)
          lines = File.readlines(data[:file]) rescue (return data)
          pattern = Regexp.new(@search_up % data)
          _, num = lines.map
            .with_index { |ln, i| [ln, i + 1] }
            .first(data[:line]).reverse
            .detect { |ln, i| pattern.match(ln) }
          num or return data

          return data.merge(line: num)
        end
      end
    end

    #class UnknownTag < Message
      #format %r{^(?<message>Unknown tag @(?<tag>\S+))( in file `(?<file>[^`]+)` near line (?<line>\d+))?$}
    #end

    #class UnknownParam < Message
      #format %r{^(?<message>@param tag has unknown parameter name: (?<param_name>\S+))\s+ in file `(?<file>[^']+)' near line (?<line>\d+))?$}

    #end
  end
end
