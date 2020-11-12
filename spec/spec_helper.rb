# frozen_string_literal: true

require 'rspec/its'
require 'fakefs/spec_helpers'
require 'saharspec'
require 'pp'

# Imitating YARD's core_ext/file.rb
module FakeFS
  class File
    def self.cleanpath(path)
      path
    end

    def self.read_binary(file)
      File.open(file, 'rb', &:read)
    end
  end
end

$LOAD_PATH.unshift 'lib'

require 'yard'
require 'yard-junk/version'
require 'yard-junk/logger'
require 'yard-junk/janitor'
