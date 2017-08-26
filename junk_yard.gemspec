Gem::Specification.new do |s|
  s.name     = 'junk_yard'
  s.version  = '0.0.1pre'
  s.authors  = ['Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/zverok/junk_yard'

  s.summary = 'Get rid of the junk in your YARD docs'
  s.description = <<-EOF
    JunkYard is structured logger/error validator plugin for YARD documentation gem.
  EOF
  s.licenses = ['MIT']

  s.required_ruby_version = '>= 2.3.0'

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ /^(?:
    spec\/.*
    |Gemfile
    |Rakefile
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    |\.travis.yml
    )$/x
  end
  s.require_paths = ["lib"]

  s.add_dependency 'yard'
  s.add_dependency 'did_you_mean', '= 1.0.0'

  s.add_development_dependency 'rubocop', '>= 0.30'
  s.add_development_dependency 'rspec', '>= 3'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'rspec-its', '~> 1'
  s.add_development_dependency 'fakefs'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubygems-tasks'
  s.add_development_dependency 'yard'
end
