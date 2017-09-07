# frozen_string_literal: true

require 'did_you_mean'

module YardJunk
  class Logger
    class Message
      attr_reader :message, :severity, :file, :line, :extra

      def initialize(message:, severity: :warn, code_object: nil, file: nil, line: nil, **extra)
        @message = message.gsub(/\s{2,}/, ' ')
        @file = file
        @line = line && line.to_i
        @code_object = code_object
        @severity = severity
        @extra = extra
      end

      %i[error warn].each do |sev|
        define_method("#{sev}?") { severity == sev }
      end

      def to_h
        {
          type: type,
          message: message,
          file: file,
          line: (line && line.to_i) || 1
        }.merge(extra)
      end

      def ==(other)
        other.is_a?(self.class) && to_h == other.to_h
      end

      DEFAULT_FORMAT = '%{file}:%{line}: [%{type}] %{message}'

      def to_s(format = DEFAULT_FORMAT)
        format % to_h
      end

      def type
        self.class.type
      end

      private

      # DidYouMean changed API dramatically between 1.0 and 1.1, and different rubies have different
      # versions of it bundled.
      if DidYouMean.const_defined?(:SpellCheckable) # 1.0 +
        class SpellChecker < Struct.new(:error, :dictionary) # rubocop:disable Style/StructInheritance
          include DidYouMean::SpellCheckable

          def candidates
            {error => dictionary}
          end
        end

        def spell_check(error, dictionary)
          SpellChecker.new(error, dictionary).corrections
        end
      elsif DidYouMean.const_defined?(:SpellChecker) # 1.1+
        def spell_check(error, dictionary)
          DidYouMean::SpellChecker.new(dictionary: dictionary).correct(error)
        end
      elsif DidYouMean.const_defined?(:BaseFinder) # < 1.0
        class SpellFinder < Struct.new(:error, :dictionary) # rubocop:disable Style/StructInheritance
          include DidYouMean::BaseFinder

          def searches
            {error => dictionary}
          end
        end

        def spell_check(error, dictionary)
          SpellFinder.new(error, dictionary).suggestions
        end
      else
        def spell_check(*)
          []
        end
      end

      class << self
        def registry
          @registry ||= []
        end

        def pattern(regexp)
          @pattern = regexp
          Message.registry << self
        end

        def search_up(pattern) # rubocop:disable Style/TrivialAccessors
          @search_up = pattern
        end

        def try_parse(line, **context)
          @pattern or fail StandardError, "Pattern is not defined for #{self}"
          match = @pattern.match(line) or return nil
          data = context.reject { |_, v| v.nil? }
                        .merge(match.names.map(&:to_sym).zip(match.captures).to_h.reject { |_, v| v.nil? })
          data = guard_line(data)
          new(**data)
        end

        def type
          !name || name.end_with?('::Message') ? 'UnknownError' : name.sub(/^.+::/, '')
        end

        def valid_type?(type)
          type == 'UnknownError' || registry.any? { |m| m.type == type }
        end

        private

        def guard_line(data) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
          # FIXME: Ugly, huh?
          data[:file] && data[:line] && @search_up or return data
          data = data.merge(line: data[:line].to_i)
          data = data.merge(code_object: find_object(data[:file], data[:line]))
          lines = File.readlines(data[:file]) rescue (return data) # rubocop:disable Style/RescueModifier
          pattern = Regexp.new(@search_up % data.map { |k, v| [k, Regexp.escape(v.to_s)] }.to_h)
          _, num = lines.map
                        .with_index { |ln, i| [ln, i + 1] }
                        .first(data[:line]).reverse
                        .detect { |ln, _| pattern.match(ln) }
          num or return data

          data.merge(line: num)
        end

        def find_object(file, line)
          YARD::Registry.detect { |o| o.file == file && o.line == line }
        end
      end
    end

    class UnknownTag < Message
      pattern %r{^(?<message>Unknown tag (?<tag>@\S+))( in file `(?<file>[^`]+)` near line (?<line>\d+))?$}
      search_up '%{tag}(\W|$)'

      def message
        corrections.empty? ? super : "#{super}. Did you mean #{corrections.map { |c| "@#{c}" }.join(', ')}?"
      end

      private

      def corrections
        spell_check(extra[:tag], YARD::Tags::Library.labels.keys.map(&:to_s))
      end
    end

    class InvalidTagFormat < Message
      pattern %r{^(?<message>Invalid tag format for (?<tag>@\S+))( in file `(?<file>[^`]+)` near line (?<line>\d+))?$}
      search_up '%{tag}(\W|$)'
    end

    class UnknownDirective < Message
      pattern %r{^(?<message>Unknown directive (?<directive>@!\S+))( in file `(?<file>[^`]+)` near line (?<line>\d+))?$}
      search_up '%{directive}(\W|$)'

      # TODO: did_you_mean?
    end

    class InvalidDirectiveFormat < Message
      pattern %r{^(?<message>Invalid directive format for (?<directive>@!\S+))( in file `(?<file>[^`]+)` near line (?<line>\d+))?$}
      search_up '%{directive}(\W|$)'
    end

    class UnknownParam < Message
      pattern %r{^(?<message>@param tag has unknown parameter name: (?<param_name>\S+))\s+ in file `(?<file>[^']+)' near line (?<line>\d+)$}
      search_up '@param(\s+\[.+?\])?\s+?%{param_name}(\W|$)'

      def message
        corrections.empty? ? super : "#{super}. Did you mean #{corrections.map { |c| "`#{c}`" }.join(', ')}?"
      end

      private

      def corrections
        spell_check(extra[:param_name], known_params)
      end

      def known_params
        @code_object.is_a?(YARD::CodeObjects::MethodObject) or return []
        @code_object.parameters.map(&:first).map { |p| p.tr('*&:', '') }
      end
    end

    class MissingParamName < Message
      pattern %r{^(?<message>@param tag has unknown parameter name):\s+in file `(?<file>[^']+)' near line (?<line>\d+)$}
      search_up '@param(\s+\[.+?\])?\s*$'

      def message
        '@param tag has empty parameter name'
      end
    end

    class DuplicateParam < Message
      pattern %r{^(?<message>@param tag has duplicate parameter name: (?<param_name>\S+))\s+ in file `(?<file>[^']+)' near line (?<line>\d+)$}
      search_up '@param\s+(\[.+?\]\s+)?%{param_name}(\W|$)'
    end

    class RedundantBraces < Message
      pattern %r{^(?<message>@see tag \(\#\d+\) should not be wrapped in \{\} \(causes rendering issues\)):\s+in file `(?<file>[^']+)' near line (?<line>\d+)$}
      search_up '@see.*{.*}'

      def message
        super.sub(/\s+\(\#\d+\)\s+/, ' ')
      end
    end

    class SyntaxError < Message
      pattern %r{^Syntax error in `(?<file>[^`]+)`:\((?<line>\d+),(?:\d+)\): (?<message>.+)$}

      # Honestly, IDK why YARD considers it "warning"... So, rewriting
      def severity
        :error
      end
    end

    class CircularReference < Message
      pattern %r{^(?<file>.+?):(?<line>\d+): (?<message>Detected circular reference tag in `(?<object>[^']+)', ignoring all reference tags for this object \((?<context>[^)]+)\)\.)$}
    end

    class Undocumentable < Message
      pattern %r{^in (?:\S+): (?<message>Undocumentable (?<object>.+?))\n\s*in file '(?<file>[^']+)':(?<line>\d+):\s+(?:\d+):\s*(?<quote>.+?)\s*$}

      def message
        super + ": `#{quote}`"
      end

      def quote
        extra[:quote]
      end
    end

    class UnknownNamespace < Message
      pattern %r{^(?<message>The proxy (?<namespace>\S+?) has not yet been recognized).\nIf this class/method is part of your source tree, this will affect your documentation results.\nYou can correct this issue by loading the source file for this object before `(?<file>[^']+)'\n$}

      def namespace
        extra[:namespace]
      end

      def message
        "namespace #{namespace} is not recognized"
      end
    end

    class MacroAttachError < Message
      pattern %r{^(?<message>Attaching macros to non-methods is unsupported, ignoring: (?<object>\S+)) \((?<file>.+?):(?<line>\d+)\)$}
      search_up '@!macro \[attach\]'
    end

    class MacroNameError < Message
      pattern %r{^(?<message>Invalid/missing macro name for (?<object>\S+)) \((?<file>.+?):(?<line>\d+)\)$}
    end

    class InvalidLink < Message
      pattern %r{^In file `(?<file>[^']+)':(?<line>\d+): (?<message>Cannot resolve link to (?<object>\S+) from text:\s+(?<quote>.+))$}
      search_up '%{quote}'
    end
  end
end
