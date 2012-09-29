require File.join(File.absolute_path(File.dirname(__FILE__)), '../lib/tracker-api')

EM.run{
  EM.start_server '0.0.0.0', 8080, TrackerApi::HttpServer
}

