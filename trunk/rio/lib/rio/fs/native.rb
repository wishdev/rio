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
  module FS #:nodoc: all
    module File
      def fnmatch?(s,globstr,*flags) @file.fnmatch?(globstr,s,*flags) end
      def expand_path(s,*args) @file.expand_path(s,*args) end
      def extname(s,*args) @file.extname(s,*args) end

      def basename(s,*args) @file.basename(s,*args) end
      def dirname(s,*args) @file.dirname(s,*args) end
      def join(s,*args) @file.join(s,*args) end


      def ftype(s,*args) @file.ftype(s,*args) end
      def symlink(s,d) @file.symlink(s.to_s,d.to_s) end

      def stat(s,*args) @file.stat(s,*args) end

      def atime(s,*args) @file.atime(s,*args) end
      def ctime(s,*args) @file.ctime(s,*args) end
      def mtime(s,*args) @file.mtime(s,*args) end

      def chmod(mod,s) @file.chmod(mod,s.to_s) end
      def chown(owner_int,group_int,s) @file.chown(owner_int,group_int,s.to_s) end

      def readlink(s,*args) @file.readlink(s,*args) end
      def lstat(s,*args) @file.lstat(s,*args) end
      
    end
    module Dir
      def rmdir(s) @dir.rmdir(s.to_s) end
      def mkdir(s,*args) @dir.mkdir(s.to_s,*args) end
      def chdir(s,&block) @dir.chdir(s.to_s,&block) end
      def foreach(s,&block) @dir.foreach(s.to_s,&block) end
      def entries(s) @dir.entries(s.to_s) end
      def glob(gstr,*args,&block) @dir.glob(gstr,*args,&block) end
    end
    module Test
      def blockdev?(s,*args) @test.blockdev?(s,*args) end
      def chardev?(s,*args) @test.chardev?(s,*args) end
      def directory?(s,*args) @test.directory?(s,*args) end
      def dir?(s,*args) @test.directory?(s,*args) end
      def executable?(s,*args) @test.executable?(s,*args) end
      def executable_real?(s,*args) @test.executable_real?(s,*args) end
      def exist?(s,*args) @test.exist?(s,*args) end
      def file?(s,*args) @test.file?(s,*args) end
      def grpowned?(s,*args) @test.grpowned?(s,*args) end
      def owned?(s,*args) @test.owned?(s,*args) end
      def pipe?(s,*args) @test.pipe?(s,*args) end
      def readable?(s,*args) @test.readable?(s,*args) end
      def readable_real?(s,*args) @test.readable_real?(s,*args) end
      def setgid?(s,*args) @test.setgid?(s,*args) end
      def setuid?(s,*args) @test.setuid?(s,*args) end
      def size(s,*args) @test.size(s,*args) end
      def size?(s,*args) @test.size?(s,*args) end
      def socket?(s,*args) @test.socket?(s,*args) end
      def sticky?(s,*args) @test.sticky?(s,*args) end
      def symlink?(s,*args) @test.symlink?(s,*args) end
      def writable?(s,*args) @test.writable?(s,*args) end
      def writable_real?(s,*args) @test.writable_real?(s,*args) end
      def zero?(s,*args) @test.zero?(s,*args) end
    end
    module Path
      require 'pathname'
      def root?(s) @path.new(s).root? end
      def mountpoint?(s) @path.new(s).mountpoint? end
      def realpath(s) @path.new(s).realpath end
      def cleanpath(s,*args) @path.new(s).cleanpath(*args) end
    end
    module Util
      # Directory stuff
      def cp_r(s,d)  @util.cp_r(s.to_s,d.to_s) end
      def rmtree(s) @util.rmtree(s.to_s) end
      def mkpath(s) @util.mkpath(s.to_s) end
      def rm(s) @util.rm(s.to_s) end
      def touch(s) @util.touch(s.to_s) end

      # file or dir
      def mv(s,d) @util.mv(s.to_s,d.to_s) end
    end
  end
end
module RIO
  module FS
    class Base
      def rootdir()
        require 'rio/local'
        ::RIO::Local::ROOT_DIR        
      end
    end
  end
end
module RIO
  module FS
    class Native < Base
      require 'singleton'
      include Singleton
      attr_reader :file,:dir
      def initialize(*args)
        @file = ::File
        @test = ::FileTest
        @dir  = ::Dir
        require 'pathname'
        @path = ::Pathname
        require 'fileutils'
        @util = ::FileUtils
      end

      def self.create(*args)
        instance(*args)
      end
      include File
      include Dir
      include Path
      include Test
      include Util

    end
  end
end
module RIO
  module FS
    class Other < Base
      def initialize(*args)
        @file = ::File
        @test = ::FileTest
        @path = ::Pathname
        @dir  = ::Dir
        @util = ::FileUtils
      end

      def self.create(*args)
        new(*args)
      end

      include File
      include Dir
      include Path
      include Test
      include Util

    end
  end
end
module RIO
  module FS
    class ZipFile < Base
      attr_reader :file,:dir
      def initialize(zipfile)
        require 'rubygems'
        require 'zip/zip'
        require 'zip/zipfilesystem'
        @zipfile = case zipfile 
                   when ::Zip::ZipFile 
                     zipfile
                   else
                     ::Zip::ZipFile.new(zipfile.to_s,::Zip::ZipFile::CREATE)
                   end
        @file = @test = @zipfile.file
        require 'pathname'
        @path = ::Pathname
        @dir  = @zipfile.dir
        require 'fileutils'
        @util = ::FileUtils
      end

      def self.create(*args)
        new(*args)
      end

      include File
      include Dir
      include Path
      include Test
      include Util

    end
  end
end
