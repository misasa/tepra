# Run after bundle install: bundle exec ruby script/verify_package.rb path.gem
require 'bundler'
require 'open3'
require 'rbconfig'
require 'rubygems/package'
require 'tmpdir'
require_relative '../lib/tepra/version'

archive = File.expand_path(ARGV.fetch(0))
package = Gem::Package.new(archive)
package.verify
abort 'Archive version differs from source' unless package.spec.version.to_s == Tepra::VERSION
abort 'Archive filename differs from gemspec' unless File.basename(archive) == package.spec.file_name
required = %w[bin/tepra lib/tepra.rb lib/tepra/views/index.haml
              lib/tepra/public/css/styles.css template/default.tpc template/default.tpe]
missing = required - package.contents
abort "Missing packaged files: #{missing.join(', ')}" unless missing.empty?

dependency_paths = (Gem.path + Gem.loaded_specs.values.map(&:base_dir)).uniq
Dir.mktmpdir('tepra-package-') do |directory|
  gem_home = File.join(directory, 'gems')
  environment = {
    'GEM_HOME' => gem_home,
    'GEM_PATH' => ([gem_home] + dependency_paths).join(File::PATH_SEPARATOR)
  }
  execute = lambda do |*args|
    stdout, stderr, status = Open3.capture3(environment, RbConfig.ruby, *args, chdir: directory)
    abort "Command failed: #{args.inspect}\n#{stdout}\n#{stderr}" unless status.success?
    stdout
  end

  Bundler.with_unbundled_env do
    execute.call('-S', 'gem', 'install', '--local', '--no-document', '--ignore-dependencies', archive)
    executable = File.join(gem_home, 'bin', 'tepra')
    abort 'Installed version differs from source' unless execute.call(executable, '--version').strip == Tepra::VERSION

    execute.call('-rtepra', '-e', <<~'CHECK', gem_home)
      installed = Gem.loaded_specs.fetch('tepra')
      expected = File.join(ARGV.fetch(0), 'gems', installed.full_name)
      abort 'Tepra loaded from outside the isolated installation' unless File.realpath(installed.full_gem_path) == File.realpath(expected)

      Tepra.config = {}
      Tepra.spc_path = 'SPC10.exe'
      abort 'Bundled template is missing' unless Tepra.template_path.file?
      csv = Tepra.create_data_file('001,Sample')
      begin
        abort 'Unexpected CSV output' unless File.binread(csv.path) == "001,001,Sample\n"
      ensure
        csv.unlink
      end
    CHECK
  end
end
puts "PASS #{package.spec.full_name} archive and installed CLI"
