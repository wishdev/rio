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


require 'rio/rl/uri'
require 'rio/rl/pathmethods'

module RIO
  module RL
    class PathBase < Base
      RESET_STATE = 'Path::Reset'

      RIOSCHEME = 'path'
      HOST = URI::REGEXP::PATTERN::HOST
      SCHEME = URI::REGEXP::PATTERN::SCHEME

      #attr :fs
      def initialize(pth,*args)

        @host = nil  # host or nil
        @fspath = nil
        case pth
        when ::Hash
          @host = pth[:host]
          @fspath = RL.url2fs(pth[:path])
          @base = pth[:base]
        when RL::Base
          @host = pth.host
          @fspath = RL.url2fs(pth.path)
          @base = pth.base
        when ::URI
          u = pth.dup
          u.path = '/' if pth.absolute? and pth.path == ''
          @fspath = RL.url2fs(u.path)
          @host = u.host
        when %r|^file://(#{HOST})?(/.*)?$|
          @host = $1 || ''
          @fspath = $2 ? RL.url2fs($2) : '/'
        else
          self.fspath = pth
        end
        args = _get_opts_from_args(args)
        self.join(*args) unless args.empty?
        unless self.absolute? or @base
          @base = RL.fs2url(::Dir.getwd)+'/'
        end
        @fspath.sub!(%r|/\.$|,'/')
        #@fs = openfs_ 
        super
      end
      def openfs_
        RIO::FS::Native.create()
      end
      def pathroot()
        return nil unless absolute?
        rrl = self.clone
        if self.urlpath =~ %r%^(/[a-zA-Z]):%
          $1+':/'
        else
          '/'
        end
      end
      include PathMethods

      def _get_opts_from_args(args)
        @base = nil
        if !args.empty? and args[-1].kind_of?(::Hash) 
          opts = args.pop
          if b = opts[:base]
            @base = case b
                    when %r%^file://(#{HOST})?(/.*)?$% then b
                    when %r%^/% then b
                    else RL.fs2url(::Dir.getwd)+'/'+b
                    end
            @base.squeeze('/')
          end
          if fs = opts[:fs]
            @fs = fs
          end
        end
        args
      end
      def base(arg=nil) 
        self.base = arg unless arg.nil?
        if absolute? 
          #p self.dirname
          urlpath 
        else
          @base
        end
      end
      def base=(arg) @base = arg end

#      def urlpath() @pth end
#      def urlpath=(arg) @pth = arg end
      def urlpath() RL.fs2url(@fspath) end
      def urlpath=(arg) @fspath = RL.url2fs(arg) end

      def path() self.fspath() end
      def path=(arg) self.fspath = arg end
      def path_no_slash() self.path.sub(/\/$/,'') end
      def use_host?
        !(@host.nil? || @host.empty? || @host == 'localhost')
      end

      def fspath() 
        if use_host?
          '//' + @host + @fspath
        else 
          @fspath
        end
      end
      def fspath=(pt)
        if pt =~ %r|^//(#{HOST})(/.*)?$|
          @host = $1
          @fspath = $2 || '/'
        else
          @fspath = pt
        end
      end

      def opaque() (absolute? ? "//#{@host}#{self.urlpath}" : self.urlpath) end

      def scheme() (absolute? ? 'file' : 'path') end
      def host() @host end
      def host=(arg) @host = arg end

      def absolute?() 
        (@fspath =~ %r%^([a-zA-Z]:)?/%  ? true : false)
      end
      alias abs? absolute?

      def abs()
        return self if absolute?
        self.class.new(@base, @fspath) 
      end
    
      def uri() 
        (absolute? ? 
         ::URI::FILE.new('file',nil,@host,nil,nil,RL.fs2url(@fspath),nil,nil,nil) : ::URI.parse(RL.fs2url(@fspath)))
      end

      def self.splitrl(s)
        sch,opq,whole = split_riorl(s)
        case sch
        when 'file' then [whole]
        else [opq]
        end
      end


    end
  end
end
