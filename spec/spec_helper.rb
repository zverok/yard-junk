# frozen_string_literal: true

require 'rspec/its'
require 'fakefs/spec_helpers'
require 'saharspec/its/call'
require 'saharspec/matchers/send_message'
require 'pp'

# Imitating YARD's core_ext/file.rb
module FakeFS
  class File
    def self.cleanpath(path)
      path
    end

    def self.read_binary(file)
      open(file, 'rb', &:read)
    end
  end
end

$LOAD_PATH.unshift 'lib'

require 'yard'
require 'junk_yard/logger'
require 'junk_yard/janitor'
