require 'tepra/command'

class Tepra::Commands::PrintCommand < Tepra::Command
	def initialize
		super 'print', 'Print label', :set => 1, :template => Tepra.template_path, :skip_header => true, :printer => Tepra.default_printer

		add_option('-s', '--set NUMBER',
						'Specify number of labels') do |set, options|
			options[:set] = set
		end

		add_option('-t', '--template TEMPLATEFILE',
						"Specify template path" ) do |template_path, options|
			options[:template_path] = template_path
		end

		add_option('-p', '--printer PRINTER',
						'Specify printer name (ex. "KING JIM SR3900P")') do |printer_name, options|
			options[:printer_name] = printer_name
		end

		add_option('-n', '--dry-run','Perform a trial run witn no changes mode') do |v|
			options[:dry_run] = v
		end

		add_option('-s', '--[no-]skip-header', 'Skip first line of DATA') do |v|
			options[:skip_header] = v
		end
	end

	def usage
		"#{program_name} DATA_or_DATAFILE"
	end

	def arguments
		"DATA_or_DATAFILE\tstring or datafile"
	end

	def defaults_str
		"--set 1 --printer \"#{Tepra.default_printer}\" --template #{Tepra.template_path} --skip-header"
	end

	def description
		<<-EOF
	The print command allows you to print lables.

	Examples:

		$ echo -e 'Id,Name\\n0000-01,test' > example-data.csv
		$ tepra print example-data.csv

		$ tepra print "Id,Name\\n0000-01,test"
		EOF
	end

	def execute
		original_options = options.clone
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify DATA_or_DATAFILE') if args.empty?
		arg = args.shift
		csvfile_path = Tepra.create_data_file(arg, options)

		command = Tepra.command_spc_print(csvfile_path, options)
		say command if options[:dry_run]
		system(command) unless options[:dry_run]
	end
end
