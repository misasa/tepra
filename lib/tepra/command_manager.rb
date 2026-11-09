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
			opts.banner = "tepra: command-line utility for King Jim TEPRA printers"
			opts.define_head "Usage: tepra [options] [command [command options]]"
			opts.separator ""
			opts.separator <<~HELP
			  Print QR code labels from the command line or through the REST API.
			  Running tepra without a subcommand starts the web server.

			  Setup:
			      Printing requires Windows and King Jim's SPC software.
			      Install or update the gem with these commands:

			      CMD> gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems/
			      CMD> gem install tepra
			      CMD> gem update tepra

			      Print a test label from SPC first. In ~/.teprarc, use the exact printer
			      name shown in Windows under Control Panel > Devices and Printers:

			      :printer: KING JIM SR5900P-NW

			      To configure multiple printers, list them under :printer. Use :nickname
			      for the name shown in the web interface and :template for the printer's
			      default template. For example:

			      :printer:
			        - :name: KING JIM SR3900P
			          :nickname: Lab printer
			          :template: 18x50
			        - :name: KING JIM WR1000
			          :nickname: Office printer
			          :template: 50x80
			      :template: 18x18

			      If print jobs time out, increase :timeout in ~/.teprarc.
			      The default timeout is 5 seconds.

			      :timeout: 10

			  Subcommands:
			      print    Print a label from an ID and name or a CSV file.
			      server   Start the web server for browser and REST API printing.
			               The default address is http://localhost:8889/.

			  Examples:
			      CMD> tepra print "20110119154409-142-363,Heaven"
			      CMD> tepra server
			      curl 'http://localhost:8889/Format/Print?UID=12345678&NAME=MyGreatStone'
			      curl 'http://localhost:8889/Format/Print?UID=12345678&NAME=MyGreatStone&printer=KING%20JIM%20WR1000&template=18x18'

			  See also:
			      tepra print --help
			      tepra server --help
			      tepra-duplicate --help
			      orochi-label --help

			  Copyright (c) 2015-2020 Okayama University
			  Licensed under the GNU General Public License, version 3 or later.

			  Options:
			HELP

			opts.on_tail("-?", "--help", "Show help") do |v|
				@options[:help] = v
			end

			opts.on_tail("-v", "--[no-]verbose", "Enable verbose output") do |v|
				@options[:verbose] = v
			end

			opts.on_tail("-V", "--version", "Show the version number") do |v|
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
