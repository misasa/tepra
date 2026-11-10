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
  spec.homepage      = "https://github.com/misasa/tepra"
  spec.license       = "GPL-3.0-or-later"

  spec.files         = `git ls-files -- lib bin template example config.ru README.md LICENSE.txt`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'csv'
  spec.add_dependency 'logger'
  spec.add_dependency 'ostruct'
  spec.add_dependency 'webrick'
  spec.add_dependency('sinatra', "~> 1.4.5")
  spec.add_dependency('sinatra-contrib', "~> 1.4.2")
  spec.add_dependency('haml', ">= 5.0.0")

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"  
  spec.add_development_dependency "geminabox", ">= 0.13.10"
  spec.add_development_dependency "rspec", "~> 3.13.0"
  spec.add_development_dependency "rack-test", "0.7.0"
#  spec.add_development_dependency "simplecov-rcov", "~> 0.2.3"
#  spec.add_development_dependency "rspec_junit_formatter", "~> 0.2.0"    
end
