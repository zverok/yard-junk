require_relative 'lib/yard-junk/version'

Gem::Specification.new do |s|
  s.name     = 'yard-junk'
  s.version  = YardJunk::VERSION
  s.authors  = ['Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/zverok/junk_yard'

  s.summary = 'Get rid of the junk in your YARD docs'
  s.description = <<-EOF
    YardJunk is structured logger/error validator plugin for YARD documentation gem.
  EOF
  s.licenses = ['MIT']

  s.required_ruby_version = '>= 2.1.0'

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ /^(?:
    spec\/.*
    |Gemfile
    |Rakefile
    |\.codeclimate.yml
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    |\.rubocop_todo.yml
    |\.travis.yml
    |\.yardopts
    )$/x
  end
  s.require_paths = ["lib"]
  s.bindir = 'exe'
  s.executables << 'yard-junk'

  s.add_dependency 'yard'
  s.add_dependency 'did_you_mean' if RUBY_VERSION < '2.3'
  s.add_dependency 'backports'
  s.add_dependency 'rainbow'
  s.add_dependency 'tty-color'

  s.add_development_dependency 'rubocop', '= 0.49' # 0.50 breaks current rubocop-rspec
  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'rubocop-rspec', '= 1.15.1' # 1.16+ is broken on JRuby
  s.add_development_dependency 'rspec-its', '~> 1'
  #s.add_development_dependency 'saharspec' # saharspec is moving target!
  s.add_development_dependency 'fakefs'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubygems-tasks'
  s.add_development_dependency 'yard'
end
