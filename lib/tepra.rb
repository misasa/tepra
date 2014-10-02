require "tepra/version"
require "tepra/file"
require "tepra/csv"
require 'yaml'
require 'pathname'
require 'tempfile'

module Tepra
	APP_ROOT = File.dirname File.expand_path(__FILE__)
	MIN_SPC_VERSION = 9
	MAX_SPC_VERSION = 12
  # Your code goes here...
  #class Base
  	@@pref_path = nil
	def self.pref_path=(pref) @@pref_path = pref end
	def self.pref_path() @@pref_path end
	@@config = nil
	def self.config=(config) @@config = config end
	def self.config() @@config end

	def self.configuration
		@configuraion ||= Tepra::ConfigFile.new []
	end

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
		return if files.empty?
		Pathname.new(files[0])
	end
	@@spc_path = nil
	def self.spc_path=(path)
		if path
			@@spc_path = Pathname.new(path)
		else
			@@spc_path = nil
		end
	end
	def self.spc_path
		return @@spc_path if @@spc_path
		Tepra::MAX_SPC_VERSION.downto(Tepra::MIN_SPC_VERSION) do |version|
			break if @@spc_path = get_spc_path(version)
		end
		@@spc_path
	end

	def self.spc_version
		spc_path.basename('.exe').to_s.match(/SPC(.+)/)
		$1
	end

	def self.create_data_file(data_or_path, opts = {})
		p opts
		raise RuntimeError.new("Invalid DATA_or_DATAFILE") unless data_or_path
		raise RuntimeError.new("Invalid DATA_or_DATAFILE") if data_or_path.empty?
		#headers = opts[:skip_header]

		if File.exists?(data_or_path)		
			data = File.read(data_or_path)
		else
			data = data_or_path
		end

		temp = Tempfile.new(['tepra','.csv'])
		csvfile_path =  temp.path

		tcsv = CSV.new(data)
		table = tcsv.read
		table.shift if table.size > 1 && opts[:skip_header]
		CSV.open(csvfile_path, "wb") do |output|
			table.each do |row|
				case row.size
				when 1
					output << [row[0], row[0], row[0]]
				when 2
					output << [row[0], row[0], row[1]]
				else
					output << row
				end
			end
		end
		temp.close
		p File.read(temp.path)
		temp
	end

	def self.command_spc_print(csvfile_path, opts = {})
		template_path = opts[:template_path] || self.template_path
		printer_name = opts[:printer_name] || "KING JIM SR3900P"
		csvfile_path = File.expand_path(csvfile_path,'.',:output_type => :mixed)
		template_path = File.expand_path(template_path,'.',:output_type => :mixed)
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

  	def self.default_printer
  		@default_printer ||= "KING JIM SR3900P"
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

  #end

end