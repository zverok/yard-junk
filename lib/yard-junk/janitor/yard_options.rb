module YardJunk
  class Janitor
    # Allows to properly parse `.yardopts` or other option file YARD supports and gracefully replace
    # or remove some of options.
    class YardOptions
      attr_reader :options, :files, :extra_files

      def initialize
        internal = Internal.new
        internal.parse_arguments
        @options = internal.option_args
        @files = internal.files
        @extra_files = internal.options.files
      end

      def set_files(*files)
        # TODO: REALLY fragile :(
        @files, @extra_files = files.partition { |f| f =~ /\.(rb|c|cxx|cpp)/ }
        self
      end

      def remove_option(long, short = nil)
        [short, long].compact.each do |o|
          i = @options.index(o)
          next unless i
          @options.delete_at(i)
          @options.delete_at(i) unless @options[i].start_with?('-') # it was argument
        end
        self
      end

      def to_a
        (@options + @files).tap { |res| res.concat(['-', *@extra_files]) unless @extra_files.empty? }
      end

      class Internal < YARD::CLI::Yardoc
        attr_reader :option_args

        def optparse(*args)
          @all_args = args
          super
        end

        def parse_files(*args)
          @option_args = @all_args - args
          super
        end
      end
    end
  end
end
