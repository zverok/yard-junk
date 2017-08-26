module JunkYard
  class Logger
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
          type: type,
          message: message,
          file: file,
          line: line&.to_i
        }.merge(rest)
      end

      def ==(other)
        other.is_a?(self.class) && to_h == other.to_h
      end

      DEFAULT_FORMAT = '%{file}:%{line}: [%{type}] %{message}'.freeze

      def to_s(format = DEFAULT_FORMAT)
        format % to_h
      end

      private

      def type
        self.class == Message ? 'UnknownError' : self.class.name.sub(/^.+::/, '')
      end

      class << self
        def registry
          @registry ||= []
        end

        def pattern(regexp)
          @pattern = regexp
          Message.registry << self
        end

        def search_up(pattern)
          @search_up = pattern
        end

        def try_parse(line, **context)
          @pattern or fail StandardError, "Pattern is not defined for #{self}"
          match = @pattern.match(line) or return nil
          data = context.reject { |_, v| v.nil? }.merge(match.names.map(&:to_sym).zip(match.captures).to_h.reject { |_, v| v.nil? })
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

    class UnknownTag < Message
      pattern %r{^(?<message>Unknown tag (?<tag>@\S+))( in file `(?<file>[^`]+)` near line (?<line>\d+))?$}
      search_up '%{tag}(\W|$)'
    end

    class InvalidTagFormat < Message
      pattern %r{^(?<message>Invalid tag format for (?<tag>@\S+))( in file `(?<file>[^`]+)` near line (?<line>\d+))?$}
      search_up '%{tag}(\W|$)'
    end

    class UnknownDirective < Message
      pattern %r{^(?<message>Unknown directive (?<directive>@!\S+))( in file `(?<file>[^`]+)` near line (?<line>\d+))?$}
      search_up '%{directive}(\W|$)'
    end

    class InvalidDirectiveFormat < Message
      pattern %r{^(?<message>Invalid directive format for (?<directive>@!\S+))( in file `(?<file>[^`]+)` near line (?<line>\d+))?$}
      search_up '%{directive}(\W|$)'
    end

    class UnknownParam < Message
      pattern %r{^(?<message>@param tag has unknown parameter name: (?<param_name>\S+))\s+ in file `(?<file>[^']+)' near line (?<line>\d+)$}
      search_up '@param\s+(\[.+?\]\s+)?%{param_name}(\W|$)'
    end

    class DuplicateParam < Message
      pattern %r{^(?<message>@param tag has duplicate parameter name: (?<param_name>\S+))\s+ in file `(?<file>[^']+)' near line (?<line>\d+)$}
      search_up '@param\s+(\[.+?\]\s+)?%{param_name}(\W|$)'
    end

    class SyntaxError < Message
      pattern %r{^Syntax error in `(?<file>[^`]+)`:\((?<line>\d+),(?:\d+)\): (?<message>.+)$}
    end

    class CircularReference < Message
      pattern %r{^(?<file>.+?):(?<line>\d+): (?<message>Detected circular reference tag in `(?<object>[^']+)', ignoring all reference tags for this object \((?<context>[^)]+)\)\.)$}
    end

    class Undocumentable < Message
      pattern %r{^in (?:\S+): (?<message>Undocumentable (?<object>.+?))\n\s*in file '(?<file>[^']+)':(?<line>\d+):\s+(?:\d+):\s*(?<quote>.+?)\s*$}

      def message
        super + ": `#{rest[:quote]}`"
      end
    end

    class InvalidLink < Message
      pattern %r{^In file `(?<file>[^']+)':(?<line>\d+): (?<message>Cannot resolve link to (?<object>\S+) from text:\s+(?<quote>.+))$}
    end


  end
end
