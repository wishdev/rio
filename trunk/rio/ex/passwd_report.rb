#!/usr/bin/env ruby
require 'rio'

rio('/etc/passwd').csv(':').columns(0,2,4) > rio(?-).csv("\t")

__END__

From Seattle,Wa
Take I-90 east, take exit 143 Gorge Amphitheatre. Follow amphitheatre signs approximately 6 miles.

206-242-8738
3:00
