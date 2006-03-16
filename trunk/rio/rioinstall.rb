#!/usr/local/bin/ruby
require 'rbconfig'
require 'rio'

include Config

ruby = CONFIG['ruby_install_name']

sitedir = rio(CONFIG["sitelibdir"])

if (destdir = ENV['DESTDIR'])
  sitedir = rio(destdir,sitedir).mkpath
end
destination = rio(sitedir, "rio").mkpath.chmod(0755)
p destination


# The library files

rio('lib').all.files('*.rb') { |f|
  puts f
}
exit
files = Dir.chdir('lib') { Dir['**/*.rb'] }

for fn in files
  fn_dir = File.dirname(fn)
  target_dir = File.join($sitedir, fn_dir)
  if ! File.exist?(target_dir)
    File.makedirs(target_dir)
  end
  File::install(File.join('lib', fn), File.join($sitedir, fn), 0644, true)
end

