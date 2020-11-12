# frozen_string_literal: true

RSpec.describe YardJunk::Logger do
  subject(:logger) { described_class.instance }

  before {
    logger.clear
    logger.format = nil
  }

  describe '#register' do
    before { logger.register('Unknown tag @wrong in file `input/lot_of_errors.rb` near line 26') }

    its(:'messages.last') {
      is_expected
        .to be_a(described_class::Message)
        .and have_attributes(message: 'Unknown tag @wrong', extra: {tag: '@wrong'}, file: 'input/lot_of_errors.rb', line: 26)
    }
  end

  describe '#notify' do
    context 'on parsing start' do
      before {
        logger.notify('Parsing foo/bar.rb')
        logger.register('Unknown tag @wrong')
      }

      its(:'messages.last') { is_expected.to have_attributes(file: 'foo/bar.rb') }
    end

    context 'on parsing end' do
      before {
        logger.notify('Parsing foo/bar.rb')
        logger.notify('Generating asset js/jquery.js')
        logger.register('Unknown tag @wrong')
      }

      its(:'messages.last') { is_expected.to have_attributes(file: nil) }
    end
  end

  describe '#format=' do
    subject { logger.register('Unknown tag @wrong in file `input/lot_of_errors.rb` near line 26') }

    before { logger.clear } # set format to default

    context 'by default' do
      its_block { is_expected.to output("input/lot_of_errors.rb:26: [UnknownTag] Unknown tag @wrong\n").to_stdout }
    end

    context 'non-empty format' do
      before { logger.format = '%{message} (%{file}:%{line})' }

      its_block { is_expected.to output("Unknown tag @wrong (input/lot_of_errors.rb:26)\n").to_stdout }
    end

    context 'empty format' do
      before { logger.format = nil }

      its_block { is_expected.not_to output.to_stdout }
    end
  end

  describe '#ignore=' do
    subject {
      logger.register('Unknown tag @wrong in file `input/lot_of_errors.rb` near line 26')
      logger.register(%{in YARD::Handlers::Ruby::AttributeHandler: Undocumentable OPTIONS
	in file 'input/lot_of_errors.rb':38:

	38: attr_reader *OPTIONS})
    }

    before { logger.clear } # Set output format to default

    context 'by default' do
      its_block { is_expected.to output("input/lot_of_errors.rb:26: [UnknownTag] Unknown tag @wrong\n").to_stdout }
    end

    context 'set ignores' do
      before { logger.ignore = 'UnknownTag' }

      its_block { is_expected.to output("input/lot_of_errors.rb:38: [Undocumentable] Undocumentable OPTIONS: `attr_reader *OPTIONS`\n").to_stdout }
    end

    context 'ignore nothing' do
      before { logger.ignore = nil }

      its_block { is_expected.to output("input/lot_of_errors.rb:26: [UnknownTag] Unknown tag @wrong\ninput/lot_of_errors.rb:38: [Undocumentable] Undocumentable OPTIONS: `attr_reader *OPTIONS`\n").to_stdout }
    end

    context 'set wrong ignores' do
      subject { logger.ignore = 'Unknown Tag' }

      its_block { is_expected.to raise_error(ArgumentError, 'Unrecognized message type to ignore: Unknown Tag') }
    end
  end
end
