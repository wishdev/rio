#!/usr/bin/ruby
Dir.chdir File.dirname(__FILE__)
$:.unshift '../lib'

require 'rio'
require 'test/unit'

ARGV.each do |el|
  puts "Running test '#{el}'"
  load 'tc/'+el+'.rb'
end
$trace_states = false
require 'test/unit/ui/console/testrunner'
#require 'test/unit/ui/tk/testrunner'
