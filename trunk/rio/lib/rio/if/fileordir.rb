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


module RIO
  class Rio

    # Creates a symbolic link _dest_ which points to the Rio's Rio#fspath.  
    # Raises a NotImplementedError exception on platforms that do not support symbolic links.
    # _dest_ may be a Rio, a String, or anything that will create an appropriate Rio 
    # when passed to Rio#new 
    # If _dest_ already exists and is a directory, creates a symbolic link in the _dest_ directory,
    # named with the name returned by Rio#filename
    # If _dest_ already exists and it is not a directory, raises Errno::EEXIST.
    # 
    # Returns the Rio (not the symlink)
    #
    # Rio#symlink differs from File#symlink when the Rio or the _dest_ path has directory information.
    # In this case Rio#symlink creates a symlink that actually refers to the Rio's location 
    # from the perspective of the link's location.
    #
    # For example: Given an existing file 'adir/afile' and a _dest_ of 'adir/alink'
    #  ::File.symlink('adir/afile','adir/alink1') # creates 'adir/alink1 -> adir/afile'
    #  ::File.exist?('adir/alink1') # false
    #  rio('adir/afile').symlink('adir/alink2')   # creates 'adir/alink2 -> afile'
    #  ::File.exist?('adir/alink2') # true
    #
    # To replace an existing symlink use the following Rio idiom
    #  rio('afile').symlink( rio('link_name').delete ) # delete 'link_name' and recreate linked to 'afile'
    #
    # Examples
    #  rio('afile').symlink('alink')    # create the symbolic link 'alink' which references 'afile'
    #  rio('afile').symlink('adir/alink') # create a symlink 'adir/alink' -> '../afile'
    #  rio('adir/afile').symlink('alink') # create a symlink 'alink' -> 'adir/afile'
    #  rio('adir/afile').symlink('adir/alink') # create a symlink 'adir/alink' -> 'afile'
    #  rio('adir/afile').symlink('adir/alink') # create a symlink 'adir/alink' -> 'afile'
    #  rio('adir1/afile').symlink('adir2/alink') # create a symlink 'adir2/alink' -> '../adir1/afile'
    #  rio('/tmp/afile').symlink('alink') # create a symlink 'adir/alink' -> '/tmp/afile'
    def symlink(dest) target.symlink(dest); self end


    # Calls File#readlink
    #
    # Returns a Rio referencing the file referenced by the given link. Not available on all platforms.
    #
    def readlink(*args) target.readlink(*args) end

    # If called with an argument calls FileUtils#rename
    # If called without an argument puts the Rio in a rename mode in
    # which changes to the Rio's path affect a rename of the file
    # on the file system.
    # 
    # Proxy for FileUtils#rename
    #  ario = rio('afile.cpp')
    #  ario.rename('afile.cxx') # renamed the file, but ario still references
    #                           # the old path
    # Rename Mode
    #
    # Change the extension of all'.cpp' files in 'adir' to '.cxx'
    #  rio('adir').rename.files('*.cpp') do |file|
    #    file.ext = '.cxx' # 'file' references the new path and the actual file is renamed
    #  end
    #  
    # Recursively change all '.tar.gz' files to '.tgz' files
    #  rio('adir').rename.all.files('*.tar.gz') do |gzfile|
    #    gzfile.ext('.tar.gz').ext = '.tgz'
    #  end
    #
    # See Rio#dirname=, Rio#filename=, Rio#basename=, and Rio#extname=
    #
    def rename(*args,&block) target.rename(*args,&block); self end
    

    # Behaves like Rio#rename, but also changes the calling Rio to 
    # refer to the renamed path
    def rename!(*args,&block) target.rename!(*args,&block); self end
    

    # For directories proxies Dir#read, otherwise proxies IO#read
    #
    # Proxy for IO#read
    #      ario.read([integer [, buffer]])    => string, buffer, or nil
    # Reads at most _integer_ bytes from the I/O stream, or to the end of
    # file if _integer_ is omitted or is +nil+. If the optional _buffer_
    # argument is present, it must reference a String, which will receive
    # the data. Returns +nil+ if called at end of file.
    #
    #  f = rio("testfile")
    #  f.read(16)   #=> "This is line one"
    #
    #  rio("testfile").read(16) #=> "This is line one"
    #
    # Proxy for Dir#read
    #     dir.read => ario or nil
    #------------------------------------------------------------------------
    #     Reads the next entry from _dir_ and returns it as a Rio. Returns
    #     +nil+ at the end of the stream.
    #        d = rio("testdir")
    #        d.read   #=> rio(".")
    #        d.read   #=> rio("..")
    #        d.read   #=> rio("config.h")
    #
    def read(*args) target.read(*args)end
    
    # For directories proxies Dir#rewind, otherwise proxies IO#rewind
    #
    # Proxy for IO#rewind
    #       ario.rewind   => ario
    # Positions _ario_ to the beginning of input, resetting lineno to zero.
    #
    # Returns the Rio
    #
    #  f = rio("testfile")
    #  f.readline   #=> "This is line one\n"
    #  f.rewind     #=> f
    #  f.lineno     #=> 0
    #  f.readline   #=> "This is line one\n"
    #
    #  f.rewind.readline #=> "This is line one\n"
    #
    # Proxy for Dir#rewind
    #     ario.rewind => ario
    #------------------------------------------------------------------------
    #     Repositions _ario_ to the first entry.
    #
    #        d = rio("testdir")
    #        d.read          #=> rio(".")
    #        d.rewind.read   #=> rio(".")
    def rewind(&block) target.rewind(&block); self end

    # For directories proxies Dir#seek, otherwise proxies IO#seek
    #
    # Proxy for IO#seek
    #      ario.seek(amount, whence=SEEK_SET) -> ario
    # Seeks to a given offset _amount_ in the stream according to the
    # value of _whence_:
    #
    #  IO::SEEK_CUR  | Seeks to <em>amount</em> plus current position
    #  --------------+----------------------------------------------------
    #  IO::SEEK_END  | Seeks to <em>amount</em> plus end of stream (you probably
    #                | want a negative value for <em>amount</em>)
    #  --------------+----------------------------------------------------
    #  IO::SEEK_SET  | Seeks to the absolute location given by <em>amount</em>
    #
    # Example:
    #
    #  f = rio("testfile")
    #  f.seek(-28, IO::SEEK_END).readline                  #=> "happily ever after. The End\n"
    #
    # Proxy for Dir#seek
    #     ario.seek( integer ) => ario
    # Seeks to a particular location in _ario_. _integer_ must be a value
    # returned by +Dir#tell+ or Rio#tell.
    #
    #        d = rio("testdir")       #=> #<RIO::Rio:0x401b3c40>
    #        d.read                   #=> rio(".")
    #        i = d.tell               #=> 12
    #        d.read                   #=> rio("..")
    #        d.seek(i)                #=> #<RIO::Rio:0x401b3c40>
    #        d.read                   #=> rio("..")
    def seek(*args) target.seek(*args); self end
    #def seek(amount,whence=IO::SEEK_SET) target.seek(amount,whence) end



    # For directories proxies Dir#pos, otherwise proxies IO#pos
    #
    # Proxy for IO#pos
    #      ario.pos     => integer
    #      ario.tell    => integer
    # Returns the current offset (in bytes) of _ario_.
    #
    #  f = rio("testfile")
    #  f.pos    #=> 0
    #  f.gets   #=> "This is line one\n"
    #  f.pos    #=> 17
    #
    #
    # Proxy for Dir#pos
    #     ario.pos => integer
    #     ario.tell => integer
    # Returns the current position in _dir_. See also +Rio#seek+.
    #
    #        d = rio("testdir")
    #        d.pos   #=> 0
    #        d.read  #=> rio(".")
    #        d.pos   #=> 12
    #
    def pos() target.pos end

    # See Rio#pos
    def tell() target.tell end

    # For directories proxies Dir#pos=, otherwise proxies IO#pos=
    #
    # Proxy for IO#pos=
    #      ario.pos = integer    => 0
    # Seeks to the given position (in bytes) in _ario_.
    #
    #  f = rio("testfile")
    #  f.pos = 17
    #  f.gets   #=> "This is line two\n"
    #
    # Proxy for Dir#pos=
    #     ario.pos = integer     => integer
    #------------------------------------------------------------------------
    # Synonym for +Rio#seek+, but returns the position parameter.
    #
    #        d = rio("testdir")       #=> d
    #        d.read                   #=> rio(".")
    #        i = d.pos                #=> 12
    #        d.read                   #=> rio("..")
    #        d.pos = i                #=> 12
    #        d.read                   #=> rio("..")
    #
    def pos=(integer) target.pos = integer end
  end
end


