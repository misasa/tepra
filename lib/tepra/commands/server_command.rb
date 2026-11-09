require 'tepra/command'
require 'tepra/server'

class Tepra::Commands::ServerCommand < Tepra::Command
	def initialize
		super 'server', 'Run the TEPRA HTTP server', :bind => '0.0.0.0', :port => Tepra.default_port

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

		add_option '-p', '--port=PORT', :Port, 'Set the listening port' do |port, options|
			options[:port] = port
		end

		add_option('-q', '--quit','Stop the server if it is running') do |v|
			options[:quit] = v
		end

		add_option '-b', '--bind=HOST,HOST','Set the addresses to listen on', Array do |address, options|
			options[:bind] ||= []
			options[:bind].push(*address)
		end
	end

	def execute
		if options[:quit]
			Tepra::Server.quit!
		else
			#Tepra.printme(:port => options[:port])
			Tepra::Server.run! options
		end
	end
end
