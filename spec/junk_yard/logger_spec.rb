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

      its(:'messages.last') { is_expected
        .to eq JunkYard::Logger::Message.new(level: :warn, type: 'UnknownTag', message: 'Unknown tag @hello', file: 'test.rb')
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

      its(:'messages.last') { is_expected
        .to eq JunkYard::Logger::Message.new(level: :warn, type: 'UnknownTag', message: 'Unknown tag @hello', file: 'test.rb', line: 3)
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

    its(:'messages.last') { is_expected
      .to eq JunkYard::Logger::Message.new(level: :warn, type: 'UnknownParam', message: '@param tag has unknown parameter name: notaparam', file: 'test.rb', line: 3)
    }
  end

  context 'invaild link' do
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

    its(:'messages.last') { is_expected
      .to eq JunkYard::Logger::Message.new(level: :warn, type: 'InvalidLink', message: 'Cannot resolve link to InvalidObject from text: ...{InvalidObject}', file: 'test.rb', line: 3)
    }
  end
end
