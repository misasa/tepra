require "tepra/version"
require 'yaml'
require 'pathname'

class File
	class << self
		alias __expand_path__ expand_path
	end
	def self.expand_path(path, default_dir = '.', opts = {})
		path = __expand_path__(path, default_dir)
		if opts[:output_type]
			case opts[:output_type]
			when :windows
				path = Pathname.new(path).sub(/^\/cygdrive\/(.)/){ $1.upcase + ':' }.to_s
			when :unix
				path = Pathname.new(path).sub(/^(.):/){ '/cygdrive/' + $1.downcase }.to_s
			end
		end
		path
	end
end

module Tepra
	MIN_SPC_VERSION = 9
	MAX_SPC_VERSION = 12
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
		ext = '.tpe'
		ext = '.tpc' if spc_version =~ /^9/
		template_dir + (File.basename(template_name, '.*') + ext)
	end

	def self.get_spc_path(version = 10)
		drive = "C:/"
		if (RUBY_PLATFORM.downcase =~ /cygwin/)
			drive = "/cygdrive/c"
		end
		files = Dir.glob(Pathname.new(drive) + 'Program Files*' + 'King Jim' + '*' + "SPC#{version}*.exe")
		Pathname.new(files[0])
	end
	@@spc_path = nil
	def self.spc_path=(path)
		@@spc_path = Pathname.new(path)
	end
	def self.spc_path
		return @@spc_path if @@spc_path
		Tepra::MIN_SPC_VERSION.upto(Tepra::MAX_SPC_VERSION) do |version|
			break if @@spc_path = get_spc_path(version)
		end
		@@spc_path
	end

	def self.spc_version
		spc_path.basename('.exe').to_s.match(/SPC(.+)/)
		$1
	end

	def self.command_spc_print(csvfile_path, opts = {})
		template_path = opts[:template_path] || self.template_path
		printer_name = opts[:printer_name] || "KING JIM SR3900P"
		csvfile_path = File.expand_path(csvfile_path,'.',:output_type => :windows)
		template_path = File.expand_path(template_path,'.',:output_type => :windows)
		set = opts[:set] || 1
		command = "\"#{spc_path}\" /pt \"#{template_path},#{csvfile_path},#{set}\" \"#{printer_name}\""
	end

	def self.print_csvfile(csvfile_path, opts = {})
		command = command_spc_print(csvfile_path, opts)
		system(command)
	end

	@@default_config = {
#		'uri' => 'database.misasa.okayama-u.ac.jp/stone/'
	}

	def self.init(opts = {})
		self.pref_path = opts[:pref_path] || "~/.teprarc"
		begin
			self.config = self.read_config
		rescue
			self.config = @@default_config
			self.write_config
		end
		raise "could not find SPC*.exe" unless spc_path
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
