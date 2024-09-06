require_relative 'lib/yard-junk/version'

Gem::Specification.new do |s|
  s.name     = 'yard-junk'
  s.version  = YardJunk::VERSION
  s.authors  = ['Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/zverok/yard-junk'

  s.summary = 'Get rid of the junk in your YARD docs'
  s.description = <<-EOF
    YardJunk is structured logger/error validator plugin for YARD documentation gem.
  EOF
  s.licenses = ['MIT']

  s.required_ruby_version = '>= 2.5.0'

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
  s.add_dependency 'backports', '>= 3.18'
  s.add_dependency 'rainbow'
  s.add_dependency 'ostruct'

  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'rspec-its', '~> 1'
  s.add_development_dependency 'saharspec'
  s.add_development_dependency 'fakefs'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubygems-tasks'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'kramdown'
end
