require 'spec_helper'
require 'stringio'

RSpec.describe 'tepra print' do
  let(:runner) { Tepra::Runner.new(command_manager: Tepra::CommandManager.new) }
  let(:printer) { 'Lab printer' }
  let(:template) { File.join(@work_dir, 'custom label.tpe') }

  before do
    Tepra.config = { printer: printer }
  end

  def run_print(*arguments)
    output = StringIO.new
    ui = Tepra::StreamUI.new(StringIO.new, output)
    Tepra::DefaultUserInteraction.use_ui(ui) { runner.run(['print', *arguments]) }
    output.string
  end

  it 'describes the print arguments and options in subcommand help' do
    expect(Tepra).not_to receive(:print)

    expect(run_print('--help')).to include('DATA_or_DATAFILE', '--dry-run', '--template', '--skip-header')
  end

  it 'uses the configured printer and the default header and copy settings' do
    expect(Tepra).to receive(:print).with('id,name', hash_including(
      printer_name: printer, skip_header: true, set: 1
    ))

    expect(run_print('id,name')).to be_empty
  end

  it 'forwards explicit print options after the input argument' do
    expect(Tepra).to receive(:print).with('id,name', hash_including(
      printer_name: 'Other printer', template_path: template, skip_header: false, set: '3'
    ))

    expect(run_print('id,name', '--printer', 'Other printer', '--template', template,
                     '--no-skip-header', '--set', '3')).to be_empty
  end

  it 'generates the CSV and reports the SPC command in dry-run mode' do
    input = File.join(@work_dir, 'source data.csv')
    File.write(input, "ID,Name\n123,Sample\n")
    allow(Dir).to receive(:tmpdir).and_return(@work_dir)
    expect(Tepra).not_to receive(:print)
    allow(Process).to receive(:spawn).and_call_original
    expect(Process).not_to receive(:spawn).with(/\A"#{Regexp.escape(Tepra.spc_path.to_s)}" \/pt /)

    output = run_print('--dry-run', '--set', '2', '--template', template, input)

    csv_path, = Dir[File.join(@work_dir, 'tepra*.csv')]
    expect(csv_path).not_to be_nil
    expect(File.binread(csv_path)).to eq("123,123,Sample\n")
    expect(File.binread(input)).to eq("ID,Name\n123,Sample\n")

    spc_template = File.expand_path(template, '.', output_type: :mixed)
    spc_csv = File.expand_path(csv_path, '.', output_type: :mixed)
    expect(output).to eq(%("#{Tepra.spc_path}" /pt "#{spc_template},#{spc_csv},2" "#{printer}"\n))
  end

  it 'reports missing data without trying to print' do
    expect(Tepra).not_to receive(:print)

    expect(run_print).to include('specify DATA_or_DATAFILE', 'tepra print --help')
  end
end
