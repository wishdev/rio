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

require 'rio/fs/base'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'rio/scheme/path'

module RIO
  module ZipFile
    class CentralDir
      include Enumerable

      def initialize(zipfile)
        @zipfile = zipfile
        #puts @zipfile.methods.sort
        topents = {}
        @zipfile.entries.map{ |ent|
          top = ent.to_s.match(%r|^(/?[^/]+(/)?)|)[1]
          topents[top] = ent if top == ent.to_s
        }
        fs = RIO::ZipFile::FS::InFile.new(@zipfile)
        @topents = topents.values.map{ |v| rio(RIO::Path::RL.new(v.to_s,{:fs => fs})) }
        @entidx = 0
      end
#      def method_missing(sym,*args,&block)
#        @zipfile.__send__(sym,*args,&block)
#      end
      def read
        return nil if @entidx >= @topents.size
        @entidx += 1
        @topents[@entidx-1]
      end
      def rewind
        @entidx = 0
      end
      def each(&block)
        @topents.each { |ent|
          yield ent
        }
      end
      def close
      end
    end
    module FS
      class Base < RIO::FS::Base
      end
      class InFile < Base
        attr_reader :file,:dir
        def initialize(zipfile)
          @zipfile = zipfile
          @file = @zipfile.file
          @dir = @zipfile.dir
          @test = @zipfile.file
        end
        include RIO::FS::File
        include RIO::FS::Dir
        include RIO::FS::Test
        include RIO::FS::Str
      end
      
      class CentralDir < RIO::FS::Native
        def initialize(zipfilepath)
          @zipfilepath = zipfilepath
          @zipfile = Zip::ZipFile.new(@zipfilepath)
          super
        end
        def mkdir(path)
          @zipfile.mkdir(path)
        end
        def rmdir(path)
          @zipfile.remove(path)
        end
        def file()
          self
        end
        def open(zipfilepath)
          @zipfilepath = zipfilepath
          @zipfile = Zip::ZipFile.new(@zipfilepath)
          RIO::ZipFile::CentralDir.new(@zipfile)
        end

      end

    end
  end
end
