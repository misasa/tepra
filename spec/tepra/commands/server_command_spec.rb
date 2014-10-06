require 'spec_helper'
require 'tepra/commands/server_command'
module Tepra::Commands
	describe ServerCommand do
		describe "#execute" do
			subject { cmd.execute }
			let(:cmd) { ServerCommand.new }
			before do
				cmd.stub(:options).and_return(options)
			end

			context "without option", :current => true do
				let(:options) { {} }
				before do
					Tepra.config = { }
				end
				it { expect{subject}.not_to raise_error }
			end

		end		
	end
end
