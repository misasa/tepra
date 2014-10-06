require 'spec_helper'
require 'tepra/server'
require 'rack/test'

module Tepra
	describe Server do
		include Rack::Test::Methods

		def app
			Tepra::Server
		end

		it 'should be OK' do
			get '/'
			expect(last_response).to be_ok
		end

	end
end