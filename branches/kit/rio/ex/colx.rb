#!/usr/bin/env ruby
require 'rio'

rio('ex/rgb.txt.gz').gzip.lines(/^\s*(\d+)\s+(\d+)\s+(\d+)\s+(\S.+)/) do |line,ma| 
  printf("#%02x%02x%02x\t%s\n",ma[1],ma[2],ma[3],ma[4])
end
