require 'pathname'
require 'open3'
class File
	class << self
		alias __expand_path__ expand_path
	end

	def self.cygpath(path, opts = [])
		return path unless RUBY_PLATFORM.downcase =~ /cygwin/

		dirname = dirname(path)
		basename = basename(path)
		command = "cygpath "
		command += opts.map{|opt| opt.length == 1 ? "-#{opt}" : "--#{opt}" }.join(" ")
		command += " \"#{dirname}\""
		out, error, status = Open3.capture3(command)
		raise RuntimeError.new(error) unless status.success?
		cpath = out.chomp
		rpath = Pathname.new(cpath) + basename
		rpath.to_s
	end

	def self.expand_path(path, default_dir = '.', opts = {})
		path = __expand_path__(path, default_dir)
		if opts[:output_type]
			path = cygpath(path, [opts[:output_type]])
			# case opts[:output_type]
			# when :windows
			# 	path = cygpath(path, ["windows"])
			# 	#path = Pathname.new(path).sub(/^\/cygdrive\/(.)/){ $1.upcase + ':' }.to_s
			# when :unix
			# 	path = cygpath(path, ["unix"])
			# 	#path = Pathname.new(path).sub(/^(.):/){ '/cygdrive/' + $1.downcase }.to_s
			# end
		end
		path
	end
end
