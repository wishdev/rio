#!/usr/bin/env ruby

require 'rio/kernel'

HEADERDIR = rio('misc')
LIBDIR = rio('lib')
OLIBDIR = rio('libo').mkdir

oldlines = rio(HEADERDIR,'oldheader').to_a
newlines = rio(HEADERDIR,'newheader').to_a
n_lines = oldlines.size

rio(LIBDIR).all.files("*.rb") do |file|

  old_file = file.sub(/^#{LIBDIR}/,OLIBDIR.to_s)
  puts "#{file} => #{old_file}"
  file > old_file.dirname.mkdir

  lines = old_file[]
  file_header = lines[0...n_lines]
  if file_header == oldlines
    file < [newlines,lines[n_lines..lines.size]]
  else
    puts "#{file} does NOT have old header"
  end
end



