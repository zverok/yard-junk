# frozen_string_literal: true

RSpec.describe JunkYard::Janitor::Resolver do
  context 'escaped HTML' do
    before {
      JunkYard::Logger.instance.clear
      JunkYard::Logger.instance.format = nil

      YARD.parse_string(%{
        # It meant to be code: {'message' => 'test'}
        def foo
        end
      })
      described_class.resolve_all(fake_options)
    }

    subject { JunkYard::Logger.instance.messages }

    let(:fake_options) { OpenStruct.new(markup: :markdown) }

    its(:last) { is_expected.to have_attributes(message: "Cannot resolve link to 'message' from text: {'message' => 'test'}", line: 3) }
  end
end
