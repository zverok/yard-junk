module JunkYard
  class Janitor
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
        html_markup_markdown(@docstring).gsub(%r{<(code|tt|pre)[^>]*>(.*?)</\1>}i, '')
          .scan(/{[^}]+}/).flatten
          .each do |link|
            name, comment = link.tr('{}', '').split(/\s+/, 2)
            resolved = YARD::Registry.resolve(@docstring.object, name, true, true)
            next unless resolved.is_a?(YARD::CodeObjects::Proxy)
            Logger.instance.register(MESSAGE_PATTERN % {file: object.file, line: object.line, name: name, link: link})
          end
      end

      def options
        # TODO: use real YARD options
        OpenStruct.new(markup_provider: :kramdown)
      end

      private

      def object
        @docstring.object
      end
    end
  end
end
