# frozen_string_literal: true

RSpec.describe YardJunk::Janitor::Resolver do
  context 'escaped HTML' do
    let(:fake_options) { OpenStruct.new(options.merge(markup: :markdown)) }
    let(:options) { {} }

    before {
      YARD::Registry.clear
      YardJunk::Logger.instance.clear
      YardJunk::Logger.instance.format = nil

      YARD.parse_string(source)
      described_class.resolve_all(fake_options)
    }

    subject { YardJunk::Logger.instance.messages }

    context 'code objects' do
      let(:source) {%{
        # It meant to be code: {'message' => 'test'}
        def foo
        end
      }}
      its(:last) { is_expected.to have_attributes(message: "Cannot resolve link to 'message' from text: {'message' => 'test'}", line: 3) }
    end

    context 'file:' do
      let(:options) { {files: [instance_double('YARD::CodeObjects::ExtraFileObject', name: 'README', filename: 'README.md')]} }

      context 'valid' do
        let(:source) {%{
          # {file:README.md}
          def foo
          end
        }}

        its(:last) { is_expected.to be_nil }
      end

      context 'invalid' do
        let(:source) {%{
          # {file:GettingStarted.md}
          def foo
          end
        }}

        its(:last) { is_expected.to have_attributes(message: "File 'GettingStarted.md' does not exist: {file:GettingStarted.md}", line: 3) }
      end

      context 'existing, but not included in YARD list'
      context 'included in YARD list, but not existing'
    end

    context 'include:'
    context 'include:file:'
    context 'render:'

    context 'url' do
      let(:source) {%{
        # {http://google.com Google}
        def foo
        end
      }}
      its(:last) { is_expected.to be_nil }
    end
  end
end
