# frozen_string_literal: true

module JunkYard
  module Rake
    extend ::Rake::DSL

    def self.define_task
      desc 'Check th junk in your YARD Documentation'
      task('yard:junk') do
        require 'yard'
        require_relative '../junk_yard'
        Janitor.new.run.report(Janitor::TextReporter.new(STDOUT))
      end
    end
  end
end
