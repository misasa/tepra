require 'tepra/runner'

step "I am not yet playing" do
end

step "I start app with :arg" do |arg|
	@argv = Shellwords.split(arg)
	@app = Tepra::Runner.new
	@app.run @argv
end
