require 'optparse'
require 'tepra/user_interaction'

class Tepra::Command

	include Tepra::UserInteraction

	attr_reader :command
	attr_reader :options
	attr_accessor :defaults
	attr_accessor :program_name
	attr_accessor :summary

	def self.common_options
		@common_options ||= []
	end

	def self.add_common_option(*args, &handler)
		Tepra::Command.common_options << [args, handler]
	end

	def initialize(command, summary=nil, defaults={})
		@command = command
		@summary = summary
		@program_name = "tepra #{command}"
		@defaults = defaults
		@options = defaults.dup
		@option_groups = Hash.new { |h,k| h[k] = []}
		@parser = nil
		@when_invoked = nil
	end

	def usage
		program_name
	end

	def show_help
		parser.program_name = usage
		say parser
	end

	def invoke_with_build_args(args, build_args)
		handle_options args
		options[:build_args] = build_args
		if options[:help] then
			show_help
		else
			execute
		end
	rescue OptionParser::InvalidOption => ex
		say "ERROR: #{ex}. See '#{program_name} --help'." 		
	end

	def handle_options(args)
		@options = {}
		parser.parse!(args)
		@options[:args] = args
	end

	def add_option(*opts, &handler)
		group_name = Symbol === opts.first ? opts.shift : :options

		@option_groups[group_name] << [opts, handler]
	end

	def remove_option(name)
		@option_groups.each do |_, option_list|
			option_list.rejct! { |args,_| args.any? { |x| x =~ /^#{name}/ }}
		end
	end

	def execute
		raise "generic command has no action"
	end

	private

	def add_parser_options
		@parser.separator nil

		regular_options = @option_groups.delete :options
		configure_options "", regular_options

		@option_groups.sort_by { |n,_| n.to_s }.each do |group_name, option_list|
			@parser.separator nil
			configure_options group_name, option_list
		end
	end

	def parser
		create_option_parser if @parser.nil?
		@parser
	end

	def create_option_parser
		@parser = OptionParser.new
		add_parser_options

		@parser.separator nil
		configure_options "Common", Tepra::Command.common_options

	end

	def configure_options(header, option_list)
		return if option_list.nil? or option_list.empty?

		header = header.to_s.empty? ? '' : "#{header} "
		@parser.separator "  #{header}Options:"
		option_list.each do |args, handler|
			args.select{ |arg| arg =~ /^-/ }
			@parser.on(*args) do |value|
				handler.call(value, @options)
			end

			@parser.separator ''
		end
	end

	add_common_option('-h', '--help', 'Get help on this command') do |value, options|
		options[:help] = true
	end

	# add_common_option('-v', '--[no-]verbose','Set the verbose level of output') do |value, options|
	# 	# Set us to "really verbose" so the progress meter works
	# 	if Tepra.configuration.verbose and value then
	# 		Tepra.configuration.verbose = true
	# 	else
	# 		Tepra.configuration.verbose = value
	# 	end
	# end

	# add_common_option('-q', '--quiet', 'Silence commands') do |value, options|
	# 	Tepra.configuration.verbose = false
	# end

end

module Tepra::Commands
end
