# frozen_string_literal: true

require 'junk_yard/janitor'

RSpec.describe JunkYard::Janitor do
  subject(:janitor) { described_class.new }

  before { JunkYard::Logger.instance.clear }

  describe '#run' do
    subject { janitor.run }

    its_call {
      is_expected
        .to send_message(YARD::Registry, :clear)
        .and send_message(YARD::CLI::Yardoc, :run)
        .with('--no-save', '--no-progress', '--no-output')
        .and send_message(JunkYard::Logger.instance, :format=).with(nil).calling_original
                                                              .and output("Running JunkYard janitor...\n\n").to_stdout
    }
  end

  def data_for_report
    logger = JunkYard::Logger.instance
    logger.format = nil
    logger.register('Unknown tag @wrong in file `input/lot_of_errors.rb` near line 26')
    logger.register('@param tag has duplicate parameter name: para in file `input/lot_of_errors.rb\' near line 33')
    logger.register('input/circular_ref.rb:5: Detected circular reference tag in `Foo#b\', ignoring all reference tags for this object (@param).', :error)
    logger.register("Syntax error in `input/unparseable.rb`:(3,4): syntax error, unexpected '\\n', expecting &. or :: or '[' or '.'")
    janitor.instance_variable_set('@duration', 250.6) # :shrug:
  end

  describe '#stats' do
    subject { janitor.stats }

    context 'initial' do
      it { is_expected.to eq(errors: 0, problems: 0, duration: 0) }
    end

    context 'after run' do
      before { data_for_report }

      it { is_expected.to eq(errors: 2, problems: 2, duration: 250.6) }
    end
  end

  describe '#exit_code' do
    context 'by default' do
      its(:exit_code) { is_expected.to eq 0 }
    end

    context 'with problems' do
      before { data_for_report }

      its(:exit_code) { is_expected.to eq 2 }
    end
  end

  describe '#report' do
    before { data_for_report }

    subject { janitor.report(reporter) }

    let(:reporter) { instance_double('JunkYard::Janitor::BaseReporter', section: nil, stats: nil, finalize: nil) }

    its_call {
      is_expected
        .to send_message(reporter, :section)
        .with('Errors', 'severe code or formatting problems',
          an_instance_of(Array).and(have_attributes(count: 2))
            .and(all(be_a(JunkYard::Logger::Message))).and(all(be_error)))
        .and send_message(reporter, :section)
        .with('Problems', 'mistyped tags or other typos in documentation',
          an_instance_of(Array).and(have_attributes(count: 2))
            .and(all(be_a(JunkYard::Logger::Message))).and(all(be_warn)))
        .and send_message(reporter, :stats)
        .with(errors: 2, problems: 2, duration: 250.6)
        .and send_message(reporter, :finalize)
    }
  end
end
