#--
# =============================================================================== 
# Copyright (c) 2005, Christopher Kleckner
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
#  rake rdoc
# from the distribution directory. Then point your browser at the 'doc/rdoc' directory.
#
# Suggested Reading
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Rio
#
# <b>Rio is pre-alpha software. 
# The documented interface and behavior is subject to change without notice.</b>

#

require 'rio'

module RIO
  # Rio Constructor 
  #
  # For purposes of discussion, we divide Rios into two catagories, those that have a path
  # and those that don't.
  #
  # ==== Creating a Rio that has a path
  #
  # To create a Rio that has a path the arguments to +rio+ may be:
  #
  # * a string representing the entire path. The separator used for Rios is as specified in RFC1738 ('/').
  #    rio('adir/afile')
  # * a string representing a fully qualified +file+ URL as per RFC1738
  #    rio('file:///atopleveldir/adir/afile')
  # * a +URI+ object representing a +file+ or generic +URL+
  #    rio(URI('adir/afile'))
  # * the components of a path as separate arguments
  #    rio('adir','afile')
  # * the components of a path as an array of separate arguments
  #    rio(%w/adir afile/)
  # * another Rio
  #    another_rio = rio('adir/afile')
  #    rio(another_rio)
  # * any object whose +to_s+ method returns one of the above
  #    rio(Pathname.new('apath'))
  # * any combination of the above either as separate arguments or as elements of an array,
  #    another_rio = rio('dir1/dir2')
  #    auri = URI('dir4/dir5)
  #    rio(another_rio,'dir3',auri,'dir6/dir7')
  #
  # ===== Creating a Rio that refers to a web page
  #
  # To create a Rio that refers to a web page the arguments to +rio+ may be:
  #
  # * a string representing a fully qualified +http+ URL
  #    rio('http://ruby-doc.org/index.html')
  # * a +URI+ object representing a +http+ +URL+
  #    rio(URI('http://ruby-doc.org/index.html'))
  # * either of the above with additional path elements
  #    rio('http://www.ruby-doc.org/','core','classes/Object.html')
  #
  # ===== Creating a Rio that refers to a file or directory on a FTP server
  #
  # To create a Rio that refers to a file on a FTP server the arguments to +rio+ may be:
  #
  # * a string representing a fully qualified +ftp+ URL
  #    rio('ftp://user:password@ftp.example.com/afile.tar.gz')
  # * a +URI+ object representing a +ftp+ +URL+
  #    rio(URI('ftp://ftp.example.com/afile.tar.gz'))
  # * either of the above with additional path elements
  #    rio('ftp://ftp.gnu.org/pub/gnu','emacs','windows','README')
  #
  # ==== Creating Rios that do not have a path
  #
  # To create a Rio without a path, the first argument to +rio+ is usually a single
  # character.
  #
  # ===== Creating a Rio that refers to a clone of your programs stdin or stdout.
  # 
  # <tt>rio(?-)</tt> (mnemonic: '-' is used by some Unix programs to specify stdin or stdout in place of a file)
  # 
  # Just as a Rio that refers to a file, does not know whether that file will be opened for reading or
  # writing until an I/O operation is specified, a <tt>stdio:</tt> Rio does not know whether it will connect
  # to stdin or stdout until an I/O operation is specified. 
  #
  # ===== Creating a Rio that refers to a clone of your programs stderr.
  #
  # <tt>rio(?=)</tt> (mnemonic: '-' refers to fileno 1, so '=' refers to fileno 2)
  #
  # ===== Creating a Rio that refers to an arbitrary IO object.
  #
  #  an_io = ::File.new('afile')
  #  rio(an_io)
  #
  # ===== Creating a Rio that refers to a file descriptor
  #
  # <tt>rio(?#,fd)</tt> (mnemonic: a file descriptor is a number '#')
  #
  #  an_io = ::File.new('afile')
  #  fnum = an_io.fileno
  #  rio(?#,fnum)
  #
  # ===== Creating a Rio that refers to a StringIO object
  #
  # <tt>rio(?")</tt> (mnemonic: '"' surrounds strings)
  # * create a Rio that refers to a string that it creates
  #    rio(?")
  # * create a Rio that refers to a string of your choosing
  #    astring = ""
  #    rio(?",astring)
  #
  # ===== Creating a Rio that refers to a Tempfile object
  #
  # <tt>rio(??)</tt> (mnemonic: '?' you don't know its name)
  #  rio(??)
  #  rio(??,basename='rio',tmpdir=Dir::tmpdir)
  #
  # ===== Creating a Rio that refers to an arbitrary TCPSocket
  #
  #  rio('tcp:',hostname,port)
  # or
  #  rio('tcp://hostname:port')
  #
  # ===== Creating a Rio that runs an external program and connects to its stdin and stdout
  #
  # <tt>rio(?-,cmd)</tt> (mnemonic: '-' is used by some Unix programs to specify stdin or stdout in place of a file)
  #
  # or
  #
  # <tt>rio(?`,cmd)</tt> (mnemonic: '`' (backtick) runs an external program in ruby)
  #
  # This is Rio's interface to IO#popen
  def rio(*args,&block)  # :yields: self
    Rio.rio(*args,&block) 
  end
  module_function :rio

  # Create a Rio as with RIO#rio which refers to the current working directory 
  #  wd = RIO.cwd
  def cwd(*args,&block)  # :yields: self
    Rio.new.getwd(*args,&block) 
  end
  module_function :cwd

  # Create a Rio as with RIO#rio which refers to a directory at the root of the file system
  #  tmpdir = RIO.root('tmp') #=> rio('/tmp')
  def root(*args,&block) # :yields: self
    Rio.new.rootpath(*args,&block) 
  end
  module_function :root

end

if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

__END__

puts
puts("Run the tests that came with the distribution")
puts("From the distribution directory use 'test/runtests.rb'")
puts
