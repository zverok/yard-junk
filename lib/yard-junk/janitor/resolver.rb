# frozen_string_literal: true

module YardJunk
  class Janitor
    # TODO: Tests
    class Resolver
      include YARD::Templates::Helpers::HtmlHelper

      MESSAGE_PATTERN = 'In file `%{file}\':%{line}: Cannot resolve link to %{name} from text: %{link}'.freeze

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
        resolved = YARD::Registry.resolve(@docstring.object, name, true, true)
        return unless resolved.is_a?(YARD::CodeObjects::Proxy)
        Logger.instance.register(MESSAGE_PATTERN % {file: object.file, line: object.line, name: name, link: link})
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
