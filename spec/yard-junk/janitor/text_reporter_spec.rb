# frozen_string_literal: true

RSpec.describe YardJunk::Janitor::TextReporter do
  let(:out) { StringIO.new }
  let(:reporter) { described_class.new(out) }

  describe '#section' do
    subject {
      reporter.section(
        'Section',
        'Explanation',
        messages
      )
    }

    let(:messages) {
      [
        YardJunk::Logger::Message.new(message: 'Something bad', file: 'file.rb', line: 10),
        YardJunk::Logger::Message.new(message: 'Something bad', file: 'file.rb', line: 10)
      ]
    }

    its_call {
      is_expected
        .to send_message(out, :puts).with(no_args)
        .and send_message(out, :puts).with('Section')
        .and send_message(out, :puts).with('-------')
        .and send_message(out, :puts).with("Explanation\n\n")
        .and send_message(reporter, :row).exactly(2).times
    }

    context 'ordering' do
      let(:first)  { YardJunk::Logger::Message.new(message: 'Something bad 1', file: 'file.rb', line: 10) }
      let(:second) { YardJunk::Logger::Message.new(message: 'Something bad 2', file: 'file.rb', line: 15) }
      let(:third)  { YardJunk::Logger::Message.new(message: 'Something bad 2', file: 'other_file.rb', line: 5) }
      let(:messages) { [third, second, first] }

      its_call {
        is_expected
          .to send_message(reporter, :row).with(first).ordered
          .and send_message(reporter, :row).with(second).ordered
          .and send_message(reporter, :row).with(third).ordered
      }
    end

    context 'empty messages' do
      let(:messages) { [] }

      its_call { is_expected.not_to send_message(out, :puts) }
    end
  end

  describe '#row' do
    subject { reporter.send(:row, YardJunk::Logger::Message.new(message: 'Something bad', file: 'file.rb', line: 10)) }

    its_call { is_expected.to send_message(out, :puts).with('file.rb:10: [UnknownError] Something bad') }
  end

  describe '#stats' do
    subject {
      reporter.stats(
        errors: 3,
        problems: 2,
        duration: 5.2
      )
    }

    its_call { is_expected.to send_message(out, :puts).with("\n\e[31m3 failures\e[0m\e[38;5;188m,\e[0m\e[33m 2 problems\e[0m\e[38;5;188m, (5 seconds to run)\e[0m") }
  end

  describe '#finalize' do
    subject { reporter.finalize }

    its_call { is_expected.not_to send_message(out, :puts) }
  end
end
