require 'spec_helper'
require 'open3'
require 'rbconfig'

RSpec.describe 'tepra executable' do
  def run_cli(*arguments)
    root = File.expand_path('../..', __dir__)
    Open3.capture3(
      { 'HOME' => @work_dir, 'USERPROFILE' => @work_dir },
      RbConfig.ruby, '-I', File.join(root, 'lib'), File.join(root, 'bin', 'tepra'),
      *arguments, chdir: @work_dir
    )
  end

  it 'prints top-level help and exits successfully' do
    stdout, stderr, status = run_cli('--help')

    expect(status.exitstatus).to eq(0)
    expect(stdout).to include('Usage: tepra', 'Sub-command:', '--version')
    expect(stderr).to be_empty
  end

  it 'prints the library version and exits successfully' do
    stdout, stderr, status = run_cli('--version')

    expect(status.exitstatus).to eq(0)
    expect(stdout).to eq("#{Tepra::VERSION}\n")
    expect(stderr).to be_empty
  end
end
