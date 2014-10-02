require 'spec_helper'

module Tepra

	describe ".spc_path", :current => true do
		it { expect(Tepra.spc_path.to_s).to include('SPC') }
	end

	describe ".spc_version" do
		before do
			Tepra.spc_path = 'C:/examples/SPC10.exe'
		end
		it { expect(Tepra.spc_version).to include('10')}
	end

	describe ".command_spc_print", :current => true do
		subject{ Tepra.command_spc_print(csvfile_path, opts)}
		let(:csvfile_path){ 'example/example-data-in.csv' }
		let(:opts){ {:template_path => '/usr/lib/ruby/gems/1.9.1/gems/tepra-0.0.1/template/default.ptc'} }
		before do
			p subject
		end
		it { expect(subject).to include(File.expand_path(csvfile_path,'.', :output_type => :mixed)) }
	end

	describe ".print_csvfile" do
		let(:csvfile_path){ 'example/example-data-in.csv' }
		before do
			Tepra.spc_path = nil
			Tepra.print_csvfile(csvfile_path)
		end
		it { expect(nil).to be_nil }			
	end

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


	describe ".init" do
		let(:pref_path){ 'dotteprarc' }
		before do
			Tepra.init(:pref_path => pref_path)
		end
		it { expect(Tepra.pref_path).to eql(pref_path)}
		it { expect(File.exists?(pref_path)).to be_truthy }

		after do
			FileUtils.rm(pref_path)
		end
	end


end
