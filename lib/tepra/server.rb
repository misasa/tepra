module Tepra
	require 'sinatra/base'
	class Server < Sinatra::Base
		get '/' do
			haml :index
		end

		get '/info' do
			@address_with_port = Tepra.ip_address.map{|addr| "#{addr}:#{request.port}"}
			haml :info
		end

		post '/print' do
			data = params.delete("data")
			if data
				Tepra.print(data, params)
			end
			redirect '/'
		end

		get '/Format/Print' do
			id = params.delete("UID")
			name = params.delete("NAME")
			if id && name
				data = "#{id},#{name}"
				Tepra.print(data, params)
			end
			200
		end

		run! if app_file == $0
	end
end
