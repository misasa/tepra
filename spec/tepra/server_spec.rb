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

		describe "get '/Format/Print'", :current => true do
			context "without params" do
				let(:params){ {} }
				before do
					get '/Format/Print', params
				end	
				it { expect(last_response).to be_ok }
			end
			context "with params" do
				let(:params){ {:UID => "12345", :NAME => "test-sample"} }
				it { 
					expect(Tepra).to receive(:print).with("12345,test-sample",{}).and_return('expect')
					get '/Format/Print', params
				}

			end

		end

		describe "get '/print'" do
			# before do
			# 	get '/print', params
			# end

			context "without params" do
				let(:params){ {} }
				before do
					get '/print', params
				end
				it { expect(last_response).to be_ok }
			end

			context "with params" do
				let(:params){ {:data => 'hello,world'} }
				before do
					allow(Tepra).to receive(:print)
					get '/print', params
				end

				it { expect(last_response).to be_ok }
			end


			context "with params" do
				let(:params){ {:data => "hello,world"} }
				before do
					#allow(Tepra).to receive(:print).and_return('mock')
					#get '/print', params
				end
				it { 
					expect(Tepra).to receive(:print).with("hello,world",{}).and_return('expect')
					get '/print', params
				}
				#it { expect(last_response).to be_ok }
			end
		end

	end
end