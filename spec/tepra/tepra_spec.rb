require 'spec_helper'

module Tepra

	describe ".spc_path" do
		subject{ Tepra.spc_path }
		before do
		  Tepra.spc_path = nil
		end
		it { 
			expect(Tepra).to receive(:find_spc_path).and_return('SPC_PATH')
			subject
			#expect(Tepra.spc_path.to_s).to include('SPC') 
		}
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

    describe ".default_template" do
      subject { Tepra.default_template }
      it { expect(subject).to eql('default')}
      context "with template in config" do
        before do
          Tepra.config = { template: template }
        end  
        let(:template){ '50x80' }
        it { expect(subject).to eql('50x80')}
      end
      after do
        Tepra.config = nil
      end
    end
    
#	describe ".print", :current => true do
#	  subject{ Tepra.print(data_or_path, opts) }
#		let(:data_or_path){ 'hello,world' }
#		let(:opts){{ printer_name: 'KING JIM WR1000'}}
#       before do
#          Tepra.config = { template: '50x80'}
#        end
#		it { expect{subject}.not_to raise_error }
#        after do
#          Tepra.config = nil
#        end
#	end

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
		subject {Tepra.ip_address }
		before do
			puts subject
		end
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
		let(:opts){ {} }
		it { expect(subject).to include(File.expand_path(csvfile_path,'.', :output_type => :mixed)) }
		context "with valid template_path" do
			let(:opts){ {:template_path => '50x50ptc'} }
			it { expect(subject).to include(File.expand_path(csvfile_path,'.', :output_type => :mixed)) }
		end
		context "without template_path" do
			let(:opts){ {:printer_name => "KING JIM SR5900P"} }
			it { expect(subject).to include(File.expand_path(csvfile_path,'.', :output_type => :mixed)) }
		end

		after do
		  puts subject
		end
	end

#	describe ".print_csvfile" do
#	 	let(:csvfile_path){ 'example/example-data-in.csv' }
#	 	before do
#	 		Tepra.spc_path = nil
#	 		Tepra.print_csvfile(csvfile_path)
#	 	end
#	 	it { expect(nil).to be_nil }			
#	end

