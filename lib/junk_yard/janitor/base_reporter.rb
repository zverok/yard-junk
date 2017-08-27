# frozen_string_literal: true

module JunkYard
  class Janitor
    # This class is a base for reporters that could be passed to
    # {Janitor#report}.
    #
    # Basically, the reporter should define methods:
    # * `header(title, explanation)` for printing problems section header;
    # * `row(msg)` for printing instance of {Logger::Message};
    # * `_stats(**statistics)` for printing statistics.
    #
    # Reporter also could redefine `finalize()` method, if it wants to do
    # something at the end of a report (like "add footer and save to file").
    #
    class BaseReporter
      # @overload initialize(io)
      #   @param io [#puts] Any IO-alike object that defines `puts` method.
      #
      # @overload initialize(filename)
      #   @param filename [String] Name of file to save the output.
      def initialize(io_or_filename)
        @io =
          case io_or_filename
          when ->(i) { i.respond_to?(:puts) } # quacks!
            io_or_filename
          when String
            File.open(io_or_filename, 'w')
          else
            fail ArgumentError, "Can't create reporter with #{io_or_filename.class}"
          end
      end

      def finalize; end

      def section(title, explanation, messages)
        return if messages.empty?
        header(title, explanation)

        messages
          .sort_by { |m| [m.file || '\uFFFF', m.line || 1000, m.message] }
          .each(&method(:row))
      end

      def stats(**stat)
        _stats(stat.merge(duration: humanize_duration(stat[:duration])))
      end

      private

      def _stats
        fail NotImplementedError
      end

      def header(_title, _explanation)
        fail NotImplementedError
      end

      def row(_message)
        fail NotImplementedError
      end

      def humanize_duration(duration)
        if duration < 60
          '%i seconds' % duration
        else
          '%.1f minutes' % (duration / 60)
        end
      end
    end
  end
end
