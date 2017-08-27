# frozen_string_literal: true

require 'benchmark'

module JunkYard
  class Janitor
    def run(*opts)
      YARD::Registry.clear # Somehow loads all Ruby stdlib classes before Rake task started...
      Logger.instance.format = nil

      puts "Running JunkYard janitor...\n\n"

      yardopts = File.read('.yardopts').split("\n").grep_v(/junk_yard/) # protection from double-require

      @duration = Benchmark.realtime do
        YARD::CLI::Yardoc.run('--no-save', '--no-progress', '--no-stats', '--no-output', *yardopts)
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

    def report(*reporters)
      reporters.each do |reporter|
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

    def messages
      JunkYard::Logger.instance.messages
    end

    def errors
      messages.select(&:error?)
    end

    def problems
      messages.select(&:warn?)
    end
  end
end

require_relative 'janitor/base_reporter'
require_relative 'janitor/text_reporter'
