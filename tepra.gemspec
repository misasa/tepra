# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tepra/version'

Gem::Specification.new do |spec|
  spec.name          = "tepra"
  spec.version       = Tepra::VERSION
  spec.authors       = ["Yusuke Yachi"]
  spec.email         = ["yyachi@misasa.okayama-u.ac.jp"]
  spec.description   = %q{Utilities for KING JIM's Tepra}
  spec.summary       = %q{Utilities for KING JIM's Tepra}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"  
  spec.add_development_dependency "geminabox", "~> 0.12"
  spec.add_development_dependency "rspec", "3.0.0"
  spec.add_development_dependency "turnip", "1.2.1"  
end
