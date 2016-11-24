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
				begin
					Tepra.print(data, params)
				rescue => ex
				end
			end
			redirect '/'
		end

		get '/Format/Print' do
			id = params.delete("UID")
			name = params.delete("NAME")
			printer = params.delete("printer")
			template = params.delete("template")
			opts = {}
			opts[:printer_name] = printer if printer
			opts[:template_path] = template if template
			if id && name
				begin
					data = "#{id},#{name}"
					Tepra.print(data, opts)
				rescue => ex
				end
			end
			200
		end

		run! if app_file == $0
	end
end
