module Tepra
	require 'sinatra/base'
	require 'sinatra/json'
	class Server < Sinatra::Base
		get '/' do
			haml :index
		end

		get '/info' do
			@address_with_port = Tepra.ip_address.map{|addr| "#{addr}:#{request.port}"}
			haml :info
		end

        get '/printers.json' do
          data = Tepra.printer_hashs
          json data
        end

        get '/templates.json' do
          data = Tepra.template_hashs(:omit => ['default'])
          json data
        end


		post '/print' do
		  data = params.delete("data")
          printer = params.delete("printer")
          template = params.delete("template")
          opts = {}
          opts[:printer_name] = printer if printer && printer != ""
          opts[:template] = template if template && template != ""
			if data
				begin
					Tepra.print(data, opts)
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
			opts[:printer_name] = printer if printer && printer != ""
			opts[:template] = template if template && template != ""
			if id && name
				begin
			      data = "#{id},#{name}"
			      Tepra.print(data, opts)
				rescue => ex
                  puts ex
				end
			end
			200
		end

		run! if app_file == $0
	end
end
