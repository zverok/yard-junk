# frozen_string_literal: true

RSpec.describe YardJunk::Janitor::Resolver do
  context 'escaped HTML' do
    before {
      YardJunk::Logger.instance.clear
      YardJunk::Logger.instance.format = nil

      YARD.parse_string(%{
        # It meant to be code: {'message' => 'test'}
        def foo
        end
      })
      described_class.resolve_all(fake_options)
    }

    subject { YardJunk::Logger.instance.messages }

    let(:fake_options) { OpenStruct.new(markup: :markdown) }

    its(:last) { is_expected.to have_attributes(message: "Cannot resolve link to 'message' from text: {'message' => 'test'}", line: 3) }
  end
end
