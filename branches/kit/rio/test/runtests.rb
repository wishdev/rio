#!/usr/bin/ruby
Dir.chdir File.dirname(__FILE__)
$:.unshift '../lib'

require 'rio'
require 'test/unit'

require 'tc/all'
$trace_states = false
require 'test/unit/ui/console/testrunner'
#require 'test/unit/ui/tk/testrunner'
