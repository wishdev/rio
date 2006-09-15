#!/usr/local/bin/ruby
Dir.chdir File.dirname(__FILE__)
$:.unshift File.expand_path('../lib/')

require 'webrick'
require 'rio'


def create_server(config = {})
  # always listen on port 8088
  config.update(:Port => 8088)     
  server = WEBrick::HTTPServer.new(config)
  yield server if block_given?
  ['INT', 'TERM'].each {|signal| 
    trap(signal) {server.shutdown}
  }
  server

end

rio_test_docroot = rio('srv/www/htdocs').abs
#puts rio_test_docroot
logdir = rio('log').delete!.mkdir
logfile = logdir/'server.log'
logger = WEBrick::Log.new(logfile.to_s)
alogfile = logdir/'access.log'
access_log_stream = alogfile
access_log = [ [ access_log_stream, WEBrick::AccessLog::COMBINED_LOG_FORMAT ] ]

server = create_server(:DocumentRoot => rio_test_docroot, :Logger => logger, :AccessLog => access_log)

threads = []
tests_done = false

Thread.new(server) { |srv|
  srv.start
}
Thread.new() {
  #Thread.pass
  system("ruby runhttptests.rb")
}.join()

Thread.new(server) { |srv|
  srv.shutdown
}

#threads.each { |aThread|  aThread.join }
