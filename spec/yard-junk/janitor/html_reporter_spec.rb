# frozen_string_literal: true

RSpec.describe YardJunk::Janitor::HtmlReporter do
  subject(:reporter) { described_class.new(out) }

  let(:out) { StringIO.new }

  describe 'initial' do
    its(:html) { is_expected.to eq described_class::HEADER }
  end

  describe '#section' do
    before do
      reporter.section(
        'Section',
        'Explanation',
        [
          YardJunk::Logger::Message.new(message: 'Something bad', file: 'file.rb', line: 10),
          YardJunk::Logger::Message.new(message: 'Something bad', file: 'file.rb', line: 12)
        ]
      )
    end

    its(:html) do
      # NB: this is not very strict test, but... enough
      is_expected.to include('Section')
        .and include('Explanation')
        .and include('<li><span class="path">file.rb:10</span>: Something bad</li>')
    end
  end

  describe '#stats' do
    before do
      reporter.stats(
        errors: 3,
        problems: 2,
        duration: 5.2
      )
    end

    its(:html) do
      is_expected
        .to include('3 failures')
        .and include('2 problems')
        .and include('(ready in 5 seconds)')
    end
  end

  describe '#finalize' do
    subject { reporter.finalize }

    its_block {
      is_expected
        .to change(reporter, :html).to(include(described_class::FOOTER))
        .and send_message(out, :puts).with(%r{</html})
    }
  end
end
