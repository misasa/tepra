require 'tepra/command'

class Tepra::Commands::PrintCommand < Tepra::Command
	def initialize
		super 'print', 'Print label'
		add_option('-l', '--list CSVFILE',
						'Use CSVFILE as input') do |csv_file, options|
			options[:list] = csv_file
		end
	end

	def execute
		csvfile_path = options[:list]
		csvfile_path = options[:args].shift unless csvfile_path
		raise OptionParser::InvalidOption.new('specify CSVFILE') unless csvfile_path
		command = Tepra::Base.command_spc_print(csvfile_path, options)
		system(command)
	end
end
