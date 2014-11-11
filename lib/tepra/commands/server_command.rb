require 'tepra/command'
require 'tepra/server'

class Tepra::Commands::ServerCommand < Tepra::Command
	def initialize
		super 'server', 'Tepra HTTP server', :port => 8889, :bind => '0.0.0.0'

		OptionParser.accept :Port do |port|
			if port =~ /\A\d+\z/ then
				port = Integer port
				raise OptionParser::InvalidArgument, "#{port}: not a port number" if
				port > 65535
				port
			else
				begin
					Socket.getservbyname port
				rescue SocketError
					raise OptionParser::InvalidArgument, "#{port}: no such named service"
				end
			end
		end

		add_option '-p', '--port=PORT', :Port, 'port to listen on' do |port, options|
			options[:port] = port
		end

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
