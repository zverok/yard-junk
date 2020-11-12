# frozen_string_literal: true

module YardJunk
  module CommandLineOptions
    def common_options(opts) # rubocop:disable Metrics/MethodLength
      super

      opts.separator ''
      opts.separator 'YardJunk plugin options'

      opts.on('--junk-log-format [FMT]',
              'YardJunk::Logger format string, by default '\
              "#{Logger::Message::DEFAULT_FORMAT.inspect}") do |format|
        Logger.instance.format = format
      end

      opts.on('--junk-log-ignore [TYPE1,TYPE2,...]',
              'YardJunk::Logger message types to ignore, by default '\
              "#{Logger::DEFAULT_IGNORE.map(&:inspect).join(', ')}") do |ignore|
        Logger.instance.ignore = ignore.to_s.split(',')
      end

      opts.separator ''
      opts.separator 'Generic options'
    end
  end
end
