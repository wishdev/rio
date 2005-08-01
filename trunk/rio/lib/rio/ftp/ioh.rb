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


require 'net/ftp'
require 'rio/ioh'
module RIO
  module FTP
    class IOH < RIO::IOH::Base
      def each(&block)
        names.each do |s|
          yield s
        end
        self
      end
      def close()
        @ios.close unless closed?
        @ios = nil
      end
      def closed?() @ios.nil? end
      def chdir(dir,&block)
        if block_given?
          wd = @ios.pwd
          @ios.chdir(dir) unless dir == wd
          rtn = yield self
          @ios.chdir(wd)  unless dir == wd
          return rtn
        else
          @ios.chdir(dir)
        end
        self
      end
      def list()
        @ios.list
      end
      def nlst()
        @ios.nlst
      end
      def names()
        begin
          @ios.nlst
        rescue ::Net::FTPTempError
          []
        end
      end
      extend Forwardable
      def_instance_delegators(:handle,:pwd,:mkdir,:rename,:put,:delete,:rmdir,:mdtm,:mtime,:root_dir)

      def callstr(func,*args)
        self.class.to_s+'['+self.to_s+']'+'.'+func.to_s+'('+args.join(',')+')'
      end
      
    end
  end
end
