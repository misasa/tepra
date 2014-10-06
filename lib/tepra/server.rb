module Tepra
	require 'sinatra/base'
	class Server < Sinatra::Base
		get '/' do
			erb :index
		end

		get '/print' do
			data = params.delete("data")
			if data
				csvfile_path = Tepra.create_data_file(data, params)
				command = Tepra.command_spc_print(csvfile_path, params)
				system(command)
			end
			erb :index
			#'Hello world!'
		end


		run! if app_file == $0
	end
end
