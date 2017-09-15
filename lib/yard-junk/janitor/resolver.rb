# frozen_string_literal: true

module YardJunk
  class Janitor
    class Resolver
      include YARD::Templates::Helpers::HtmlHelper

      # This one is copied from real YARD output
      OBJECT_MESSAGE_PATTERN = 'In file `%{file}\':%{line}: Cannot resolve link to %{name} from text: %{link}'.freeze

      # ...while this one is totally invented, YARD doesn't check file existance at all
      FILE_MESSAGE_PATTERN = "In file `%{file}':%{line}: File '%{name}' does not exist: %{link}".freeze

      def self.resolve_all(yard_options)
        YARD::Registry.all.map(&:base_docstring).each { |ds| new(ds, yard_options).resolve }
      end

      def initialize(docstring, yard_options)
        @docstring = docstring
        @options = yard_options
      end

      def resolve
        markup_meth = "html_markup_#{options.markup}"
        return unless respond_to?(markup_meth)
        send(markup_meth, @docstring)
          .gsub(%r{<(code|tt|pre)[^>]*>(.*?)</\1>}im, '')
          .scan(/{[^}]+}/).flatten
          .map(&CGI.method(:unescapeHTML))
          .each(&method(:try_resolve))
      end

      private

      attr_reader :options

      def try_resolve(link)
        name, _comment = link.tr('{}', '').split(/\s+/, 2)

        # See YARD::Templates::Helpers::BaseHelper#linkify for the source of patterns
        # TODO: there is also {include:}, {include:file:} and {render:} syntaxes, but I've never seen
        # a project using them. /shrug
        case name
        when %r{://}, /^mailto:/ # that's pattern YARD uses
          # do nothing, assume it is correct
        when /^file:(\S+?)(?:#(\S+))?$/
          name = Regexp.last_match[1]
          return if options.files.any? { |f| f.name == name || f.filename == name }
          Logger.instance.register(FILE_MESSAGE_PATTERN % {file: object.file, line: object.line, name: name, link: link})
        else
          resolved = YARD::Registry.resolve(@docstring.object, name, true, true)
          return unless resolved.is_a?(YARD::CodeObjects::Proxy)
          Logger.instance.register(OBJECT_MESSAGE_PATTERN % {file: object.file, line: object.line, name: name, link: link})
        end
      end

      def object
        @docstring.object
      end

      # required by HtmlHelper
      def serializer
        nil
      end
    end
  end
end
