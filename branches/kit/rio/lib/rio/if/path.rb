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

    # Returns the path for the Rio, which is defined differently for different types of Rios.
    #
    # For Rios representing paths on the underlying file system this proxies URI::FILE#path or URI::Generic#path
    # depending on whether the Rio is absolute or not. Note that this is *not* the same as Rio#fspath, but rather
    # a URL path as defined in RFC 1738.
    #
    # For HTTP Rios this proxies this proxies URI::HTTP#path 
    #
    # For special Rios such as stdin: and stderr: this returns the special symbol used to create the Rio
    #
    # Specifically:
    #  '-' => stdio:
    #  '=' => stderr:
    #  '?' => tempfile:
    #  '$' => stringio:
    #  '_' => sysio:
    #
    # This list of possible paths may not be comprehensive as new types of Rios are added, however,
    # A Rio should always return a path when the underlying object has a concept of a path and something
    # else that is reasonable for Rios that have no such concept
    # 
    def path(*args) target.path(*args) end
    
    def to_url() target.to_url end
    def to_uri() target.to_uri end

    # Returns the path for the Rio on the underlying file system
    # Returns nil if the Rio is not on the filesystem (i.e. stdin: or http: Rios)
    def fspath(*args) target.fspath(*args) end

    # Proxy for File#expand_path
    #
    # Converts a pathname to an absolute pathname. 
    # Relative paths are referenced from the current working directory of the process 
    # unless dir_string is given, in which case it will be used as the starting point. 
    # The given pathname may start with a ``~’’, which expands to the process owner’s 
    # home directory (the environment variable HOME must be set correctly). 
    # ``~user’’ expands to the named user’s home directory.
    #
    # Returns a Rio representing the returned path
    #
    # 
    def expand_path(*args) target.expand_path(*args) end


    # Returns a new rio with a path equal to the absolute path of this rio
    #
    #  rio('/tmp').chdir
    #  rio('afile').abs # => rio('/tmp/afile')
    def abs(*args) target.abs(*args)  end


    # Returns a new rio with a path equal to the relative path from _other_
    #  rio('/tmp/afile').rel('/tmp')   #=> rio('afile')
    #  rio('zippy/afile').rel('zippy') #=> rio('afile')
    #
    def rel(other) target.rel(other)  end


    # Sets the string that the Rio considers an extension. The value will be used by
    # subsequent calls to Rio#basename. If called with no arguments resets its value
    # to the value returned by File#extname. Returns the Rio
    #  ario = rio('afile.txt')
    #  ario.ext('.txt').basename        #=> rio('afile')
    #  ario.ext('.zip').basename        #=> rio('afile.txt')
    #  ario.ext.basename                #=> rio('afile')
    #  ario.ext('').basename            #=> rio('afile.txt')
    # See also Rio#ext,Rio#ext?,Rio#filename,
    #
    def ext(arg=nil) target.ext(arg); self end


    # Identical to Rio#ext('')
    # See Rio#ext
    #  ario.basename                  #=> rio('afile')
    #  ario.noext.basename            #=> rio('afile.txt')
    #
    def noext() target.noext(); self end


    # Returns the value of the Rio's 'ext' variable
    # This defaults to the value returned by Rio#extname and may be set by either calling Rio#ext 
    # or by passing an argument Rio#basename
    # See also Rio#basename, Rio#ext, Rio#extname, Rio#noext
    #
    #  ario = rio('afile.txt')
    #  ario.ext?                        #=> '.txt'
    #  ario.ext('.txt').basename        #=> rio('afile')
    #  ario.ext?                        #=> '.txt'
    #  ario.ext('.zip').basename        #=> rio('afile.txt')
    #  ario.ext?                        #=> '.zip'
    #  ario.basename('.tar')            #=> rio('afile.txt')
    #  ario.ext?                        #=> '.tar'
    #  ario.ext.basename                #=> rio('afile')
    #  ario.ext?                        #=> '.txt'
    #  ario.noext.basename              #=> rio('afile.txt')
    #  ario.ext?                        #=> ''
    #
    def ext?() target.ext?() end


    # Similar to File#basename
    #
    # Returns a Rio whose path is that returned by File#basename when passed the path
    # of a rio and the value returned by File#extname. This differs from the behaviour
    # of File#basename.
    #  File.basename('afile.txt')                           #=> 'afile.txt'
    #  File.basename('afile.txt',File.extname('afile.txt')) #=> 'afile'
    #  rio('afile.txt').basename                            #=> rio('afile')
    #  rio('afile.txt').basename('.txt')                    #=> same thing
    #  rio('afile.txt').ext('.txt').basename                #=> same thing
    # See also Rio#ext,Rio#ext?,Rio#filename,
    def basename(*args) target.basename(*args) end


    # Calls File#dirname
    #
    # Returns a new Rio referencing the directory portion of a Rio.
    #    rio('/tmp/zippy.txt').dirname   #=> rio('/tmp')
    #
    def dirname(*args) target.dirname(*args) end


    # Calls File#extname
    #
    # Returns a String containing the path's extension
    #    rio('/tmp/zippy.txt').extname   #=> rio('.txt')
    #
    def extname(*args) target.extname(*args) end


    # Returns a new Rio with all path information stripped away. This is similar to
    # Rio#basename, except that it always includes an extension if one exists
    #
    #  rio('apath/afile.txt').filename #=> rio('afile.txt')
    #
    def filename() target.filename() end


    # Replace the part of the path returned by Rio#extname. If in +rename+
    # mode, also renames the referenced filesystem object.
    #
    # Returns the extension
    #
    #   ario = rio('dirA/dirB/afile.rb')
    #   ario.extname = '.txt'          # rio('dirC/bfile.txt')
    #
    #   rio('adir/afile.txt').rename.extname  = '.rb'      # adir/afile.txt => adir/afile.rb
    #
    # See Rio#extname, Rio#rename
    #
    def extname=(arg) target.extname = arg end


    # Replace the part of the path returned by Rio#basename. If in +rename+
    # mode, also renames the referenced filesystem object.
    # 
    # Returns the new value of +basename+
    #
    #   ario = rio('dirA/dirB/afile.rb')
    #   ario.dirname = 'dirC'          # rio('dirC/afile.rb')
    #   ario.basename = 'bfile'        # rio('dirC/bfile.rb')
    #   ario.extname = '.txt'          # rio('dirC/bfile.txt')
    #   ario.filename = 'cfile.rb'     # rio('dirC/cfile.rb')
    #
    #   rio('adir/afile.txt').rename.filename = 'bfile.rb' # adir/afile.txt => adir/bfile.rb
    #   rio('adir/afile.txt').rename.basename = 'bfile'    # adir/afile.txt => adir/bfile.txt
    #   rio('adir/afile.txt').rename.extname  = '.rb'      # adir/afile.txt => adir/afile.rb
    #   rio('adir/afile.txt').rename.dirname =  'b/c'      # adir/afile.txt => b/c/afile.txt
    #
    # See Rio#basename, Rio#rename
    #
    def basename=(arg) target.basename = arg end


    # Replace the part of the path returned by Rio#dirname. If in +rename+
    # mode, also renames the referenced filesystem object.
    # 
    # Returns the new value of +dirname+
    #
    #   ario = rio('dirA/dirB/afile.rb')
    #   ario.dirname = 'dirC'          # rio('dirC/afile.rb')
    #   ario.basename = 'bfile'        # rio('dirC/bfile.rb')
    #   ario.extname = '.txt'          # rio('dirC/bfile.txt')
    #   ario.filename = 'cfile.rb'     # rio('dirC/cfile.rb')
    #
    #   rio('adir/afile.txt').rename.filename = 'bfile.rb' # adir/afile.txt => adir/bfile.rb
    #   rio('adir/afile.txt').rename.basename = 'bfile'    # adir/afile.txt => adir/bfile.txt
    #   rio('adir/afile.txt').rename.extname  = '.rb'      # adir/afile.txt => adir/afile.rb
    #   rio('adir/afile.txt').rename.dirname =  'b/c'      # adir/afile.txt => b/c/afile.txt
    #
    # See Rio#dirname, Rio#rename
    #
    def dirname=(arg) target.dirname  = arg end



    # Replace the part of the path returned by Rio#filename. If in +rename+
    # mode, also renames the referenced filesystem object.
    # 
    # Returns the new value of +filename+
    #
    #   ario = rio('dirA/dirB/afile.rb')
    #   ario.dirname = 'dirC'          # rio('dirC/afile.rb')
    #   ario.basename = 'bfile'        # rio('dirC/bfile.rb')
    #   ario.extname = '.txt'          # rio('dirC/bfile.txt')
    #   ario.filename = 'cfile.rb'     # rio('dirC/cfile.rb')
    #
    #   rio('adir/afile.txt').rename.filename = 'bfile.rb' # adir/afile.txt => adir/bfile.rb
    #   rio('adir/afile.txt').rename.basename = 'bfile'    # adir/afile.txt => adir/bfile.txt
    #   rio('adir/afile.txt').rename.extname  = '.rb'      # adir/afile.txt => adir/afile.rb
    #   rio('adir/afile.txt').rename.dirname =  'b/c'      # adir/afile.txt => b/c/afile.txt
    #
    # See Rio#filename, Rio#rename
    #
    def filename=(arg) target.filename = arg end


    # Creates new Rio by adding args as additional directory components like File#join.
    #
    #   ario = rio('adir')
    #   brio = rio('b')
    #   crio = ario.join(brio)    #=> rio('adir/b')
    #
    #   ario = rio('adir')
    #   ario.join('b','c','d')    #=> rio('ario/b/c/d')
    #
    # See also Rio#/
    def join(*args) target.join(*args) end


    # Creates an array of Rios, one for each path element. 
    # (Note that this behavior differs from File#split.)
    #
    #  rio('a/b/c').split   #=> [rio('a'),rio('b'),rio('c')]
    #
    # The array returned is extended with a +to_rio+ method, 
    # which will put the parts back together again.
    #
    #  ary = rio('a/b/c').split   #=> [rio('a'),rio('b'),rio('c')]
    #  ary.to_rio           #=> rio('a/b/c')
    #
    #  ary = rio('a/b/c').split   #=> [rio('a'),rio('b'),rio('c')]
    #  ary[1] = rio('d')
    #  ary.to_rio           #=> rio('a/d/c')
    #
    # See also Rio#join, Rio#/
    def split() target.split() end


    # Subdirectory operator.
    #
    # Effectively the same as Rio#join(arg)
    #
    #   a = rio('a')
    #   b = rio('b')
    #   c = a/b          #=> rio('a/b')
    #
    #   ario = rio('adir')
    #   ario/'afile.rb'           #=> rio('ario/afile.rb')
    #   ario/'b'/'c'/'d'          #=> rio('ario/b/c/d')
    #   
    #   ario = rio('adir')
    #   ario /= 'afile.rb'           #=> rio('ario/afile.rb')
    #   
    def /(arg) target / arg end


    # Create a Rio referencing Rio#to_s + arg.to_s
    #
    def +(arg) target + arg end

    # Create a new Rio referencing the result of applying String#sub to the value returned by
    # Rio#to_s
    def sub(re,string) target.sub(re,string) end

    # Create a new Rio referencing the result of applying String#gsub to the value returned by
    # Rio#to_s
    def gsub(re,string) target.gsub(re,string) end


    # Rio#catpath!
    #
    #
    #def catpath!(*args) target.catpath!(*args); self end


    # Rio#catpath
    #
    #
    #def catpath(*args) target.catpath(*args) end


    # Changes a Rio inplace by adding args as additional directory components like Rio#join,
    #
    def join!(*args) target.join!(*args); self end

    # Rio#rootpath
    #
    #
    def rootpath(*args) target.rootpath(*args) end


    # Rio#root
    #
    #
    ##def root(*args,&block) target.root(*args,&block) end


    # Rio#cwd
    #
    #
    ##def cwd(*args,&block) target.cwd(*args,&block) end


    # Rio#getwd
    #
    #
    ##def getwd(*args,&block) target.getwd(*args,&block) end


    # Rio#base
    #
    #
    def base() target.base()  end


    # Returns the scheme for Rio's URI like URI#scheme where the Rio is represented
    # by a standard URI. For Rios that are not represented by standard URIs one of
    # Rio's non-standard schemes's is returned. 
    #
    #  rio('http://ruby-doc.org/') #=> 'http'
    #
    def scheme(*args) target.scheme(*args) end

    # Proxy for URI#host
    #
    #  rio('http://ruby-doc.org/') #=> 'ruby-doc'
    #
    def host(*args) target.host(*args) end

    # Proxy for URI#opaque
    #
    def opaque(*args) target.opaque(*args) end



    # Proxy for URI#merge
    # 
    # Merges to Rios. URI#merge does not document exactly what merging to URIs means. This appears to
    # join the the paths with like <tt>other + path</tt>. See URI#merge for less information.
    #
    #
    def merge(other) target.merge(other)  end


    # Proxy for URI#route_from
    #
    # Returns a new rio representing the path to this Rio from the perspective of _other_.
    # URI#route_from requires that absolute URIs be used. Rio#route_from does not.
    #
    def route_from(other) target.route_from(other)  end

    # Proxy for URI#route_to
    #
    # Returns a new rio representing the path to _other_ from the perspective of this Rio.
    # URI#route_to requires that absolute URIs be used. Rio#route_to does not.
    #
    def route_to(other) target.route_to(other)  end


  end
end
