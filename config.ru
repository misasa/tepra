require 'rubygems'
require 'bundler'

Bundler.require

require './lib/tepra/server.rb'

run Tepra::Server
