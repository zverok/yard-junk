# frozen_string_literal: true

module JunkYard
  class Janitor
    # TODO: Tests
    class Resolver
      include YARD::Templates::Helpers::HtmlHelper

      MESSAGE_PATTERN = 'In file `%{file}\':%{line}: Cannot resolve link to %{name} from text: %{link}'

      def self.resolve_all
        YARD::Registry.all.map(&:base_docstring).each { |ds| new(ds).resolve }
      end

      def initialize(docstring)
        @docstring = docstring
      end

      def resolve
        # TODO: use real YARD options
        html_markup_markdown(@docstring)
          .gsub(%r{<(code|tt|pre)[^>]*>(.*?)</\1>}i, '')
          .scan(/{[^}]+}/).flatten
          .each(&method(:try_resolve))
      end

      def options
        # TODO: use real YARD options
        OpenStruct.new(markup_provider: :kramdown)
      end

      private

      def try_resolve(link)
        name, _comment = link.tr('{}', '').split(/\s+/, 2)
        resolved = YARD::Registry.resolve(@docstring.object, name, true, true)
        return unless resolved.is_a?(YARD::CodeObjects::Proxy)
        Logger.instance.register(MESSAGE_PATTERN % {file: object.file, line: object.line, name: name, link: link})
      end

      def object
        @docstring.object
      end
    end
  end
end
