require 'rspec/its'
require 'fakefs/spec_helpers'
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