#    describe ".print" do
#      subject { Tepra.print(data, opts) }
#      let(:data){ "hello,world" }
#      let(:opts){ {} }
#      it { expect{subject}.not_to raise_error}
#      context "with printer_name" do
#        let(:opts){ {:printer_name => "KING JIM WR1000"} }
#        it { expect{subject}.not_to raise_error }
#      end
#      context "with printer_name and template" do
#        let(:opts){ {:printer_name => "KING JIM WR1000", :template => '50x80'} }
#        it { expect{subject}.not_to raise_error }
#      end
#    end
    
	describe ".app_root" do
		it { expect(Tepra.app_root).to be_an_instance_of(Pathname) }
	end

	describe ".template_dir" do
		it { expect(Tepra.template_dir).to be_an_instance_of(Pathname) }
	end

    describe ".select_template" do
      subject {Tepra.select_template(opts)}
      context "without opts" do
      	it {expect(Tepra.select_template.to_s).to include(Tepra.default_template) }
      end

      context "with opts[:template_path]" do
      	let(:opts){ {template_path:template_path} }
      	let(:template_path){"/path/to/template/example.tpe"}
      	it {expect(subject.to_s).to be_eql(template_path) }
      end

      context "with opts[:template]" do
      	let(:opts){ {template:template} }
      	let(:template){"50x67"}
      	it {expect(subject.to_s).to include(template) }
      end

      context "with opts[:printer_name]" do
      	before do
      	  Tepra.config = {template: default_template, printer: [{name: printer_1, template: template_1},{name: printer_2, template: template_2},{name: printer_3}]}
      	end
      	#let(:opts){ {printer_name: printer_1} }
        let(:printer_1){"KING JIM WR1000"}
      	let(:template_1){"50x80"}
        let(:printer_2){"KING JIM SR5900P"}
      	let(:template_2){"12x12"}
        let(:printer_3){"KING JIM SR3900P"}
        let(:default_template){"12x20"}   	
      	it {expect(Tepra.select_template({printer_name: printer_1}).to_s).to include(template_1) }
      	it {expect(Tepra.select_template({printer_name: printer_2}).to_s).to include(template_2) }
      	it {expect(Tepra.select_template({printer_name: printer_3}).to_s).to include(default_template) }
      	after do
      		Tepra.config = nil
      	end
      end


    end


	describe ".template_path without arg" do
		it { expect(Tepra.template_path).to be_an_instance_of(Pathname) }
	end

	describe ".template_path with arg" do
		subject { Tepra.template_path(template_name) }
		let(:template_name){ 'default' }
		before do
			template_name
		end
		it { expect(subject.to_s).to include(template_name)}
		it { expect(subject).to be_an_instance_of(Pathname) }
	end

    describe ".printers" do
      subject { Tepra.printers }
      let(:printer_1){ "KING JIM SR5900P" }
      let(:printer_2){ "KING JIM WR1000" }
      context "without printer" do
        before do
          Tepra.config = {}
        end
        it { expect(subject).to be_empty }
      end
      context "with empty printer" do
        before do
          Tepra.config = { printer: nil }
        end
        it { expect(subject).to be_empty }
      end
      context "with single printer" do
        before do
          Tepra.config = { printer: printer_1}
        end
        it { expect(subject).not_to be_empty }
        it { expect(subject).to be_eql([printer_1]) }        
      end
      context "with array" do
        before do
          Tepra.config = { printer: [printer_1, printer_2]}
        end
        it { expect(subject).to be_eql([printer_1, printer_2])}
      end
      context "with single hash" do
      	before do
      	  Tepra.config = { printer: {name: printer_1}}
      	end
      	it { expect(subject).to be_eql([printer_1])}
      end
      context "with hash array" do
      	before do
      	  Tepra.config = { printer: [{name: printer_1}, {name: printer_2}]}
      	end
      	it { expect(subject).to be_eql([printer_1, printer_2])}
      end
    end


    describe ".printer_hashs" do
      subject { Tepra.printer_hashs }
      let(:printer_1){ "KING JIM SR5900P" }
      let(:printer_2){ "KING JIM WR1000" }
      let(:printer_3){ {name: "KING SR5900P"} }
      let(:printer_4){ {name: "KING JIM WR1000"} }

      context "without printer" do
        before do
          Tepra.config = {}
        end
        it { expect(subject).to be_empty }
      end
      context "with empty printer" do
        before do
          Tepra.config = { printer: nil }
        end
        it { expect(subject).to be_empty }
      end
      context "with single printer" do
        before do
          Tepra.config = { printer: printer_1}
        end
        it { expect(subject).not_to be_empty }
        it { expect(subject).to be_eql([{name: printer_1}]) }        
      end
      context "with array" do
        before do
          Tepra.config = { printer: [{name: printer_1}, {name: printer_2}]}
        end
        it { expect(subject).to be_eql([{name: printer_1}, {name: printer_2}])}
      end
      context "with single hash" do
      	before do
      	  Tepra.config = { printer: printer_3 }
      	end
      	it { expect(subject).to be_eql([printer_3])}
      end
      context "with hash array" do
      	before do
      	  Tepra.config = { printer: [printer_3, printer_4]}
      	end
      	it { expect(subject).to be_eql([printer_3, printer_4])}
      end
    end

    describe ".templates" do
      subject { Tepra.templates }
      it { expect(subject).not_to be_empty }
      it { expect(subject).to include('default') }      
      context "with omit option" do
      	subject { Tepra.templates(opts) }
        let(:opts){ {:omit => ['default'] } }
      	it { expect(subject).not_to be_empty }
      	it { expect(subject).not_to include('default') }      	
      end
    end

	describe ".config" do
		it { expect(Tepra.config).to be_an_instance_of(Hash) }
	end

	describe ".default_printer with config" do
		subject { Tepra.default_printer }
		let(:printer_name) { 'Example Printer' }
        let(:printer_2) { 'Sub Printer'}
        context "with single printer" do
		  before do
			Tepra.config = { printer: printer_name }
		  end
		  it { expect(subject).to eql(printer_name) }
        end
        context "with multiple printers" do
          before do
            Tepra.config = { printer: [printer_name, printer_2]}
          end
          it { expect(subject).to eql(printer_name)}
        end
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
