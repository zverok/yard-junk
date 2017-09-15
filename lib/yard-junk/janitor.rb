# frozen_string_literal: true

require 'benchmark'
require 'backports/2.3.0/enumerable/grep_v'

module YardJunk
  class Janitor
    def initialize(mode: :full, pathes: nil)
      @mode = mode
      @files = expand_pathes(pathes)
    end

    def run(*opts)
      YARD::Registry.clear # Somehow loads all Ruby stdlib classes before Rake task started...
      Logger.instance.format = nil # Nothing shouuld be printed

      puts "Running YardJunk janitor (version #{YardJunk::VERSION})...\n\n"

      @duration = Benchmark.realtime do
        command = YARD::CLI::Yardoc.new
        command.run(*prepare_options(opts))
        Resolver.resolve_all(command.options) unless mode == :sanity
      end

      self
    end

    def stats
      {
        errors: errors.count,
        problems: problems.count,
        duration: @duration || 0
      }
    end

    def report(*args, **opts)
      guess_reporters(*args, **opts).each do |reporter|
        reporter.section('Errors', 'severe code or formatting problems', errors)
        reporter.section('Problems', 'mistyped tags or other typos in documentation', problems)

        reporter.stats(stats)
        reporter.finalize
      end

      exit_code
    end

    def exit_code
      return 2 unless errors.empty?
      return 1 unless problems.empty?
      0
    end

    private

    attr_reader :mode, :files, :yardopts

    BASE_OPTS = %w[--no-save --no-progress --no-stats --no-output --no-cache].freeze

    def prepare_options(opts)
      if mode == :full || mode == :sanity && files.nil?
        [*BASE_OPTS, *opts]
      elsif mode == :sanity
        # TODO: specs
        [*BASE_OPTS, '--no-yardopts', *yardopts_with_files(files)]
      else
        fail ArgumentError, "Undefined mode: #{mode.inspect}"
      end
    end

    def yardopts_with_files(files)
      # Use all options from .yardopts file, but replace files lists
      YardOptions.new.remove_option('--files').set_files(*files)
    end

    def messages
      @messages ||= YardJunk::Logger
                    .instance
                    .messages
                    .grep_v(Logger::Undocumentable) # FIXME: Not DRY
                    .select { |m| !files || !m.file || files.include?(File.expand_path(m.file)) }
    end

    def errors
      messages.select(&:error?)
    end

    def problems
      messages.select(&:warn?)
    end

    def expand_pathes(pathes)
      return unless pathes
      Array(pathes)
        .map { |path| File.directory?(path) ? File.join(path, '**', '*.*') : path }
        .flat_map(&Dir.method(:[]))
        .map(&File.method(:expand_path))
    end

    # TODO: specs for the logic
    def guess_reporters(*symbols, **symbols_with_args)
      symbols
        .map { |sym| [sym, nil] }.to_h.merge(symbols_with_args)
        .map { |sym, args| ["#{sym.to_s.capitalize}Reporter", args] }
        .each { |name, _| Janitor.const_defined?(name) or fail(ArgumentError, "Reporter #{name} not found") }
        .map { |name, args| Janitor.const_get(name).new(*args) }
    end
  end
end

require_relative 'janitor/base_reporter'
require_relative 'janitor/text_reporter'
require_relative 'janitor/html_reporter'
require_relative 'janitor/resolver'
require_relative 'janitor/yard_options'
