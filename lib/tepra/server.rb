module Tepra
	require 'sinatra/base'
	class Server < Sinatra::Base
		get '/' do
			erb :index
		end

		get '/print' do
			data = params.delete("data")
			if data
				Tepra.print(data, params)
			end
			erb :index
			#'Hello world!'
		end


		run! if app_file == $0
	end
end
