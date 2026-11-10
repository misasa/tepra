require 'spec_helper'
require 'tepra/server'

RSpec.describe Tepra::CommandManager do
  it 'starts the server with the configured port when no subcommand is given' do
    Tepra.config = { port: 9123 }
    expect(Tepra::Server).to receive(:run!).with(hash_including(port: 9123))

    Tepra::CommandManager.new.run([])
  end
end
