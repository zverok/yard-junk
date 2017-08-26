# frozen_string_literal: true

require 'yard'
require 'junk_yard/logger'

RSpec.describe JunkYard::Logger::Message do
  include FakeFS::SpecHelpers

  describe '.try_parse' do
    subject { klass.try_parse(input) }

    let(:klass) {
      Class.new(described_class) {
        pattern %r{^(?<message>Unknown tag @(?<tag>\S+))( in file `(?<file>[^`]+)` near line (?<line>\d+))?$}
      }
    }

    before { allow(klass).to receive(:name).and_return('UnknownTag') }

    context 'when matches' do
      let(:input) { 'Unknown tag @wrong in file `input/lot_of_errors.rb` near line 15' }

      its(:to_h) {
        is_expected.to eq(type: 'UnknownTag', message: 'Unknown tag @wrong', tag: 'wrong', file: 'input/lot_of_errors.rb', line: 15)
      }
    end

    context 'when partial match' do
      let(:input) { 'Unknown tag @wrong' }

      its(:to_h) {
        is_expected.to eq(type: 'UnknownTag', message: 'Unknown tag @wrong', tag: 'wrong', file: nil, line: nil)
      }
    end

    context 'with parsing context' do
      subject { klass.try_parse(input, file: 'input/lot_of_errors.rb') }

      let(:input) { 'Unknown tag @wrong' }

      its(:to_h) {
        is_expected.to eq(type: 'UnknownTag', message: 'Unknown tag @wrong', tag: 'wrong', file: 'input/lot_of_errors.rb', line: nil)
      }
    end

    context 'when not matches' do
      let(:input) { '@param tag has unknown parameter name: arg3' }

      it { is_expected.to be_nil }
    end

    context 'with search_up' do
      let(:input) { 'Unknown tag @wrong in file `lot_of_errors.rb` near line 5' }

      before {
        klass.search_up '@%{tag}(\W|$)'
        File.write 'lot_of_errors.rb', %{
          # @wrong
          #
          # Something else.
          def foo
          end
        }
      }
      its(:to_h) {
        is_expected.to include(file: 'lot_of_errors.rb', line: 2)
      }
    end
  end

  describe '#to_s' do
    context 'by default' do
      subject { klass.new(message: 'Unknown tag @wrong', tag: 'wrong', file: 'lot_of_errors.rb', line: 2) }

      let(:klass) {
        Class.new(described_class)
      }

      before { allow(klass).to receive(:name).and_return('UnknownTag') }

      its(:to_s) { is_expected.to eq 'lot_of_errors.rb:2: [UnknownTag] Unknown tag @wrong' }
    end
  end
end
