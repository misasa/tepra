require 'tepra/command'

class Tepra::Commands::PrintCommand < Tepra::Command
	def initialize
		super 'print', 'Print QR code labels', :set => 1, :skip_header => true, :printer => Tepra.default_printer

		add_option('-s', '--set NUMBER',
						'Set the number of copies') do |set, options|
			options[:set] = set
		end

		add_option('-t', '--template TEMPLATEFILE',
						"Set the template file path. Bundled templates in #{Tepra.template_dir}: #{Tepra.templates.join(", ")}." ) do |template_path, options|
			options[:template_path] = template_path
		end

		printer_names = Tepra.printers.join(", ")
		printer_description = "Select a printer by name."
		printer_description += " Configured printers: #{printer_names}." unless printer_names.empty?
		add_option('-p', '--printer PRINTER', printer_description) do |printer_name, options|
			options[:printer_name] = printer_name
		end

		add_option('-n', '--dry-run','Show the SPC command without printing') do |v|
			options[:dry_run] = v
		end

		add_option('-s', '--[no-]skip-header', 'Skip the header row in multi-row input') do |v|
			options[:skip_header] = v
		end
	end

	def usage
		"#{program_name} DATA_or_DATAFILE"
	end

	def arguments
		"A CSV string or a path to a CSV file"
	end

	def defaults_str
		"--set 1 --printer \"#{Tepra.default_printer}\" --template #{Tepra.template_path} --skip-header"
	end

	def description
		<<~'HELP'
		  Print QR code labels from a CSV string or a CSV file. Each row supplies
		  the data for a label. The first row is skipped by default when the input
		  has multiple rows. Use --no-skip-header if the first row contains label
		  data.

		  Printing requires King Jim's SPC software. If a print job times out,
		  increase :timeout in ~/.teprarc. The default is 5 seconds.

		      :timeout: 10

		  Examples:
		      tepra print "0000-01,test-1"
		      tepra print labels.csv
		      tepra print --no-skip-header labels-without-header.csv

		  Copyright (c) 2015-2020 Okayama University
		  Licensed under the GNU General Public License, version 3 or later.
		HELP
	end

	def execute
	    original_options = options.clone
        #p original_options
		args = options.delete(:args)
		raise OptionParser::InvalidArgument.new('specify DATA_or_DATAFILE') if args.empty?
		arg = args.shift
		options[:printer_name] = Tepra.default_printer unless options[:printer_name]
		if options[:dry_run]
			csvfile_path = Tepra.create_data_file(arg, options)
			command = Tepra.command_spc_print(csvfile_path, options)
			say command if options[:dry_run]
		else
			Tepra.print(arg, options)
		end
	end
end
