# frozen_string_literal: true

RSpec.describe 'Integration: catching errors' do
  include FakeFS::SpecHelpers

  before(:all) do
    YARD::Logger.prepend(YardJunk::Logger::Mixin)
  end

  after(:all) do
    YARD::Registry.clear
  end

  def parse_file(contents)
    # It would be "fake" file, provided by FakeFS and stored nowhere
    File.write('test.rb', contents)
    YARD.parse('test.rb')
  end

  subject(:logger) { YardJunk::Logger.instance }

  before {
    logger.clear
    logger.format = nil # do not print messages to STDOUT
  }

  shared_examples_for 'file parser' do |description, code, **message|
    context description do
      let(:defaults) { {file: 'test.rb', line: 1} }

      before { parse_file(code) }

      its(:'messages.last.to_h') { is_expected
        .to eq(defaults.merge(message))
      }
    end
  end

  it_behaves_like 'file parser', 'unknown tag',
    %{
      # @hello world
      def foo
      end
    },
    type: 'UnknownTag',
    message: 'Unknown tag @hello',
    tag: '@hello',
    line: 2

  it_behaves_like 'file parser', 'unknown tag: no location',
    %{
      # @hello world
    },
    type: 'UnknownTag',
    message: 'Unknown tag @hello',
    tag: '@hello'

  it_behaves_like 'file parser', 'unknown tag: did you mean?',
    %{
      # @raises NoMethodError
      def foo
      end
    },
    type: 'UnknownTag',
    message: 'Unknown tag @raises. Did you mean @raise?',
    tag: '@raises',
    line: 2

  it_behaves_like 'file parser', 'invalid tag format',
    %{
      # @example
      def bar
      end
    },
    type: 'InvalidTagFormat',
    message: 'Invalid tag format for @example',
    tag: '@example',
    line: 2

  it_behaves_like 'file parser', 'unknown directive',
    %{
      # @!hello world
      def foo
      end
    },
    type: 'UnknownDirective',
    message: 'Unknown directive @!hello',
    directive: '@!hello',
    line: 2

  it_behaves_like 'file parser', 'invalid directive format',
    %{
      # @!macro
      def bar
      end
    },
    type: 'InvalidDirectiveFormat',
    message: 'Invalid directive format for @!macro',
    directive: '@!macro',
    line: 2

  it_behaves_like 'file parser', 'unknown parameter',
    %{
      # @param notaparam foo
      def foo(a) end
    },
    type: 'UnknownParam',
    message: '@param tag has unknown parameter name: notaparam',
    param_name: 'notaparam',
    line: 2

  it_behaves_like 'file parser', 'unknown parameter: did you mean',
    %{
      # @param tuples foo
      def foo(tuple) end
    },
    type: 'UnknownParam',
    message: '@param tag has unknown parameter name: tuples. Did you mean `tuple`?',
    param_name: 'tuples',
    line: 2

  it_behaves_like 'file parser', 'unknown parameter without name',
    %{
      # @param [String]
      def foo(a) end
    },
    type: 'MissingParamName',
    message: '@param tag has empty parameter name',
    line: 2

  it_behaves_like 'file parser', 'unknown parameter for generated method',
    %{
      # @!method join(delimiter, null_repr)
      #   Convert the array to a string by joining
      #   values with a delimiter (empty stirng by default)
      #   and optional filler for NULL values
      #   Translates to an `array_to_string` call
      #
      #   @param [Object] delimiter
      #   @param [Object] null
      #
      #   @return [SQL::Attribute<Types::String>]
      #
      #   @api public
    },
    type: 'UnknownParam',
    message: '@param tag has unknown parameter name: null',
    param_name: 'null',
    line: 9

  it_behaves_like 'file parser', 'diplicate parameter',
    %{
      # @param para
      # @param para
      def bar(para)
      end
    },
    type: 'DuplicateParam',
    message: '@param tag has duplicate parameter name: para',
    param_name: 'para',
    line: 3

  it_behaves_like 'file parser', 'syntax error',
    %{
      foo, bar.
    },
    type: 'SyntaxError',
    message: "syntax error, unexpected end-of-input, expecting '('",
    line: 3

  it_behaves_like 'file parser', 'circular reference',
    %{
      class Foo
        # @param (see #b)
        def a; end
        # @param (see #a)
        def b; end
      end
    },
    type: 'CircularReference',
    message: "Detected circular reference tag in `Foo#b', ignoring all reference tags for this object (@param).",
    object: 'Foo#b',
    context: '@param',
    line: 6

  it_behaves_like 'file parser', 'undocumentable',
    %{
      attr_reader *OPTIONS
    },
    type: 'Undocumentable',
    message: 'Undocumentable OPTIONS: `attr_reader *OPTIONS`',
    quote: 'attr_reader *OPTIONS',
    object: 'OPTIONS',
    line: 2

  it_behaves_like 'file parser', 'not recognized',
    %{
      Bar::BOOKS = 5
    },
    type: 'UnknownNamespace',
    message: 'namespace Bar is not recognized',
    namespace: 'Bar'

  it_behaves_like 'file parser', 'macro attaching error',
    %{
      # @!macro [attach] attached4
      #  $1 $2 $3
      class A
      end
    },
    type: 'MacroAttachError',
    message: 'Attaching macros to non-methods is unsupported, ignoring: A',
    object: 'A',
    line: 2

  it_behaves_like 'file parser', 'macro name error',
    %{
      # @!macro wtf
      def foo
      end
    },
    type: 'MacroNameError',
    message: 'Invalid/missing macro name for #foo',
    object: '#foo',
    line: 3

  it_behaves_like 'file parser', 'redundant braces',
    %{
      # @see {invalid}
      def foo
      end
    },
    type: 'RedundantBraces',
    message: '@see tag should not be wrapped in {} (causes rendering issues)',
    line: 2

  # TODO: DRY!
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
