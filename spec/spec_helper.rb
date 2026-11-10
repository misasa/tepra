require 'tmpdir'
require 'tepra'
require 'tepra/runner'

RSpec.configure do |config|
  config.order = :random
  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  config.around do |example|
    previous_config = Tepra.instance_variable_get(:@config)
    previous_pref_path = Tepra.instance_variable_get(:@pref_path)
    previous_spc_path = Tepra.instance_variable_get(:@spc_path)

    Dir.mktmpdir('tepra-spec-') do |directory|
      @work_dir = directory
      Tepra.pref_path = File.join(directory, '.teprarc')
      File.write(Tepra.pref_path, "{}\n")
      Tepra.config = nil
      Tepra.spc_path = File.join(directory, 'King Jim', 'SPC10.exe')
      example.run
    end
  ensure
    Tepra.config = previous_config
    Tepra.pref_path = previous_pref_path
    Tepra.spc_path = previous_spc_path
  end
end
