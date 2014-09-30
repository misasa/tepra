require "tepra/version"
require 'yaml'
require 'pathname'

module Tepra
  # Your code goes here...
  class Base
  	@@pref_path = nil
	def self.pref_path=(pref) @@pref_path = pref end
	def self.pref_path() @@pref_path end
	@@config = nil
	def self.config=(config) @@config = config end
	def self.config() @@config end

	def self.app_root
		path = Pathname.new(File.dirname(File.expand_path(__FILE__)) + '/..')
		path.cleanpath
	end

	def self.template_dir
		app_root + 'template'
	end

	def self.template_path(template_name = 'default')
		template_dir + (template_name + '.tpe')
	end

	@@default_config = {
		'uri' => 'database.misasa.okayama-u.ac.jp/stone/'
	}


	def self.init(opts = {})
		self.pref_path = opts[:pref_path] || "~/.teprarc"
		begin
			self.config = self.read_config
		rescue
			self.config = @@default_config
			self.write_config
		end

  	end

	def self.read_config
		config = YAML.load(File.read(File.expand_path(self.pref_path)))
	end

	def self.write_config
		config = Hash.new
		config = self.config
		STDERR.puts("writing |#{File.expand_path(self.pref_path)}|")
		open(File.expand_path(self.pref_path), "w") do |f|
			YAML.dump(config, f)
		end
	end  	


  end
end
