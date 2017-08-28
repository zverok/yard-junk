# frozen_string_literal: true

module YardJunk
  module Rake
    extend ::Rake::DSL

    def self.define_task
      desc 'Check the junk in your YARD Documentation'
      task('yard:junk') do
        require 'yard'
        require_relative '../yard-junk'
        exit Janitor.new.run.report(Janitor::TextReporter.new(STDOUT))
      end
    end
  end
end
