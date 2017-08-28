Gem::Specification.new do |s|
  s.name     = 'yard-junk'
  s.version  = '0.0.1'
  s.authors  = ['Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/zverok/junk_yard'

  s.summary = 'Get rid of the junk in your YARD docs'
  s.description = <<-EOF
    YardJunk is structured logger/error validator plugin for YARD documentation gem.
  EOF
  s.licenses = ['MIT']

  s.required_ruby_version = '>= 2.3.0'

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
  s.bindir = 'bin'
  s.executables << 'yard-junk'

  s.add_dependency 'yard'
  if RUBY_VERSION < '2.4'
    s.add_dependency 'did_you_mean', '~> 1.0'
  else
    s.add_dependency 'did_you_mean', '~> 1.1'
  end

  s.add_development_dependency 'rubocop', '>= 0.49'
  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'rspec-its', '~> 1'
  #s.add_development_dependency 'saharspec'
  s.add_development_dependency 'fakefs'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubygems-tasks'
  s.add_development_dependency 'yard'
end
