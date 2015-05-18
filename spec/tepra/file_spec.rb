require 'spec_helper'

module Tepra
  describe File do
  	# describe ".cygpath" do
  	# 	subject { File.cygpath(path, options) }
  	# 	let(:path) { '/cygdrive/c/example'}
  	# 	let(:options) { [:m] }
  	# 	it { expect(subject).to include('C:/') }
  	# end
  	describe ".expand_path" do
  		subject { File.expand_path(path,".", options) }
  		let(:path) { '/usr/lib/ruby/bin/tepra.csv' }
  		let(:options) { {:output_type => :mixed} }
	    #it { expect(subject).to include('C:/') }
	    it { expect(subject).to include(File.basename(path)) }	    
    end 
  end
end
