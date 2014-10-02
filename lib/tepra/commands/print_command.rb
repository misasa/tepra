require 'tepra/command'

class Tepra::Commands::PrintCommand < Tepra::Command
	def initialize
		super 'print', 'Print label'
		add_option('-l', '--list CSVFILE',
						'Use CSVFILE as input') do |csv_file, options|
			options[:list] = csv_file
		end

		add_option('-s', '--set NUMBER',
						'Specify number of labels') do |set, options|
			options[:set] = set
		end

		add_option('-t', '--template TEMPLATEFILE',
						"Specify template path (default: #{Tepra.template_path})" ) do |template_path, options|
			options[:template_path] = template_path
		end

		add_option('-p', '--printer PRINTER',
						'Specify printer name (ex. "KING JIM SR3900P")') do |printer_name, options|
			options[:printer_name] = printer_name
		end

		add_option('-n', '--dry-run','Perform a trial run witn no changes mode') do |v|
			options[:dry_run] = v
		end
	end

	def execute
		original_options = options.clone

		args = options.delete(:args)
		csvfile_path = options[:list]
		csvfile_path = args.shift unless csvfile_path
		raise OptionParser::InvalidOption.new('specify CSVFILE') unless csvfile_path
		command = Tepra.command_spc_print(csvfile_path, options)
		say command if options[:dry_run]
		system(command) unless options[:dry_run]
	end
end
