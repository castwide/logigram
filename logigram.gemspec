lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logigram/version'

Gem::Specification.new do |spec|
  spec.name          = 'logigram'
  spec.version       = Logigram::VERSION
  spec.authors       = ['Fred Snyder']
  spec.email         = ['fsnyder@castwide.com']

  spec.summary       = 'A library for generating logic puzzles'
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://castwide.com'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'opal', '~> 1.7'
  spec.add_development_dependency 'opal-rspec', '~> 1.0'
  spec.add_development_dependency 'opal-sprockets', '~> 1.0'
  spec.add_development_dependency 'rake', '~> 13.2'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
end
