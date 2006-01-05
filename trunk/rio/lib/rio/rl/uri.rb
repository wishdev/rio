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


require 'rio/rl/base'
module RIO
  module RL
    class URIBase < Base
      attr_reader :uri
      SCHEME = URI::REGEXP::PATTERN::SCHEME
      def initialize(u,*args)
        #p callstr('initialize',u,*args)
        # u should be a ::URI or something that can be parsed to one
        args = _get_base_from_args(args)
        @uri =  _mkuri(u)
        self.join(*args)
        @uri.path = '/' if @uri.absolute? and @uri.path == ''
      end
      def initialize_copy(*args)
        super
        @uri = @uri.clone unless @uri.nil?
        @base = @base.clone unless @base.nil?
      end
      def _get_base_from_args(args)
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
      def pathroot() '/' end
      def _mkuri(arg)
        (arg.kind_of?(::URI) ?  arg.dup : parse_url(arg.to_s))
      end
      def base(arg=nil)
        self.base = arg unless arg.nil? or @uri.absolute?
        @base || @uri
      end
      def base=(arg) @base = _mkuri(arg) end
      require 'rio/rl/pathmethods'
      include PathMethods

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

      def abs()
        return self if absolute?
        self.class.new(@base.merge(@uri),{:base => @base}) 
      end

      def url() @uri.to_s end
      def to_s() self.url end

    end
  end
end
