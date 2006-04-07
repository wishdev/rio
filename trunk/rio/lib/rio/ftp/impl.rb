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


require 'net/ftp'
require 'rio/fs/base'
require 'rio/fs/impl'
require 'rio/ftp/conn'
module RIO
  module FTP
    module Impl
      class Dir
        def initialize(uri)
          @conn = RIO::FTP::Conn.new(uri)
        end
        def rmdir(s) @conn.rmdir(s) end
        def mkdir(s,*args) @conn.mkdir(s,*args) end
        def chdir(s,&block) @conn.chdir(s,&block) end
      end
      class Test
        FTYPES = %w{file dir nada}
        def initialize(uri)
          @conn = RIO::FTP::Conn.new(uri)
          @ftype = nil
        end
        def _ftype(file_name)
          fname = URI(file_name).path
          @ftype ||= @conn.get_ftype(fname)
        end
        def exist?(file_name)   
          _ftype(file_name) != 'nada'
        end
        def directory?(file_name)   
          _ftype(file_name) == 'dir'
        end
        def file?(file_name)   
          _ftype(file_name) == 'file'
        end
        def size(file_name)
          @conn.size(file_name)
        end
        def zero?(file_name)  
          size(file_name) == 0
        end

        def blockdev?(file_name)
          false
        end
        def chardev?(file_name)   
          false
        end
        def executable?(file_name)   
          false
        end
        def executable_real?(file_name)   
          false
        end
        def grpowned?(file_name)   
          false
        end
        def owned?(file_name)   
          false
        end
        def pipe?(file_name)   
          false
        end
        def readable?(file_name)   
          false
        end
        def readable_real?(file_name)   
          false
        end
        def setgid?(file_name)   
          false
        end
        def setuid?(file_name)   
          false
        end
        def socket?(file_name)   
          false
        end
        def sticky?(file_name)   
          false
        end
        def symlink?(file_name)   
          false
        end
        def writable?(file_name)   
          false
        end
        def writable_real?(file_name)   
          false
        end
      end
    end
  end
end
