require 'spec_helper'
require 'tepra/commands/server_command'

RSpec.describe Tepra::Commands::ServerCommand do
  subject(:command) { described_class.new }

  it 'defaults to port 8889' do
    expect(Tepra::Server).to receive(:run!).with(hash_including(port: 8889))

    command.invoke_with_build_args([], nil)
  end

  it 'starts the server on the port specified on the command line' do
    expect(Tepra::Server).to receive(:run!).with(hash_including(port: 9123))

    command.invoke_with_build_args(['--port', '9123'], nil)
  end

  it 'rejects ports outside the valid range' do
    expect { command.handle_options(['--port', '65536']) }.to raise_error(
      OptionParser::InvalidArgument, /not a port number/
    )
  end

  it 'stops the server for --quit' do
    expect(Tepra::Server).to receive(:quit!)
    expect(Tepra::Server).not_to receive(:run!)

    command.invoke_with_build_args(['--quit'], nil)
  end
end
