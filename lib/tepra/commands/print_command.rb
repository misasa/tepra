require 'tepra/command'

class Tepra::Commands::PrintCommand < Tepra::Command
	def initialize
		super 'print', 'Print label with QR-code', :set => 1, :skip_header => true, :printer => Tepra.default_printer

		add_option('-s', '--set NUMBER',
						'Specify number of labels') do |set, options|
			options[:set] = set
		end

		add_option('-t', '--template TEMPLATEFILE',
						"Specify template path. Available templates are #{Tepra.template_dir}/{#{Tepra.templates.join(",")}}.tpe." ) do |template_path, options|
			options[:template_path] = template_path
		end

		add_option('-p', '--printer PRINTER',
						"Specify printer name. Available printers are {#{Tepra.printers.join(",")}}.") do |printer_name, options|
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
		"datastring/csvfile"
	end

	def defaults_str
		"--set 1 --printer \"#{Tepra.default_printer}\" --template #{Tepra.template_path} --skip-header"
	end

	def description
	<<-EOF
    Print label with QR-code.  If you see timeout error, set `timeout'
    line on configration file `~/.teprarc' as below and raise the
    value.  Default setting is 5 seconds.

    :timeout: 10

    When you feed multiple entries delimited by CR either by
    datastring or datacsvfile, it prints multiple labels.  Note that
    by default it skips the first line.

    This program tries to look for "SPC" on C drive.  If you install
    "SPC" to D drive or else, configure %PATH% carefully.

Synopsis:
    tepra print "ID,name"
    tepra print csvfile

Options:
    --no-skip-header:  Print first line

Example:
	CMD> tepra print "0000-01,test-1"

	cygwin$ echo -e 'ID,Name\\n0000-01,KLB1' > my-great-list.csv
	cygwin$ tepra print my-great-list.csv

	cygwin$ tepra print "ID,Name\\n0000-01,test"
	cygwin$ tepra print "0000-01,test-1\\n0000-02,test-2" --no-skip-header
	cygwin$ tepra print "0000-01,test-1"

See also:
    orochi-label
    http://dream.misasa.okayama-u.ac.jp
    https://github.com/misasa/tepra/blob/master/lib/tepra/commands/print_command.rb

Implementation:
    Copyright (c) 2015-2020 Okayama University
    Licensed under the same terms as Ruby

		EOF
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
