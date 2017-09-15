# frozen_string_literal: true

module YardJunk
  class Janitor
    # @fuck
    class Resolver
      include YARD::Templates::Helpers::HtmlHelper

      # This one is copied from real YARD output
      OBJECT_MESSAGE_PATTERN = 'In file `%{file}\':%{line}: Cannot resolve link to %{name} from text: %{link}'.freeze

      # ...while this one is totally invented, YARD doesn't check file existance at all
      FILE_MESSAGE_PATTERN = "In file `%{file}':%{line}: File '%{name}' does not exist: %{link}".freeze

      def self.resolve_all(yard_options)
        YARD::Registry.all.map(&:base_docstring).each { |ds| new(ds, yard_options).resolve }
        yard_options.files.each { |file| new(file, yard_options).resolve }
      end

      def initialize(object, yard_options)
        case object
        when YARD::CodeObjects::ExtraFileObject
          init_file(object)
        when YARD::Docstring
          init_docstring(object)
        else
          fail "Unknown object to resolve #{object.class}"
        end
        @options = yard_options
      end

      def resolve
        markup_meth = "html_markup_#{options.markup}"
        return unless respond_to?(markup_meth)
        send(markup_meth, @string)
          .gsub(%r{<(code|tt|pre)[^>]*>(.*?)</\1>}im, '')
          .scan(/{[^}]+}/).flatten
          .map(&CGI.method(:unescapeHTML))
          .each(&method(:try_resolve))
      end

      private

      def init_file(file)
        @string = file.contents
        @file = file.filename
        @line = 1
      end

      def init_docstring(docstring)
        @string = docstring
        @root_object = docstring.object
        @file = @root_object.file
        @line = @root_object.line
      end

      attr_reader :options, :file, :line

      def try_resolve(link)
        name, _comment = link.tr('{}', '').split(/\s+/, 2)

        # See YARD::Templates::Helpers::BaseHelper#linkify for the source of patterns
        # TODO: there is also {include:}, {include:file:} and {render:} syntaxes, but I've never seen
        # a project using them. /shrug
        case name
        when %r{://}, /^mailto:/ # that's pattern YARD uses
          # do nothing, assume it is correct
        when /^file:(\S+?)(?:#(\S+))?$/
          resolve_file(Regexp.last_match[1], link)
        else
          resolve_code_object(name, link)
        end
      end

      def object
        @docstring.object
      end

      def resolve_file(name, link)
        return if options.files.any? { |f| f.name == name || f.filename == name }
        Logger.instance.register(FILE_MESSAGE_PATTERN % {file: file, line: line, name: name, link: link})
      end

      def resolve_code_object(name, link)
        resolved = YARD::Registry.resolve(@root_object, name, true, true)
        return unless resolved.is_a?(YARD::CodeObjects::Proxy)
        Logger.instance.register(OBJECT_MESSAGE_PATTERN % {file: file, line: line, name: name, link: link})
      end

      # required by HtmlHelper
      def serializer
        nil
      end
    end
  end
end
