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

    its_block {
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

      its_block {
        is_expected
          .to send_message(reporter, :row).with(first).ordered
          .and send_message(reporter, :row).with(second).ordered
          .and send_message(reporter, :row).with(third).ordered
      }
    end

    context 'empty messages' do
      let(:messages) { [] }

      its_block { is_expected.not_to send_message(out, :puts) }
    end
  end

  describe '#row' do
    subject { reporter.send(:row, YardJunk::Logger::Message.new(message: 'Something bad', file: 'file.rb', line: 10)) }

    its_block { is_expected.to send_message(out, :puts).with('file.rb:10: [UnknownError] Something bad') }
  end

  describe '#stats' do
    subject { reporter.stats(**stats) }

    context 'there are errors' do
      let(:stats) { {errors: 3, problems: 2, duration: 5.2} }

      its_block {
        is_expected
          .to send_message(out, :puts)
          .with("\n\e[31m3 failures, 2 problems\e[0m (5 seconds to run)")
      }
    end

    context 'there are problems' do
      let(:stats) { {errors: 0, problems: 2, duration: 5.2} }

      its_block {
        is_expected
          .to send_message(out, :puts)
          .with("\n\e[33m0 failures, 2 problems\e[0m (5 seconds to run)")
      }
    end

    context 'everything is ok' do
      let(:stats) { {errors: 0, problems: 0, duration: 5.2} }

      its_block {
        is_expected
          .to send_message(out, :puts)
          .with("\n\e[32m0 failures, 0 problems\e[0m (5 seconds to run)")
      }
    end

    context 'TTY does not support colors' do
      let(:stats) { {errors: 3, problems: 2, duration: 5.2} }

      before { allow(TTY::Color).to receive(:supports?).and_return(false) }

      its_block {
        is_expected
          .to send_message(out, :puts)
          .with("\n3 failures, 2 problems (5 seconds to run)")
      }
    end
  end

  describe '#finalize' do
    subject { reporter.finalize }

    its_block { is_expected.not_to send_message(out, :puts) }
  end
end
