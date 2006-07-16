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


require 'net/ftp'
require 'uri'
require 'singleton'

module RIO
  module FTP
    class Connection
      attr_reader :uri
      def initialize(uri)
        @uri = uri.clone
        @netftp = nil
        @remote_root = nil
        _init_connection()
      end
      def _init_connection
        @netftp = ::Net::FTP.new()
        #p 'Connecting'
        @netftp.connect(@uri.host,@uri.port)
        #p "Logging In"
        if @uri.user
          @netftp.login(@uri.user,@uri.password)
        else
          @netftp.login
        end
        @remote_root = @netftp.pwd
      end
      def netftp()
        #_init_connection() unless @netftp
        @netftp
      end
      def remote_root
        #_init_connection() unless @netftp
        @remote_root
      end
      def method_missing(sym,*args,&block)
        #_init_connection() unless @netftp
        @netftp.__send__(sym,*args,&block)
      end
    end
    class ConnCache
      include Singleton
      def initialize()
        @conns = {}
        @count = {}
      end
      def urikey(uri)
        key_uri = uri.clone
        key_uri.path = ''
        key_uri.to_s
      end
      def connect(uri)
        key = urikey(uri)
        unless @conns.has_key?(key)
          @conns[key] = Connection.new(uri)
          @count[key] = 0
        end
        @count[key] += 1
        @conns[key]
      end
      def close(uri)
        key = urikey(uri)
        @count[key] -= 1
        #p "Closed #{uri} count=#{@count[key]}"
      end
    end
  end
end
