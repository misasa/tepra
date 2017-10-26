require 'spec_helper'
require 'tepra/server'
require 'rack/test'

module Tepra
	describe Server do
		include Rack::Test::Methods

		def app
			Tepra::Server
		end

		describe "get '/info'" do
			it {
				get '/info'
				expect(last_response).to be_ok
			}
		end

        describe "get '/printers.json'" do
          it {
          	get '/printers.json'
          	expect(last_response).to be_ok
          }          
#          after do
#          	puts last_response.body
#          end
        end

        describe "get '/templates.json'" do
          it {
          	get '/templates.json'
          	expect(last_response).to be_ok
          }
#          after do
#          	puts last_response.body
#          end
        end

		describe "get '/'" do
			before do
				Tepra.config = { printer: [{name: "KING JIM SR5900P", nickname: "SR5900P@121"}, {name:"KING JIM WR1000"}] }
				get '/', params
			end

			context "without params" do
				let(:params){ {} }
				it { 
					expect(last_response).to be_ok
				}

			end

			context "with params" do
				let(:params){ {:data => 'hello,world'} }
				it { expect(last_response).to be_ok }
			end
		end


		describe "get '/Format/Print'" do
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

			context "with params printer and template" do
				let(:params){ {:UID => "12345", :NAME => "test-sample", :printer => printer, :template => template} }
				let(:printer){ "KING JIM WR1000" }
				let(:template){ "50x50" }
				it { 
					expect(Tepra).to receive(:print).with("12345,test-sample",{:printer_name => printer, :template => template}).and_return('expect')
					get '/Format/Print', params
				}
			end

			context "with params printer and without template" do
				let(:params){ {:UID => "12345", :NAME => "test-sample", :printer => printer} }
				let(:printer){ "KING JIM WR1000" }
				it { 
					expect(Tepra).to receive(:print).with("12345,test-sample",{:printer_name => printer}).and_return('expect')
					get '/Format/Print', params
				}
			end


			context "with params printer and empty template" do
				let(:params){ {:UID => "12345", :NAME => "test-sample", :printer => printer, :template => ""} }
				let(:printer){ "KING JIM WR1000" }
				it { 
					expect(Tepra).to receive(:print).with("12345,test-sample",{:printer_name => printer}).and_return('expect')
					get '/Format/Print', params
				}
			end

		end

		describe "post '/print'" do
			# before do
			# 	get '/print', params
			# end

			context "without params" do
				let(:params){ {} }
				before do
					post '/print', params
				end
				it { 
					expect(last_response).to be_redirect
				}
			end

			context "with params" do
				let(:params){ {:data => 'hello,world'} }
				before do
					allow(Tepra).to receive(:print)
					post '/print', params
				end

				it { expect(last_response).to be_redirect }
			end


			context "with params" do
				let(:params){ {:data => "hello,world"} }
				before do
					#allow(Tepra).to receive(:print).and_return('mock')
					#get '/print', params
				end
				it { 
					expect(Tepra).to receive(:print).with("hello,world",{}).and_return('expect')
					post '/print', params
				}
				#it { expect(last_response).to be_ok }
			end
		end

	end
end
