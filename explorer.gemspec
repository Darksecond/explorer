# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'explorer/version'

Gem::Specification.new do |spec|
  spec.name          = "explorer"
  spec.version       = Explorer::VERSION
  spec.authors       = ["Tim Peters"]
  spec.email         = ["mail@darksecond.nl"]
  spec.summary       = %q{A pow! replacement.}
  spec.description   = %q{A pow! replacement written in ruby.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.9"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'rubydns', '~> 1.0'
  spec.add_dependency 'reel', '~> 0.5'
  spec.add_dependency 'thor', '~> 0.19'
  spec.add_dependency 'celluloid', '~> 0.16'
  spec.add_dependency 'celluloid-io', '~> 0.16'
  spec.add_dependency 'dotenv', '~> 2.0'
  spec.add_dependency 'rainbow', '~> 2.0'
  spec.add_dependency 'formatador', '~> 0.2'
end
