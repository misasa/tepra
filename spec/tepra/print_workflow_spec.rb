require 'spec_helper'

RSpec.describe Tepra do
  describe '.create_data_file' do
    it 'preserves quoted fields, Japanese text, and extra columns in CSV files' do
      source = File.join(@work_dir, 'labels.csv')
      input = "ID,Name\r\n001,\"試料, A\"\r\n002,second,third,fourth\r\n"
      File.binwrite(source, input)

      output = Tepra.create_data_file(source, skip_header: true)

      expect(CSV.read(output.path, encoding: 'UTF-8')).to eq([
        ['001', '001', '試料, A'],
        %w[002 second third fourth]
      ])
      expect(File.binread(source)).to eq(input.b)
    ensure
      output.unlink if output
    end

    it 'keeps the first row when header skipping is disabled' do
      output = Tepra.create_data_file("ID,Name\n123,Sample\n", skip_header: false)

      expect(File.binread(output.path)).to eq("ID,ID,Name\n123,123,Sample\n")
    ensure
      output.unlink if output
    end

    it 'reports malformed CSV' do
      allow(Dir).to receive(:tmpdir).and_return(@work_dir)

      expect { Tepra.create_data_file('001,"unclosed') }.to raise_error(CSV::MalformedCSVError)
    end
  end

  describe 'SPC discovery and templates' do
    it 'tries supported versions from newest to oldest and caches the first match' do
      Tepra.spc_path = nil
      path = Pathname.new(File.join(@work_dir, 'SPC11.exe'))
      expect(Tepra).to receive(:get_spc_path).with(12).ordered.and_return(nil)
      expect(Tepra).to receive(:get_spc_path).with(11).ordered.and_return(path)

      expect(Tepra.spc_path).to eq(path)
      expect(Tepra.spc_path).to eq(path)
    end

    it 'uses the bundled TPC template for SPC9 and TPE for newer SPC' do
      expect(Tepra.template_path).to eq(Tepra.template_dir + 'default.tpe')
      expect(Tepra.template_path).to be_file

      Tepra.spc_path = File.join(@work_dir, 'SPC9.exe')

      expect(Tepra.template_path).to eq(Tepra.template_dir + 'default.tpc')
      expect(Tepra.template_path).to be_file
      expect(Tepra.templates).to eq(['default'])
    end

    it 'prefers an explicit path over a named template and the printer default' do
      Tepra.config = { template: '18x18', printer: [{ name: 'Lab printer', template: '50x80' }] }
      options = { printer_name: 'Lab printer', template: '24x50' }
      path = File.join(@work_dir, 'custom.tpe')

      expect(Tepra.select_template(options)).to eq(Tepra.template_dir + '24x50.tpe')
      expect(Tepra.select_template(options.merge(template_path: path))).to eq(path)
    end
  end

  describe '.print' do
    let(:pid) { 12345 }
    let(:started_at) { Time.at(1_000) }
    let(:spc_command) { /\A"#{Regexp.escape(Tepra.spc_path.to_s)}" \/pt / }

    before do
      allow(Dir).to receive(:tmpdir).and_return(@work_dir)
      allow(Tepra).to receive(:sleep).with(1)
      allow(Process).to receive(:spawn).and_call_original
    end

    it 'passes the generated CSV to SPC and polls until the print process exits' do
      Tepra.config = { printer: 'Lab printer', template: '18x50' }
      allow(Time).to receive(:now).and_return(started_at)
      expect(Process).to receive(:spawn).with(spc_command) do |command|
        csv_path, = Dir[File.join(@work_dir, 'tepra*.csv')]
        expect(File.binread(csv_path)).to eq("123,123,Sample\n")
        template = File.expand_path(Tepra.template_dir + '18x50.tpe', '.', output_type: :mixed)
        csv = File.expand_path(csv_path, '.', output_type: :mixed)
        expect(command).to eq(%("#{Tepra.spc_path}" /pt "#{template},#{csv},2" "Lab printer"))
        pid
      end
      expect(Process).to receive(:waitpid).with(pid, Process::WNOHANG).twice.and_return(nil, pid)
      expect(Process).not_to receive(:kill)

      Tepra.print('123,Sample', set: 2)
    end

    it 'kills and reaps a timed-out process before raising TimeoutError' do
      # Advance the clock after spawn so CSV and tempfile creation use real time.
      expect(Process).to receive(:spawn).with(spc_command) do
        allow(Time).to receive(:now).and_return(started_at + 2)
        pid
      end
      allow(Time).to receive(:now).and_return(started_at)
      expect(Process).to receive(:kill).with('KILL', pid).ordered
      expect(Process).to receive(:wait).with(pid).ordered

      expect { Tepra.print('123,Sample', timeout: 1) }.to raise_error(Tepra::TimeoutError)
    end
  end
end
