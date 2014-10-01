require 'spec_helper'

module Tepra
	describe Base do
		describe ".spc_path" do
			it { expect(Base.spc_path.to_s).to include('SPC') }
		end

		describe ".spc_version" do
			before do
				Base.spc_path = 'C:/examples/SPC10.exe'
			end
			it { expect(Base.spc_version).to include('10')}
		end

		describe ".command_spc_print" do
			let(:csvfile_path){ 'example/example-data-in.csv' }
			before do
			end
			it { expect(Base.command_spc_print(csvfile_path)).to include(File.expand_path(csvfile_path,'.', :output_type => :windows)) }
		end

		describe ".print_csvfile",  :current => true do
			let(:csvfile_path){ 'example/example-data-in.csv' }
			before do
				Base.print_csvfile(csvfile_path)
			end
			it { expect(nil).to be_nil }			
		end

		describe ".app_root" do
			it { expect(Base.app_root).to be_an_instance_of(Pathname) }
		end

		describe ".template_dir" do
			it { expect(Base.template_dir).to be_an_instance_of(Pathname) }
		end

		describe ".template_path without arg" do
			it { expect(Base.template_path).to be_an_instance_of(Pathname) }
		end

		describe ".template_path with arg" do
			let(:template_name){ 'default' }
			before do
				template_name
			end
			it { expect(Base.template_path(template_name).to_s).to include(template_name)}
			it { expect(Base.template_path(template_name)).to be_an_instance_of(Pathname) }
		end


		describe ".init" do
			let(:pref_path){ 'dotteprarc' }
			before do
				Base.init(:pref_path => pref_path)
			end
			it { expect(Base.pref_path).to eql(pref_path)}
			it { expect(File.exists?(pref_path)).to be_truthy }

			after do
				FileUtils.rm(pref_path)
			end
		end
	end
end
