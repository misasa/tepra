require 'tepra/command'
require 'tepra/server'

class Tepra::Commands::ServerCommand < Tepra::Command
	def initialize
		super 'server', 'Tepra HTTP server', :port => 8808, :bind => '0.0.0.0'

		add_option('-q', '--quit','Stop the self-hosted server if running') do |v|
			options[:quit] = v
		end

		add_option '-b', '--bind=HOST,HOST','addresses to bind', Array do |address, options|
			options[:bind] ||= []
			options[:bind].push(*address)
		end
	end

	def execute
		if options[:quit]
			Tepra::Server.quit!
		else
			Tepra::Server.run! options
		end
	end
end
