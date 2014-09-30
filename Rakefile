require "bundler/gem_tasks"

module Bundler
  class GemHelper
    protected
    def rubygem_push(path)
      if Pathname.new("~/.gem/geminabox").expand_path.exist?
        sh("bundle exec gem inabox -o '#{path}'")
        Bundler.ui.confirm "Pushed #{name} #{version} to http://devel.misasa.okayama-u.ac.jp/gems/."
      else
        raise "Your geminabox credentials aren't set. Run `gem inabox #{path}` to push your gem and set credentials."
      end
    end
  end
end