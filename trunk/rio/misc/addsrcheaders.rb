#!/usr/bin/env ruby

require 'rio/kernel'

HEADERDIR = rio('misc')
LIBDIR = rio('lib')
NLIBDIR = rio('libn').mkdir
OLIBDIR = rio('libo').mkdir


header_lines = ["#--\n",rio(HEADERDIR).files('*.txt').nolines[/^#--/,/\#\+\+/],"#++\n"]

rio(LIBDIR).all.files("*.rb") do |f|
  #nf = rio(NLIBDIR,f.rel(LIBDIR))
  nf = f.sub(/^lib/,'libn')
  nf.dirname.mkpath
  puts "#{f} => #{nf}"
  cnt = f.slurp
  nf < ( cnt.sub!(/#--.+#\+\+/m,header_lines.to_s) || (header_lines.to_s + cnt))
  nf.rename.dirname = f.dirname
end



