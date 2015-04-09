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
    	opts.define_head "Usage: tepra [main-option] [sub-command [sub-option]]"
		opts.separator ""
		opts.separator "Summary:"
		opts.separator "    Print QR-code to King Jim's Tepra from command line or via REST
    interface.  For latter, invoke with server mode."
		opts.separator ""
		opts.separator "Description:"
		opts.separator "    This gem is part of Medusa and supports Ruby for Windows only
    (http://rubyinstaller.org/downloads/).  Install this gem and
    update by following commands."
		opts.separator ""
		opts.separator "    DOS> gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems/"
		opts.separator "    DOS> gem install tepra"
		opts.separator "    DOS> gem update tepra"
		opts.separator ""
		opts.separator "    Setup this computer and make sure you can print something from
    `SPC 10'.  Identify name of the printer on `SPC 10' such as `KING
    JIM SR5900P-NW'.  Put it to a configuration file `~/.teprarc'.  A
    line should look like below."
		opts.separator "    :printer: KING JIM SR5900P-NW"
		opts.separator ""
		opts.separator "    Issue following to have a test label."
		opts.separator "    DOS> tepra print ''20110119154409-142-363,Heaven''"
		opts.separator ""
		opts.separator "Sub-command:"
		opts.separator "    print   :  print QR-code"
		opts.separator "    server  :  launch server to accept queue via REST interface"
		opts.separator ""
    	opts.separator "Examples:"
		opts.separator "    DOS> tepra print ''20110119154409-142-363,Heaven''"
		opts.separator "    DOS> tepra server"
		opts.separator ""
		opts.separator "See Also"
		opts.separator "    tepra-duplicate --help"
		opts.separator "    orochi-label --help"
		opts.separator "    http://dream.misasa.okayama-u.ac.jp"
		opts.separator ""
		opts.separator "Implementation:"
		opts.separator "    Copyright (c) 2015 ISEI, Okayama University"
		opts.separator "    Licensed under the same terms as Ruby"
    	opts.separator ""
        # opts.separator "  #{BUILTIN_COMMANDS.join(', ')}"
    #			opts.separator "Commands:"
    #			opts.separator ""	
        # opts.separator "  tepra"
    	# opts.separator "  tepra print csvfile"
        # opts.separator "  tepra server"
		# opts.separator "  tepra [command] --help"
    	opts.separator "Main-option:"


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

