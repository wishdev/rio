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


require 'rio/rl/base'
require 'rio/rl/withpath'
require 'rio/fs/url'
require 'rio/fs/native'
require 'rio/uri/file'

module RIO
  module RL
    class URIBase < WithPath
      SCHEME = URI::REGEXP::PATTERN::SCHEME
      HOST = URI::REGEXP::PATTERN::HOST

      attr_accessor :uri
      def initialize(u,*args)
        # u should be a ::URI or something that can be parsed to one
        #p callstr('initialize',u,*args)
        @base = nil

        args = _get_opts_from_args(args)
        _init_from_args(u,*args)
        super
        unless self.absolute? or @base
          @base = ::URI::parse('file://'+RL.fs2url(fs.getwd)+'/')
        end
        @uri.path = '/' if @uri.absolute? and @uri.path == ''
      end
      def initialize_copy(*args)
        super
        @uri = @uri.clone unless @uri.nil?
        @base = @base.clone unless @base.nil?
      end
      def absolute?()
        uri.absolute?
      end
      alias :abs? :absolute?
      def openfs_()
        #p callstr('openfs_')
        @fs || RIO::FS::Native.create()
      end
      def url()
        self.uri.to_s
      end
      def to_s()
        self.url
      end
      def urlpath() uri.path end
      def urlpath=(arg) uri.path = arg end
      def path()
        case scheme
        when 'file','path' then fspath()
        else urlpath()
        end
      end
      def scheme() uri.scheme end
      def host() uri.host end
      def host=(arg) uri.host = arg end
      def opaque()
        u = uri.clone
        u.query = nil
        u.to_s.sub(/^#{SCHEME}:/,'')
      end
      def pathroot()
        u = uri.clone
        u.query = nil
        case scheme
        when 'file'
          if self.urlpath =~ %r%^(/[a-zA-Z]):% then $1+':/'
          else '/'
          end
        else
          u.path = '/'
          u.to_s
        end
      end
      def urlroot()
        return nil unless absolute?
        cp = self.clone
        cp.urlpath = self.pathroot
        cp.url
      end
      def base()
        @base || self.uri
      end
      def base=(arg)
        #p "uri.rb:base= arg=#{arg.inspect}"
        @base = _uri(arg)
      end
      def _init_from_args(arg0,*args)
        #p "_get_base: #{arg0.inspect}"
        vuri,vbase,vfs = nil,nil,nil
        case arg0
        when RIO::Rio
          return _init_from_arg(arg0.rl)
        when URIBase
          vuri,vbase,vfs = arg0.uri,arg0.base,arg0.fs
        when ::URI 
          vuri = arg0
        when ::String 
          vuri = uri_from_string_(arg0) || ::URI.parse(arg0)
        else
          raise(ArgumentError,"'#{arg0}'[#{arg0.class}] can not be used to create a Rio")
        end

        @uri = vuri
        self.join(*args)
        @base = vbase unless @base or vbase.nil?
        fs = vfs if vfs 
      end
      def _get_base_from_arg(arg)
        #p "_get_base: #{arg.inspect}"
        case arg
        when RIO::Rio
          arg.abs.to_uri
        when URIBase
          arg.abs.uri
        when ::URI 
          arg if arg.absolute?
        when ::String 
          uri_from_string_(arg) || ::URI.parse([RL.fs2url(::Dir.getwd+'/'),arg].join('/').squeeze('/'))
        else
          raise(ArgumentError,"'#{arg} is not a valid base path")
        end
      end
      def _get_opts_from_args(args)
        if !args.empty? and args[-1].kind_of?(::Hash) 
          opts = args.pop
          if b = opts[:base]
            @base = _get_base_from_arg(b)
            #@base.path.sub!(%r{/*$},'/')
          end
          if fs = opts[:fs]
            @fs = fs
          end
        end
        args
      end
    end
  end
end

module RIO
  module RL
    class URIBase0 < WithPath
      SCHEME = URI::REGEXP::PATTERN::SCHEME
      attr_reader :uri
      #attr :fs
      def initialize(u,*args)
        #p callstr('initialize',u,*args)
        # u should be a ::URI or something that can be parsed to one
        args = _get_opts_from_args(args)
        @uri =  _mkuri(u)
        self.join(*args)
        @uri.path = '/' if @uri.absolute? and @uri.path == ''
        super
      end
      def initialize_copy(*args)
        super
        @uri = @uri.clone unless @uri.nil?
        @base = @base.clone unless @base.nil?
      end
      def _get_opts_from_args(args)
        #      args.each { |a| p "get_base len=#{args.length} #{a.class}##{a.to_s}" }
        @base = nil
        if !args.empty? and args[-1].kind_of?(::Hash) and (b = args.pop[:base])
          @base = case b
                  when URIBase then  b.uri if b.uri.absolute?
                  when ::URI then b if b.absolute?
                  when ::String then  ::URI.parse(b) if b  =~ /^#{SCHEME}:/
                  end
        end
        args
      end
      def _mkuri(arg)
        (arg.kind_of?(::URI) ?  arg.dup : parse_url(arg.to_s))
      end


      def openfs_()
        RIO::FS::URL.create()
      end

      def pathroot() '/' end
      def base(arg=nil)
        self.base = arg unless arg.nil? or @uri.absolute?
        @base || @uri
      end
      def base=(arg) @base = _mkuri(arg) end
      require 'rio/rl/pathmethods'
      include PathMethods

      def fspath() RL.url2fs(self.urlpath) end

      def urlpath=(pt) @uri.path = pt end


      def urlpath() @uri.path end

      def path=(pt) self.urlpath = pt end
      def path() self.urlpath end
      def path_no_slash() self.path.sub(/\/$/,'') end

      def opaque() 
        u = @uri.dup
        u.scheme = nil
        u.to_s
      end

      def scheme() @uri.scheme end
      def host() @uri.host end
      def host=(arg) @uri.host = arg end

      def absolute?() @uri.absolute? end
      alias abs? absolute?

      def abs(base=nil)
        base ||= @base
        absuri = calc_abs_uri_(@uri.to_s,base.to_s) 
        RIO::RL::Builder.build(absuri)
      end

      def url() @uri.to_s end
      def to_s() self.url end

    end
  end
end
