require 'tepra/command'
require 'tepra/server'

class Tepra::Commands::ServerCommand < Tepra::Command
	def initialize
		super 'server', 'Tepra HTTP server', :port => 8808, :daemon => false

	end

	def execute
		Tepra::Server.run
	end
end
