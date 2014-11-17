require 'spec_helper'
require 'tepra/commands/server_command'
module Tepra::Commands
	describe ServerCommand do
		describe "#handle_options" do
			#subject { cmd.handle_options args}
			let(:cmd){ ServerCommand.new }
			let(:args){ [] }
			before do
				cmd.handle_options args
			end
			it { expect(cmd.options).to include(:port => Tepra::default_port) }
		end

		describe "#execute" do
			subject { cmd.execute }
			let(:cmd) { ServerCommand.new }
			before do
				cmd.stub(:options).and_return(options)
			end

			context "without option", :current => true do
				let(:options) { {:port => port } }
				let(:port){ 8889 }
				before do
					Tepra.config = { }
				end
				it { 
					expect(Tepra).to receive(:printme).with({:port => port})
					expect(Tepra::Server).to receive(:run!).with({:port => port})
					cmd.execute
				}
			end

		end		
	end
end
