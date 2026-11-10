require 'spec_helper'

RSpec.describe 'tepra gem package' do
  it 'includes the executable, templates, and web assets needed at runtime' do
    root = File.expand_path('..', __dir__)
    Dir.chdir(root) do
      specification = Gem::Specification.load('tepra.gemspec')
      assets = Dir['template/*', 'lib/tepra/views/*.haml', 'lib/tepra/public/**/*'].select do |path|
        File.file?(path)
      end

      expect(specification.executables).to eq(['tepra'])
      expect(specification.licenses).to eq(['GPL-3.0-or-later'])
      expect(specification.files).to include(
        'bin/tepra', 'lib/tepra.rb', 'template/default.tpc', 'template/default.tpe',
        'lib/tepra/views/index.haml', 'lib/tepra/public/css/styles.css',
        'config.ru', 'README.md', 'LICENSE.txt', *assets
      )
      expect(specification.files.grep(%r{\A(?:\.github|script|spec)/})).to be_empty
    end
  end
end
