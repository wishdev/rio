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


require 'rio/rl/uri'
module RIO
  module RL
    class PathBase < Base
      RESET_STATE = 'Path::Reset'

      RIOSCHEME = 'path'

      def initialize(pth,*args)
        @host = nil
        case pth
        when ::URI
          @uri = pth.dup
          @uri.path = '/' if pth.absolute? and pth.path == ''
          @pth = @uri.path
        when %r|^file://(localhost)?(/.*)?$|
          @host = $1
          @pth = $2 || '/'
        else
          @pth = pth
          @uri= nil
        end
        if !args.empty? and args[-1].kind_of?(::Hash) and (b = args.pop['base'])
          @wd = case b
                when %r%^file://(localhost)?(/.*)?$% then $2 || '/'
                when %r%^/% then b
                else RL.fs2url(::Dir.getwd)+'/'+b
                end
          @wd.squeeze('/')
        end
        self.join(*args) unless args.empty?
        @wd = RL.fs2url(::Dir.getwd)+'/' unless @wd
      end

      def parse_url(str)
        ::URI.parse(::URI.escape(str,ESCAPE))
      end

      def initialize_copy(*args)
        super
        @uri = nil
      end

      def init_paths()
        @uri = nil
      end
      def path=(pt)
        @uri = nil
        @pth = pt
      end
      def join(*args)
        return self if args.empty?
        sa = args.map(&:to_s).map { |s| ::URI.escape(s,ESCAPE) }
        sa.unshift(@pth) unless @pth.empty?
        @uri = nil
        @pth = sa.join('/').squeeze('/')
      end
      
      def uri() 
        @uri ||= (absolute? ? ::URI::FILE.new('file',nil,@host,nil,nil,@pth,nil,nil,nil) : ::URI.parse(@pth))
      end
      def url() 
        if uri and uri.scheme
          self.uri.to_s 
        else
          self.scheme+SUBSEPAR+self.opaque 
        end
      end
      def to_s() RL.url2fs(@pth) end

      def self.splitrl(s)
        sch,opq,whole = split_riorl(s)
        case sch
        when 'file' then [whole]
        else [opq]
        end
      end
      def scheme() (absolute? ? 'file' : 'path') end
      def opaque() (absolute? ? "//#{@host}#{@pth}" : @pth) end
      def fspath() RL.url2fs(@pth) end
      def fs2url(pth) RL.fs2url(pth) end
      def url2fs(pth) RL.url2fs(pth) end
      def wd=(wd) @wd = wd end
      def route_from(other)
        rfrl = self.class.new(uri.route_from(other.uri))
        rfrl.wd = other.path
        rfrl
      end
      def route_to(other)
        rtrl = self.class.new(uri.route_to(other.uri))
        rtrl.wd = self.abs
        rtrl
      end
      def merge(other)
        self.class.new(uri.merge(other.uri))
      end
      def base(arg=nil) 
        unless arg.nil?
          self.wd = arg
        end
        (absolute? ? @pth : @wd) 
      end

      def abs()
        return self if absolute?
        self.class.new(@wd + @pth) 
      end
      def path_no_slash() @pth.sub(/\/$/,'') end
      def path() @pth end
      def absolute?() @pth[0] == ?/ end
      def host() @host ||= uri.host end
      alias abs? absolute?

    end
  end
end
