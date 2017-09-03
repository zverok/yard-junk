# frozen_string_literal: true

module YardJunk
  module Rake
    extend ::Rake::DSL

    def self.define_task(*args)
      desc 'Check the junk in your YARD Documentation'
      task('yard:junk') do
        require 'yard'
        require_relative '../yard-junk'
        args = :text if args.empty?
        exit Janitor.new.run.report(*args)
      end
    end
  end
end
