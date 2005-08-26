#!/usr/local/bin/ruby

require 'rio/prompt'

ans = RIO.prompt("Name: ")
puts "You typed '#{ans}'"
