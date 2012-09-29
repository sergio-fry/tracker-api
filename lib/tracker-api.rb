require 'bundler'
Bundler.setup

$LOAD_PATH.unshift(File.dirname(__FILE__))
APP_ROOT = File.absolute_path(File.join(File.dirname(__FILE__), ".."))

require 'tracker-api/rgfootball-net.rb'
require 'tracker-api/http_server.rb'

