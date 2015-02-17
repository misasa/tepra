require 'tepra/command'

class Tepra::Commands::PrintCommand < Tepra::Command
	def initialize
		super 'print', 'Print a label', :set => 1, :template => Tepra.template_path, :skip_header => true, :printer => Tepra.default_printer

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
    Print a label.
    If you see timeout error, set `timeout' line on configration file `~/.teprarc' as below and raise the value.
    Default setting is 5 seconds.

    :timeout: 10

EXAMPLE
	$ echo -e 'Id,Name\\n0000-01,test' > example-data.csv
	$ tepra print example-data.csv

	$ tepra print "Id,Name\\n0000-01,test"
	$ tepra print "0000-01,test-1\\n0000-02,test-2" --no-skip-header
	$ tepra print "0000-01,test-1"

SEE ALSO
    http://dream.misasa.okayama-u.ac.jp

IMPLEMENTATION
    Copyright (c) 2015 ISEI, Okayama University
    Licensed under the same terms as Ruby

		EOF
	end

	def execute
		original_options = options.clone
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify DATA_or_DATAFILE') if args.empty?
		arg = args.shift
		if options[:dry_run]
			csvfile_path = Tepra.create_data_file(arg, options)
			command = Tepra.command_spc_print(csvfile_path, options)
			say command if options[:dry_run]
		else
			Tepra.print(arg, options)
		end
	end
end
