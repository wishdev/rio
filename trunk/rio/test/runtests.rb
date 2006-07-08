#!/usr/local/bin/ruby
Dir.chdir File.dirname(__FILE__)
$devlib=File.expand_path('../lib/')
$:.unshift $devlib unless $:[0] == $devlib

$mswin32 = (RUBY_PLATFORM =~ /mswin32/)

require 'rio'
require 'test/unit'

require 'tc/all'
$trace_states = false
require 'test/unit/ui/console/testrunner'
#require 'test/unit/ui/tk/testrunner'
#require 'test/unit/ui/fox/testrunner'
#Test::Unit::UI::Tk::TestRunner.run(TC_MyTest)
