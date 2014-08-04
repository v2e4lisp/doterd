# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'doterd/version'

Gem::Specification.new do |spec|
  spec.name          = "doterd"
  spec.version       = Doterd::VERSION
  spec.authors       = ["wenjun.yan"]
  spec.email         = ["mylastnameisyan@gmail.com"]
  spec.summary       = %q{ruby dsl for ERD }
  spec.description   = %q{ruby dsl for ERD }
  spec.homepage      = "https://github.com/v2e4lisp/doterd"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
