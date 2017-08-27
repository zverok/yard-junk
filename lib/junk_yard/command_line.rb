module JunkYard
  module CommandLineOptions
   def common_options(opts)
    super

    opts.separator ""
    opts.separator "JunkYard plugin options"

    opts.on('--junk-log-format [FMT]', "JunkYard::Logger format string, by default #{Logger::Message::DEFAULT_FORMAT.inspect}") do |format|
      Logger.instance.format = format
    end

    opts.on('--junk-log-ignore TYPE1,TYPE2,...', "JunkYard::Logger message types to ignore, by default #{Logger::DEFAULT_IGNORE.map(&:inspect).join(', ')}") do |ignore|
      Logger.instance.ignore = ignore.split(',')
    end

    opts.separator ""
    opts.separator "Generic options"
   end
  end
end
