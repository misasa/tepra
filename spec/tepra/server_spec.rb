require 'spec_helper'
require 'tepra/server'
require 'rack/test'

module Tepra
	describe Server do
		include Rack::Test::Methods

		def app
			Tepra::Server
		end

		describe "get '/'", :current => true do
			before do
				get '/', params
			end

			context "without params" do
				let(:params){ {} }
				it { expect(last_response).to be_ok }
			end

			context "with params" do
				let(:params){ {:data => 'hello,world'} }
				it { expect(last_response).to be_ok }
			end

		end

		describe "get '/print'" do
			before do
				get '/print', params
			end

			context "without params" do
				let(:params){ {} }
				it { expect(last_response).to be_ok }
			end

			context "with params" do
				let(:params){ {:data => 'hello,world'} }
				it { expect(last_response).to be_ok }
			end


			context "with params" do
				let(:params){ {:data => "hello,world"} }
				it { expect(last_response).to be_ok }
			end
		end

	end
end