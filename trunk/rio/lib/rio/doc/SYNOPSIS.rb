#--
# =============================================================================== 
# Copyright (c) 2005, 2006 Christopher Kleckner
# All rights reserved
#
# This file is part of the Rio library for ruby.
#
# Rio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Rio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rio; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# =============================================================================== 
#++
#
# To create the documentation for Rio run the command
#  ruby build_doc.rb
# from the distribution directory.
#
# Suggested Reading
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Doc::EXAMPLES
# * RIO::Rio
#


# :title: Rio

module RIO
# Copyright (c) 2005, 2006 Christopher Kleckner.
# All rights reserved
#
# This file is part of the Rio library for ruby.
# Rio is free software; you can redistribute it and/or modify it under the terms of 
# the {GNU General Public License}[http://www.gnu.org/licenses/gpl.html] as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
module Doc #:doc:
=begin rdoc

= Rio - Ruby I/O Comfort Class

Rio is a convenience class wrapping much of the functionality of IO,
File, Dir, Pathname, FileUtils, Tempfile, StringIO, and OpenURI and
uses Zlib, and CSV to extend that functionality using a simple
consistent interface.  Most of the instance methods of IO, File and
Dir are simply forwarded to the appropriate handle to provide
identical functionality. Rio also provides a "grande" interface that
allows many application level IO tasks to be expressed succinctly.


== SYNOPSIS

For the following assume:
 astring = ""
 anarray = []

Copy or append a file to a string
 rio('afile') > astring      # copy
 rio('afile') >> astring     # append

Copy or append a string to a file
 rio('afile') < astring      # copy
 rio('afile') << astring     # append

Copy or append the lines of a file to an array
 rio('afile') > anarray     
 rio('afile') >> anarray
 
Copy or append a file to another file
 rio('afile') > rio('another_file')  
 rio('afile') >> rio('another_file') 

Copy a file to a directory
 rio('adir') << rio('afile')

Copy a directory structure to another directory
 rio('adir') >> rio('another_directory')

Copy a web-page to a file
 rio('http://rubydoc.org/') > rio('afile')

Ways to get the chomped lines of a file into an array
 anarray = rio('afile').chomp[]         # subscript operator
 rio('afile').chomp > anarray           # copy-to operator
 anarray = rio('afile').chomp.to_a      # to_a
 anarray = rio('afile').chomp.readlines # IO#readlines
 
Copy a gzipped file un-gzipping it
 rio('afile.gz').gzip > rio('afile')

Copy a plain file, gzipping it
 rio('afile.gz').gzip < rio('afile')

Copy a file from a ftp server into a local file un-gzipping it
 rio('ftp://host/afile.gz').gzip > rio('afile')

Iterate over the entries in a directory
 rio('adir').entries { |entrio| ... }

Iterate over only the files in a directory
 rio('adir').files { |entrio| ... }

Iterate over only the .rb files in a directory
 rio('adir').files('*.rb') { |entrio| ... }

Iterate over only the _dot_ files in a directory
 rio('adir').files(/^\./) { |entrio| ... }

Iterate over the files in a directory and its subdirectories, skipping '.svn' and 'CVS' directories 
 rio('adir').norecurse(/^\.svn$/,'CVS').files { |entrio| ... }

Create an array of the .rb entries in a directory
 anarray = rio('adir')['*.rb']

Create an array of the .rb entries in a directory and its subdirectories
 anarray = rio('adir').all['*.rb']

Iterate over the .rb files in a directory and its subdirectories
 rio('adir').all.files('*.rb') { |entrio| ... }

Copy an entire directory structure and the .rb files within it
 rio('adir').dirs.files('*.rb') > rio('another_directory')

Iterate over the first 10 chomped lines of a file
 rio('afile').chomp.lines(0..9) { |line| ... }

Put the first 10 chomped lines of a file into an array
 anarray = rio('afile').chomp.lines[0..9]

Copy the first 10 lines of a file into another file
 rio('afile').lines(0..9) > rio('another_file')

Copy the first 10 lines of a file to stdout
 rio('afile').lines(0..9) > rio(?-)

Copy the first 10 lines of a gzipped file on an ftp server to stdout
 rio('ftp://host/afile.gz').gzip.lines(0..9) > rio(?-)

Put the first 100 chomped lines of a gzipped file into an array
 anarray =  rio('afile.gz').chomp.gzip[0...100] 

Put chomped lines that start with 'Rio' into an array
 anarray = rio('afile').chomp[/^Rio/]

Iterate over the non-empty, non-comment chomped lines of a file
 rio('afile').chomp.skiplines(:empty?,/^\s*#/) { |line| ... }

Copy the output of th ps command into an array, skipping the header line and the ps command entry
 rio(?-,'ps -a').skiplines(0,/ps$/) > anarray 

Prompt for input and return what was typed
 ans = rio(?-).print("Type Something: ").chomp.gets 

Change the extension of all .htm files in a directory and its subdirectories to .html
 rio('adir').rename.all.files('*.htm') do |htmfile|
   htmfile.extname = '.html'
 end

Create a symbolic link 'asymlink' in 'adir' which refers to 'adir/afile'
 rio('adir/afile').symlink('adir/asymlink')

=== SUGGESTED READING

* RIO::Doc::INTRO
* RIO::Doc::HOWTO
* RIO::Rio
* RIO::Doc::EXAMPLES
* RIO::Doc::OPTIONAL

=end
module SYNOPSIS #:doc:
end
end
end
