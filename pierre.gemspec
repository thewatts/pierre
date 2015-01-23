# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pierre/version'

Gem::Specification.new do |spec|
  spec.name          = "pierre"
  spec.version       = Pierre::VERSION
  spec.authors       = ["Nathaniel Watts"]
  spec.email         = ["reg@nathanielwatts.com"]
  spec.summary       = %q{More to come}
  spec.description   = %q{More to come}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.1.0"
end
