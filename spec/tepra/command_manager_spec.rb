require 'spec_helper'
require 'tepra/command_manager'
module Tepra
  describe CommandManager do
  let(:cmd){ CommandManager.instance }
  # context "with --help" do
  #   let(:args){ ['--help'] }
  #   before do
  #     puts cmd.show_help
  #   end
  #   it "shows help and exit" do
  #     expect(cmd).to receive(:show_help)
  #     # expect{ cmd.run args }.to exit_with_code(0)
  #   end
  # end

  describe "#show_help", :show_help => true do
    it {
      puts "===================================="
      expect{ cmd.show_help }.not_to raise_error
      puts "===================================="
    }
  end
  end
end
