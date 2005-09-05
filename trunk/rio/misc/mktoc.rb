#!/usr/bin/env ruby
require 'rio'

RDOCDIR = rio('doc/rdoc')
#RDOCDIR = rio('/loc/doc/ruby-doc/core')
SBDIR = RDOCDIR/'sidebar'
ofile = SBDIR/'toc.xml'
#ofile = rio(?-)

CLDI = RDOCDIR/'classes'
#CLDI.all.files('*.html').norecurse('*.src') { |f|

def dofile(ofile,clfile,depth)
  clfile.lines(%r|href="(#M\d{6})">(\w+[!?=]?)</a>|) { |l,ma|
    afile = clfile.route_from(SBDIR) + ma[1]
    ofile.puts(('  ' * depth  ) +%{<item url="#{afile}" title="#{ma[2]}" />})
  }

end
def dodir(ofile,cldir,depth=1)
  #p clfile.filename.to_s
  cldir.files('*.html') { |ent|
    d = ent.sub(/\.html$/,'')
    afile = ent.route_from(SBDIR)
    ofile.puts(('  ' * depth) +%{<item url="#{afile}" title="#{ent.basename}">})
    if d.dir?
      dofile(ofile,ent,depth+1)
      dodir(ofile,d,depth+1)
    else
      dofile(ofile,ent,depth+1)
    end
    ofile.puts(('  ' * depth ) +%{</item>})
  }
end
ofile.puts('<?xml version="1.0" encoding="iso-8859-1"?>')

ofile.puts('<toc title="Rio for Ruby">')
dodir(ofile,CLDI)
ofile.puts('</toc>')
ofile.close
__END__




HEADERDIR = rio('misc')
LIBDIR = rio('lib')
NLIBDIR = rio('libn').mkdir
OLIBDIR = rio('libo').mkdir


header_lines = ["#--\n",rio(HEADERDIR).files('*.txt').skiplines[/^#--/,/\#\+\+/],"#++\n"]

rio(LIBDIR).all.files("*.rb") do |f|
  #nf = rio(NLIBDIR,f.rel(LIBDIR))
  nf = f.sub(/^lib/,'libn')
  nf.dirname.mkpath
  puts "#{f} => #{nf}"
  cnt = f.slurp
  nf < ( cnt.sub!(/#--.+#\+\+/m,header_lines.to_s) || (header_lines.to_s + cnt))
  nf.rename.dirname = f.dirname
end



