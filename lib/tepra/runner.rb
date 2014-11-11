require 'tepra'
require 'tepra/command_manager'

class Tepra::Runner
	def initialize(options = {})
  		@command_manager_class = options[:command_manager] || Tepra::CommandManager	
	end

	def run(args)
		cmd = @command_manager_class.instance
		# cmd.command_names.each do |command_name|
		# 	config_args = Tepra.configuration[command_name]
		# end
		cmd.run args
	end
end
