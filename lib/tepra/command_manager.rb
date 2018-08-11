require 'tepra/command'
require 'tepra/user_interaction'

class Tepra::CommandManager
	include Tepra::UserInteraction


	attr_accessor :program_name
  BUILTIN_COMMANDS = [
  		:print,
      :server,
  		:help,
  ]
  def self.instance
  	@command_manager ||= new
  end

  def instance
  	self
  end

	def initialize
		@commands = {}
		@options = {}
		@program_name = "tepra"
		BUILTIN_COMMANDS.each do |name|
			register_command name
		end
	end

	def register_command(command, obj=false)
		@commands[command] = obj
	end

	def command_names
		@commands.keys.collect {|key| key.to_s}.sort
	end

	def run(args, build_args=nil)
		process_args(args, build_args)
	end

	def parse_options

	end

	def options
	 	@options || {}
	end

	def opts
		@opts ||= OptionParser.new do |opts|
			#@options = {}
    	opts.banner = "tepra: command-line utility for Tepra"
    	opts.define_head "Usage: tepra [option] [sub-command [sub-option]]"
		opts.separator ""
		opts.separator "Summary:"
		opts.separator "    Print QR-code to King Jim's Tepra via command line or REST interface."
		opts.separator "    The program works as label-print server.  When the program is launched"
		opts.separator "    without argument, it runs as web server."
		opts.separator ""
		opts.separator "Description:"
		opts.separator "    This gem is not part of Medusa and supports Ruby for Windows only
    (http://rubyinstaller.org/downloads/).  Install this gem and
    update by following commands."
		opts.separator ""
		opts.separator "    CMD> gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems/"
		opts.separator "    CMD> gem install tepra"
		opts.separator "    CMD> gem update tepra"
		opts.separator ""
		opts.separator "    Setup this computer and make sure you can print something from
    `SPC 10'.  Identify name of the printer on `SPC 10' such as `KING
    JIM SR5900P-NW'.  Technically the name is one listed on Windows'
    Control Panel.  Put it to a configuration  file `~/.teprarc'.
    A line should look like below."
		opts.separator "    :printer: KING JIM SR5900P-NW"
		opts.separator ""
		opts.separator "    When you want to control several printers by one
    host, list the printers to see a printer list in the
    tepra server.  An element :name: corresponds to name that
    is the listed on Windows' Control Panel.  An element :nickname:
    is an alias that is shown on popup menu on tepra server.
    An example of a configuration file `~/.teprarc' is shown below."
		opts.separator "    :printer:"
		opts.separator "      - :name: KING JIM SR3900P"
		opts.separator "        :nickname: SR3900P@126"
		opts.separator "        :template: 18x50"
		opts.separator "      - :name: KING JIM SR5900P-A17F52 # 2016-09-01 (keep awake) on shelf"
		opts.separator "        :nickname: SR5900P@126"
		opts.separator "      - :name: KING JIM SR5900P-A1C8F9 # 2017-09-06 (keep awake) SIMS ims-5f"
		opts.separator "        :nickname: SR5900P@125"
		opts.separator "      - :name: KING JIM SR5900P-A1C8FA # 2017-09-06 (keep awake) SIMS ims-1270"
		opts.separator "        :nickname: SR5900P@121"
		opts.separator "      - :name: KING JIM WR1000"
		opts.separator "        :nickname: WR1000@126"
		opts.separator "        :template: 50x80"
		opts.separator "      - :name: KING JIM SR5900P-A1C8F8 # 2017-09-06 (keep awake) with Surface-2016"
		opts.separator "        :nickname: SR5900P@127"
		opts.separator "      - :name: KING JIM SR5900P-A123E5 # 2015-09-01 (auto power off) on TK's office"
		opts.separator "        :nickname: SR5900P@201"
		opts.separator "      - :name: KING JIM SR5900P-A0EA7E # 2015-09-01 (auto power off) on Tsutom's office"
		opts.separator "        :nickname: SR5900P@212"
		opts.separator "      # - :name: KING JIM SR5900P-A0EA7A # 2015-09-01 (auto power off)"
		opts.separator "    :template: 18x18"
		opts.separator ""
        opts.separator "    If you see timeout error, set `timeout' line on
    configuration file `~/.teprarc' as below and raise the value.
    Default setting is 5 seconds."
  		opts.separator "    :timeout: 10"
		opts.separator ""
		opts.separator "    Issue following to have a test label."
		opts.separator "    CMD> tepra print ''20110119154409-142-363,Heaven''"
        opts.separator ""
		opts.separator "    To print label from web browser, launch this command as server."
		opts.separator "    Without sub-command, this will startup as server mode.  Then access to"
		opts.separator "    the server with typical URL `http://localhost:8889/'."
        opts.separator ""
		opts.separator "Sub-command:"
        opts.separator "    unspecified :  `server' is set"
		opts.separator "    server      :  launch server to accept queue via REST interface as such below"
		opts.separator "                :  http://localhost:8889/Format/Print?UID=12345678&NAME=MyGreatStone"
		opts.separator "                :  http://localhost:8889/Format/Print?UID=12345678&NAME=MyGreatStone&printer=KING%20JIM%20WR1000%template=18x18"
		opts.separator "    print       :  print QR-code with number and name"
		opts.separator ""
    	opts.separator "Examples:"
		opts.separator "    CMD> tepra print ''20110119154409-142-363,Heaven''"
		opts.separator ""
		opts.separator "    CMD> tepra"
		opts.separator "    CMD> tepra server"
		opts.separator "    darwin$ open http://localhost:8889/"
		opts.separator "    darwin$ curl http://localhost:8889/Format/Print?UID=12345678&NAME=MyGreatStone"
		opts.separator "    darwin$ curl http://localhost:8889/Format/Print?UID=12345678&NAME=MyGreatStone&printer=KING%20JIM%20WR1000%template=18x18"
		opts.separator ""
		opts.separator "See Also"
		opts.separator "    tepra-duplicate --help"
		opts.separator "    orochi-label --help"
		opts.separator "    http://dream.misasa.okayama-u.ac.jp"
		opts.separator ""
		opts.separator "Implementation:"
		opts.separator "    Copyright (C) 2015-2018 Okayama University"
		opts.separator "    License GPLv3+: GNU GPL version 3 or later"
    	opts.separator ""
        # opts.separator "  #{BUILTIN_COMMANDS.join(', ')}"
        # opts.separator "Commands:"
        # opts.separator ""
        # opts.separator "  tepra"
    	# opts.separator "  tepra print csvfile"
        # opts.separator "  tepra server"
		# opts.separator "  tepra [command] --help"
    	opts.separator "option:"


    	opts.on_tail("-?", "--help", "Show this message") do |v|
    		@options[:help] = v
    	end

    	opts.on_tail("-v", "--[no-]verbose", "Run verbosely") do |v|
    		@options[:verbose] = v
    	end

    	opts.on_tail("-V", "--version", "Show version") do |v|
    		@options[:version] = v
    	end
  	end
	end

	def usage
		"tepra"
	end

	def show_help
		opts.program_name = usage
		say opts
	end

	def show_version
		say Tepra::VERSION
	end


  def process_args(args, build_args=nil)
  		opts.order!(args)

 		if options[:help] then
			show_help
      exit
		elsif options[:version] then
			show_version
      exit
		elsif args.empty?
      cmd_name = 'server'
			#show_help
		else
			cmd_name = args.shift.downcase
    end
		cmd = find_command cmd_name
		cmd.invoke_with_build_args args, build_args
	rescue OptionParser::InvalidOption => ex
		say "ERROR: #{ex}. See '#{program_name} --help'."
  end

  def process_args_org(args, build_args=nil)
  		if args.empty? then
  			say Tepra::Command::HELP
  			terminate_interaction 1
  		end

  		case args.first
  		when '-h', '--help' then
  			say Tepra::Command::HELP
  			terminate_interaction 0
  		when '-v', '--version' then
  			say Tepra::version
  			terminate_interaction 0
  		when /^-/ then
  			alert_error "Invalid option: #{args.first}. See 'tepra --help'."
  			terminate_interaction 1
  		else
  			cmd_name = args.first.downcase
  			cmd = find_command cmd_name
  			#cmd.invoke_with_build_args args, build_args
  		end
  	end
  	def [](command_name)
  		command_name = command_name.intern
  		return nil if @commands[command_name].nil?
  		@commands[command_name] ||= load_and_instantiate(command_name)
  	end

  	def find_command(cmd_name)
  		#len = cmd_name.length
  		#found = command_names.select{ |name| cmd_name == name[0, len] }
  		exact = command_names.find{ |name| name == cmd_name }
  		self[exact]
  	end

  	private
  	def load_and_instantiate(command_name)
  		command_name = command_name.to_s
   		const_name = command_name.capitalize.gsub(/_(.)/) { $1.upcase } << "Command"
 		require "tepra/commands/#{command_name}_command"
 	  	Tepra::Commands.const_get(const_name).new
  	end
end
