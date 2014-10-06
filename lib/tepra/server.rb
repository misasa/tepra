module Tepra
	require 'sinatra/base'
	class Server < Sinatra::Base
		get '/' do
			'Hello world!'
		end
		run! if app_file == $0
	end
end
