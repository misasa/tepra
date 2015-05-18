require 'tepra'
require 'tepra/runner'
require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start

include Tepra
Dir.glob("spec/support/**/*.rb") { |f| load f, true }
Dir.glob("spec/steps/**/*steps.rb") { |f| load f, true }


RSpec.configure do |config|
 	config.mock_with :rspec do |c|
 		c.syntax = [:should, :expect]
 	end
 	config.expect_with :rspec do |c|
 		c.syntax = [:should, :expect]
 	end
 	config.deprecation_stream = 'log/deprecations.log'
end