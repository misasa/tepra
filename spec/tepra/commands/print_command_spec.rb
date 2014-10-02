require 'spec_helper'
require 'tepra/commands/print_command'
module Tepra::Commands
	describe PrintCommand do
		describe "#handle_options" do
			#subject { cmd.handle_options args}
			let(:cmd){ PrintCommand.new }
			let(:args){ ["-n", "--printer", printer_name, "--template", template_path, "example/example-data-in.csv"] }
			let(:printer_name){ 'Example Printer' }
			let(:template_path){ 'example/template.tpc'}
			before do
				cmd.handle_options args
			end
			it { expect(cmd.options).to include(:printer_name => printer_name) }
			it { expect(cmd.options).to include(:dry_run => true) }
			it { expect(cmd.options).to include(:template_path => template_path) }			
		end

		describe "#execute" do
			let(:cmd) { PrintCommand.new }
			let(:options) { {:list => csvfile_path, :dry_run => true, :set => 4 } }
			let(:csvfile_path) { 'example/example-data-in.csv' }
			before do
				cmd.stub(:options).and_return(options)
				cmd.execute
			end
			it { expect(cmd.options).to include(:list => csvfile_path) }
		end
	end
end
