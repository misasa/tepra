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
  	@pref_path = nil
	def self.pref_path=(pref_path) @pref_path = pref_path end
	def self.pref_path
		@pref_path ||= "~/.teprarc"
	end

	@config = nil
	def self.config=(config) @config = config end
	def self.config
		load_config unless @config
		@config
	end

	@default_printer = "KING JIM SR3900P"
	@default_port = 8889
    @default_template = 'default'
	@default_timeout = 5
	DEFAULT_CONFIG = {:printer => @default_printer, :port => @default_port, :timeout => @default_timeout }
	def self.load_config
#		self.pref_path = opts[:pref_path] || "~/.teprarc"
		begin
			self.config = self.read_config
		rescue
			self.config = DEFAULT_CONFIG
			self.write_config
		end		
		#raise "could not find SPC*.exe" unless spc_path
  	end

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
		config = YAML.load(File.read(File.expand_path(pref_path)))
	end

	def self.write_config
		config = Hash.new
		config = self.config
		STDERR.puts("writing |#{File.expand_path(self.pref_path)}|")
		open(File.expand_path(self.pref_path), "w") do |f|
			YAML.dump(config, f)
		end
	end  	

	def self.app_root
		path = Pathname.new(File.dirname(File.expand_path(__FILE__)) + '/..')
		path.cleanpath
	end

	def self.template_dir
		app_root + 'template'
	end

  	def self.default_printer
  		if !printers.empty?
          printers[0]
  		else
  			@default_printer
  		end
  	end

    # def self.printers
    #   return [] unless config[:printer]
    #   if config[:printer].instance_of?(String)
    #     [config[:printer]]
    #   elsif config[:printer].instance_of?(Hash)
    #   	config[:printer][:name]
    #   elsif config[:printer].instance_of?(Array) && config[:printer][0].instance_of?(Hash)
    #     config[:printer].map{|h| h[:name]}
    #   else
    #     config[:printer]
    #   end
    # end

    def self.printers
      printer_names
    end

    def self.printer_names
      printer_hashs.map{|h| h[:name] }
    end

    def self.printer_hashs
      #return [] unless config.has_key?(:printer)
      return [] unless config[:printer]
      case config[:printer]
        when String
          [{name: config[:printer]}]
        when Hash
          [config[:printer]]
        when Array
      	if config[:printer][0].instance_of?(String)
      	  config[:printer].map{|name| {name: name} }
      	else
      	  config[:printer]
      	end
      end
    end
    
  	def self.default_port
  		if config.has_key?(:port)
  		  	config[:port]
  		else
  			@default_port
  		end
  	end

    def self.default_template(printer = nil)
      template = @default_template
      if config.has_key?(:template)
        template = config[:template]
      end
      if printer
      	index = self.printer_names.index(printer)
      	template = self.printer_hashs[index][:template] if index && self.printer_hashs[index][:template]
      end
      template
    end
    
  	def self.default_timeout
  		if config.has_key?(:timeout)
  			config[:timeout]
  		else
  			@default_timeout
  		end
  	end

	def self.template_path(template_name = self.default_template)
		ext = '.tpe'
		ext = '.tpc' if spc_version =~ /^9/
		template_dir + (File.basename(template_name, '.*') + ext)
	end

    def self.templates(opts = {})
      ext = '.tpe'
      ext = '.tpc' if spc_version =~ /^9/
      pattern = '*' + ext
      ts = []
      files = Dir.glob(template_dir + pattern)
      ts = files.map{|file| File.basename(file, ".*")}
      ts = ts - opts[:omit] if opts[:omit]
      ts
    end

    def self.template_hashs(opts = {})
    	templates(opts).map{|template| {name: template }}
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

	@spc_path = nil
	def self.spc_path=(path)
		if path
			@spc_path = Pathname.new(path)
		else
			@spc_path = nil
		end
	end

	def self.find_spc_path
		Tepra::MAX_SPC_VERSION.downto(Tepra::MIN_SPC_VERSION) do |version|
			return @spc_path if @spc_path = get_spc_path(version)
		end		
	end

	def self.spc_path
		return @spc_path if @spc_path
		@spc_path = find_spc_path
		raise RuntimeError.new("could not find SPC*.exe") unless @spc_path
		@spc_path
	end

	def self.spc_version
		spc_path.basename('.exe').to_s.match(/SPC(.+)/)
		$1
	end

	def self.ip_address
		re2 = %r/(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/
		re = %r/IPv4\sAddress/
		#re = %r/IP/o
		command = 'cmd /c "chcp 437 & ipconfig/all"'
		lines = IO.popen(command){|fd| 
			fd.readlines.map{|str|
				str.force_encoding('UTF-8')
				str = str.encode("UTF-16BE", "UTF-8", :invalid => :replace, :undef => :replace, :replace => '?').encode("UTF-8")
			}
		}
		candidates = lines.select{|line| line =~ re}
		address = []
		candidates.each do |line|
			if line =~ re2
				address << Regexp.last_match[1]
			end
		end
		address
	end

	def self.printme(opts = {})
		port = opts[:port] || default_port
		address = opts[:address] || ip_address
		address.each do |addr|
			addr_with_port = "#{addr}:#{port}"
			self.print(addr_with_port)
		end
	end

	def self.print(data_or_path, opts = {})
		timeout = (opts[:timeout] || self.default_timeout).to_i
		csvfile_path = Tepra.create_data_file(data_or_path, opts)
		cmd = Tepra.command_spc_print(csvfile_path, opts)

		start = Time.now
		pid = Process::spawn(cmd)
		while true do
			sleep 1
			dtime = Time.now - start
			if dtime > timeout
				begin
					Process.kill("KILL",pid)
					Process.wait(pid)
				rescue => ex
				end
				raise Tepra::TimeoutError.new("print job was timed out")
			end
			break if Process.waitpid(pid, Process::WNOHANG)		
		end

	end

	def self.execute_command(cmd, opts = {})
		timeout = opts[:timeout] || 10
		puts "#{cmd} executing..."
		start = Time.now
		pid = Process::spawn(cmd)
		while true do
			sleep 1
			dtime = Time.now - start
			if dtime > timeout
				Process.kill("KILL",pid)
				Process.wait(pid)
				raise "Timeout"
			end
			break if Process.waitpid(pid, Process::WNOHANG)		
		end
	end


	def self.create_data_file(data_or_path, opts = {})
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
		temp
	end

    def self.select_template(opts = {})
      path = self.template_path
      p "default #{path}"
      if opts[:printer_name]
      	index = self.printer_names.index(opts[:printer_name])
      	path = self.template_path(self.printer_hashs[index][:template]) if index && self.printer_hashs[index][:template]
        p "opts[:printer_name]:#{opts[:printer_name]} path:#{path}"
      end
      if opts[:template]
        path = self.template_path(opts[:template])
        p "opts[:template]:#{opts[:template]} path:#{path}"
      end
      if opts[:template_path]
        path = opts[:template_path]
        p "opts[:template_path]:#{opts[:template_path]} path:#{path}"
      end
      path
    end

	def self.command_spc_print(csvfile_path, opts = {})
		#template_path = opts[:template_path] || ( opts[:template] ? self.template_path(opts[:template]) : self.template_path )
		template_path = select_template(opts)
		printer_name = opts[:printer_name] || self.default_printer
		csvfile_path = File.expand_path(csvfile_path,'.',:output_type => :mixed)
		template_path = File.expand_path(template_path,'.',:output_type => :mixed)
		set = opts[:set] || 1
		command = "\"#{spc_path}\" /pt \"#{template_path},#{csvfile_path},#{set}\" \"#{printer_name}\""
	end

	def self.print_csvfile(csvfile_path, opts = {})
		command = command_spc_print(csvfile_path, opts)
		system(command)
	end


  #end
  class TimeoutError < StandardError
  	def initialize(message)
  		@message = message
  	end
  end

end
