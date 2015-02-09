require 'spec_helper'

module Tepra

	describe ".spc_path" do
		before do
			Tepra.spc_path = nil
		end
		it { expect(Tepra.spc_path.to_s).to include('SPC') }
	end

	describe ".spc_path" do
		before do
			Tepra.spc_path = nil
			Tepra.stub(:find_spc_path).and_return(nil)
		end
		it { expect{Tepra.spc_path.to_s}.to raise_error }
	end

	describe ".spc_version" do
		before do
			Tepra.spc_path = 'C:/examples/SPC10.exe'
		end
		it { expect(Tepra.spc_version).to include('10')}
	end

	describe ".print", :current => true do
		subject{ Tepra.print(data_or_path, opts) }
		let(:data_or_path){ 'example/example-data-in.csv' }
		let(:opts){{}}
		it { expect{subject}.not_to raise_error }
	end

	describe ".printme" do
		let(:opts){ { :address => address, :port => port } }
		let(:port){ 8889 }
		let(:address){ ['0.0.0.0', '172.24.1.234'] }
		it {
			address.each do |addr|
				expect(Tepra).to receive(:print).with("#{addr}:#{port}")				
			end
			Tepra.printme(opts)
		}
	end

	describe ".ip_address" do
		it { expect{ Tepra.ip_address }.not_to raise_error }
	end

	describe ".create_data_file" do
		subject { Tepra.create_data_file(data, opts) }

		context "with nil data" do
			let(:data) { nil}
			let(:opts) { {} }
			it { expect{subject}.to raise_error }
		end

		context "with 1 column data without header" do
			let(:data) { "000-01"}
			let(:opts) { {:skip_header => true } }
			it { expect{subject}.not_to raise_error }
			it { expect(subject).to be_an_instance_of(Tempfile) }
			it { expect(File.read(subject.path)).to eql("000-01,000-01,000-01\n")}
		end

		context "with empty data" do
			let(:data) { ""}
			let(:opts) { {} }
			it { expect{subject}.to raise_error }
		end

		context "with 0 column data" do
			let(:data) { "Id\n"}
			let(:opts) { {:skip_header => true} }			
			it { expect{subject}.not_to raise_error }
			it { expect(subject).to be_an_instance_of(Tempfile) }
			it { expect(File.read(subject.path)).to eql("Id,Id,Id\n")}
		end

		context "with 1 column data" do
			let(:data) { "Id\n000-01"}
			let(:opts) { {:skip_header => true} }
			it { expect{subject}.not_to raise_error }
			it { expect(subject).to be_an_instance_of(Tempfile) }
			it { expect(File.read(subject.path)).to eql("000-01,000-01,000-01\n")}
		end

		context "with 2 column data" do
			let(:data) { "Id,Name\n000-01,test"}
			let(:opts) { {:skip_header => true} }

			it { expect{subject}.not_to raise_error }
			it { expect(subject).to be_an_instance_of(Tempfile) }
			it { expect(File.read(subject.path)).to eql("000-01,000-01,test\n")}
		end

		context "with 3 coulumn data" do
			let(:data) { "Uniq Id,Id,Name\n000-01,000-01,test"}
			let(:opts) { {:skip_header => true} }

			it { expect{subject}.not_to raise_error }
			it { expect(subject).to be_an_instance_of(Tempfile) }
			it { expect(File.read(subject.path)).to eql("000-01,000-01,test\n")}
		end

	end

	describe ".command_spc_print" do
		subject{ Tepra.command_spc_print(csvfile_path, opts)}
		let(:csvfile_path){ 'example/example-data-in.csv' }
		let(:opts){ {:template_path => '/usr/lib/ruby/gems/1.9.1/gems/tepra-0.0.1/template/default.ptc'} }
		it { expect(subject).to include(File.expand_path(csvfile_path,'.', :output_type => :mixed)) }
	end

	# describe ".print_csvfile" do
	# 	let(:csvfile_path){ 'example/example-data-in.csv' }
	# 	before do
	# 		Tepra.spc_path = nil
	# 		Tepra.print_csvfile(csvfile_path)
	# 	end
	# 	it { expect(nil).to be_nil }			
	# end

	describe ".app_root" do
		it { expect(Tepra.app_root).to be_an_instance_of(Pathname) }
	end

	describe ".template_dir" do
		it { expect(Tepra.template_dir).to be_an_instance_of(Pathname) }
	end

	describe ".template_path without arg" do
		it { expect(Tepra.template_path).to be_an_instance_of(Pathname) }
	end

	describe ".template_path with arg" do
		let(:template_name){ 'default' }
		before do
			template_name
		end
		it { expect(Tepra.template_path(template_name).to_s).to include(template_name)}
		it { expect(Tepra.template_path(template_name)).to be_an_instance_of(Pathname) }
	end


	describe ".config" do
		it { expect(Tepra.config).to be_an_instance_of(Hash) }
	end

	describe ".default_printer with config" do
		subject { Tepra.default_printer }
		let(:printer_name) { 'Example Printer' }
		before do
			Tepra.config = { printer: printer_name }
		end
		it { expect(Tepra.default_printer).to eql(printer_name) }
	end


	describe ".default_printer without config" do
		subject { Tepra.default_printer }
#		let(:printer_name) { 'Example Printer' }
		before do
			Tepra.config = {  }
		end
		it { expect(Tepra.default_printer).to eql("KING JIM SR3900P") }
	end

	describe ".default_timeout with config" do
		subject { Tepra.default_timeout }
		let(:timeout) { 50 }
		before do
			Tepra.config = { timeout: timeout }
		end
		it { expect(Tepra.default_timeout).to eql(timeout) }
		after do
			Tepra.config = nil
		end
	end


	describe ".default_timeout without config" do
		subject { Tepra.default_timeout }
		before do
			Tepra.config = nil
		end
		# before do
		# 	Tepra.class_variable_set(:default_timeout, timeout)
		# end
		it { expect(Tepra.default_timeout).not_to be_nil }
	end	
	# describe ".init" do
	# 	let(:pref_path){ 'dotteprarc' }
	# 	before do
	# 		Tepra.init(:pref_path => pref_path)
	# 	end
	# 	it { expect(Tepra.pref_path).to eql(pref_path)}
	# 	it { expect(File.exists?(pref_path)).to be_truthy }

	# 	after do
	# 		FileUtils.rm(pref_path)
	# 	end
	# end


end
