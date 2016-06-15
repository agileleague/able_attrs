# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'able_attrs/version'

Gem::Specification.new do |spec|
  spec.name          = "able_attrs"
  spec.version       = AbleAttrs::VERSION
  spec.authors       = ["John Maxwell"]
  spec.email         = ["john@agileleague.com"]

  spec.summary       = "Capable attributes for your Ruby classes."
  spec.description   = "Capable attributes for your Ruby classes. Provides a DSL to define attributes whose values can be initialized, type-coerced, and transformed from common inputs upon setting."
  spec.homepage      = "https://github.com/agileleague/able_attrs"
  spec.license       = "MIT"

  spec.files         = [".gitignore", ".travis.yml", "CODE_OF_CONDUCT.md", "Gemfile", "LICENSE.txt", "README.md", "Rakefile", "able_attrs.gemspec", "bin/console", "bin/setup", "lib/able_attrs.rb", "lib/able_attrs/version.rb"]
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "pry", "~> 0.10.3"
end
