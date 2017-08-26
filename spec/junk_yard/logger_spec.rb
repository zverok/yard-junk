require 'yard'
require 'junk_yard/logger'

RSpec.describe JunkYard::Logger do
  include FakeFS::SpecHelpers

  before(:all) do
    YARD::Logger.prepend(described_class::Mixin)
  end

  after(:all) do
    YARD::Registry.clear
  end

  def parse_file(contents)
    File.write('test.rb', contents)
    YARD.parse('test.rb')
  end

  subject(:logger) { JunkYard::Logger.instance }

  before { logger.messages.clear }

  context 'unknown tag' do
    context 'without location' do
      before {
        parse_file(%{
          # @hello world
        })
      }

      its(:'messages.last.to_h') { is_expected
        .to eq(type: 'UnknownTag', message: 'Unknown tag @hello', tag: 'hello', file: 'test.rb', line: nil)
      }
    end

    context 'with location' do
      before {
        parse_file(%{
          # @hello world
          def foo
          end
        })
      }

      its(:'messages.last.to_h') { is_expected
        .to eq(type: 'UnknownTag', message: 'Unknown tag @hello', tag: 'hello', file: 'test.rb', line: 2)
      }
    end
  end

  context 'unknown parameter' do
    before {
      parse_file(%{
        # @param notaparam foo
        def foo(a) end
      })
    }

    its(:'messages.last.to_h') { is_expected
      .to eq(type: 'UnknownParam', message: '@param tag has unknown parameter name: notaparam', param_name: 'notaparam', file: 'test.rb', line: 2)
    }
  end

  context 'invalid link' do
    include YARD::Templates::Helpers::BaseHelper
    include YARD::Templates::Helpers::HtmlHelper

    before {
      parse_file(%{
        # Comments here
        # And a reference to {InvalidObject}
        class MyObject; end
      })
      allow(self).to receive(:object).and_return(YARD::Registry.at('MyObject'))
      resolve_links(YARD::Registry.at('MyObject').docstring)
    }

    its(:'messages.last.to_h') { is_expected
      .to eq(type: 'InvalidLink', message: 'Cannot resolve link to InvalidObject from text: ...{InvalidObject}', object: 'InvalidObject', quote: '...{InvalidObject}', file: 'test.rb', line: 3)
    }
  end
end
