# frozen_string_literal: true

RSpec.describe YardJunk::Janitor::Resolver do
  context 'escaped HTML' do
    subject { YardJunk::Logger.instance.messages }

    let(:fake_options) { OpenStruct.new(options.merge(markup: markup)) }
    let(:markup) { :markdown }
    let(:options) { {files: [readme]} }
    let(:readme) {
      # Not an instance_double, because resolver checks object class
      YARD::CodeObjects::ExtraFileObject.new('README.md', readme_contents).tap do |f|
        allow(f).to receive(:name).and_return('README')
        allow(f).to receive(:filename).and_return('README.md')
      end
    }
    let(:readme_contents) { '' }

    before {
      YARD::Registry.clear
      YardJunk::Logger.instance.clear
      YardJunk::Logger.instance.format = nil

      YARD.parse_string(source)
      described_class.resolve_all(fake_options)
    }

    context 'code objects' do
      let(:source) { %{
        # It meant to be code: {'message' => 'test'}
        def foo
        end
      }}

      its(:last) { is_expected.to have_attributes(message: "Cannot resolve link to 'message' from text: {'message' => 'test'}", line: 3) }

      context 'for RDoc' do
        let(:markup) { :rdoc }

        its(:last) { is_expected.to have_attributes(message: "Cannot resolve link to 'message' from text: {'message' => 'test'}", line: 3) }
      end
    end

    context 'file:' do
      context 'valid' do
        let(:source) { %{
          # {file:README.md}
          def foo
          end
        }}

        its(:last) { is_expected.to be_nil }
      end

      context 'invalid' do
        let(:source) { %{
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
      let(:source) { %{
        # {http://google.com Google}
        def foo
        end
      }}

      its(:last) { is_expected.to be_nil }
    end

    context 'check in files' do
      let(:readme_contents) { 'Is it {Foo}?' }
      let(:source) { '' }

      its(:last) { is_expected.to have_attributes(message: 'Cannot resolve link to Foo from text: {Foo}') }

      context 'RDoc readme' do
        let(:readme) {
          # Not an instance_double, because resolver checks object class
          YARD::CodeObjects::ExtraFileObject.new('README.rdoc', readme_contents).tap do |f|
            allow(f).to receive(:name).and_return('README')
            allow(f).to receive(:filename).and_return('README.rdoc')
          end
        }
        let(:readme_contents) { 'Is it {Foo}?' }

        its(:last) { is_expected.to have_attributes(message: 'Cannot resolve link to Foo from text: {Foo}') }
      end

      context 'Markdown README with rdoc settings' do
        let(:markup) { :rdoc }
        let(:readme_contents) { 'Is it `{Foo}`?' }

        its(:last) { is_expected.to be_nil }
      end
    end
  end
end
