#!/usr/bin/env ruby

require 'rio/kernel'

HEADERDIR = rio('misc')
LIBDIR = rio('lib')
OLIBDIR = rio('libo').mkdir

oldlines = rio(HEADERDIR,'oldheader').to_a
newlines = rio(HEADERDIR,'newheader').to_a
n_lines = oldlines.size

rio(LIBDIR).all.files("*.rb") do |f|

  of = f.sub(/^#{LIBDIR}/,OLIBDIR.to_s)
  puts "#{f} => #{of}"
  f > of.dirname.mkdir

  lines = of[]
  f_eader = lines[0...n_lines]
  if f_eader == oldlines
    f < [newlines,lines[n_lines..lines.size]]
  else
    puts "#{f} does NOT have old header"
  end
end



