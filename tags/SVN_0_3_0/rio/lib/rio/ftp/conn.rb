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
require 'uri'
require 'singleton'

module RIO
  module FTP
    module RootDir
      attr_reader :root_dir
    end
  end
end
module RIO
  module FTP
    class ConnCache
      include Singleton
      def initialize()
        @co = {}
        @ca = {}
      end
      def kuris(uri)
        curi = uri.clone
        curi.path = ''
        kuri = curi.to_s
        [kuri,curi]
      end
      def connect(uri)
        kuri,curi = kuris(uri)
        unless @co.has_key?(kuri)
          @co[kuri] = ::Net::FTP.new()
          @ca[kuri] = 0
        end
        c = @co[kuri]
        if c.closed?
          c.connect(curi.host,curi.port)
          if curi.user
            c.login(curi.user,curi.password)
          else
            c.login
          end
          wd = c.pwd
          c.instance_eval {
            @root_dir = wd
          }
          c.extend(RootDir)
        end
        @ca[kuri] += 1
        #@ca.each { |k,v| puts " FTPCC.connect: #{k}: #{v}" }
        c
      end
      def close(uri)
        kuri,curi = kuris(uri)

        if @ca.has_key?(kuri)
          @ca[kuri] -= 1
        end
        #@ca.each { |k,v| puts " FTPCC.close: #{k}: #{v}" }
      end
    end
  end
end
module RIO
  module FTP
    class Conn
      attr_accessor :uri
      def initialize(uri=nil)
        @uri = uri.clone || URI::FTP.new('ftp',nil,nil,nil,nil,nil,nil,nil,nil)
      end
      def connect(host, port = ::Net::FTP::FTP_PORT)
        @uri.host = host
        @uri.port = port
      end
      def login(user = 'anonymous',password = nil)
        unless user == 'anonymous' && password.nil?
          @uri.user = user
          @uri.password = password
        end
      end
      def chdir(dirname)
        @uri.path = dirname
        co = FTP::ConnCache.instance.connect(@uri)
        rd = co.root_dir
        rd = '' if rd == '/'
        co.chdir(rd + @uri.path)
      end
      def pwd()
        co = FTP::ConnCache.instance.connect(@uri)
        co.pwd
      end
      def root_dir()
        co = FTP::ConnCache.instance.connect(@uri)
        co.root_dir
      end
      def mdtm(filename)
        co = FTP::ConnCache.instance.connect(@uri)
        co.mdtm(filename)
      end
      def conndir()
        co = FTP::ConnCache.instance.connect(@uri)
        rd = co.root_dir
        rd = '' if rd == '/'
        co.chdir(rd + @uri.path)
        co
      end
      def put(src,dstname)
        conndir.put(src,dstname)
      end
      def rename(src,dstname)
        conndir.rename(src,dstname)
      end
      def delete(pth)
        conndir.delete(pth)
      end
      def rmdir(pth)
        conndir.rmdir(pth)
      end
      def list()
        conndir.list
      end
      def mkdir(dirname)
        conndir.mkdir(dirname)
      end
      def nlst()
        conndir.nlst
      end
      def close()
        FTP::ConnCache.instance.close(@uri)
      end
    end
  end
end
