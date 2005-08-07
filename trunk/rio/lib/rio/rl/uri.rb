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
      attr_writer :base
      def initialize(u,*args)
        #p callstr('initialize',u,*args)
        # u should be a ::URI or something that can be parsed to one
        args = get_base(*args)
        @uri =  _mkuri(u)
        self.join(*args)
        @uri.path = '/' if @uri.absolute? and @uri.path == ''
      end
      def initialize_copy(*args)
        #p callstr('initialize_copy',*args)

        super
        @uri = @uri.clone unless @uri.nil?
        @base = @base.clone unless @base.nil?
      end
      def _mkuri(arg)
        (arg.kind_of?(::URI) ?  arg.dup : parse_url(arg.to_s))
      end
      def base(arg=nil)
        @base = _mkuri(arg) unless arg.nil? or @uri.absolute?
        (@base.nil? ? @uri : @base)
      end
      def join(*args)
#        self.class.joinuri(self.uri,*args)
        return @uri if args.empty?
        sa = args.map(&:to_s).map { |str| ::URI.escape(str,ESCAPE) }
        sa.unshift @uri.path unless @uri.path.empty?
        @uri.path = sa.join('/')
        @uri.path.gsub!(%r|/+|,'/')
      end

      def parse_url(str)
        ::URI.parse(::URI.escape(str,ESCAPE))
      end

      def url() self.uri.to_s end
      def fs2url(pth) RL.fs2url(pth) end
      def url2fs(pth) RL.url2fs(pth) end
      def fspath() RL.url2fs(@uri.path) end

      def route_from(other)
        self.class.new(@uri.route_from(other.uri),other)
      end
      def route_to(other)
        self.class.new(@uri.route_to(other.uri),self.abs)
      end
      def merge(other)
        self.class.new(@uri.merge(other.uri))
      end
      def get_base(*args)
        #      args.each { |a| p "get_base len=#{args.length} #{a.class}##{a.to_s}" }
        @base = nil
        if args.length > 0
          b = args.pop
          @base = case b
                  when URIBase then  b.uri if b.uri.absolute?
                  when ::URI then b if b.absolute?
                  when ::String then  ::URI.parse(b) if b  =~ /^[a-z]+:/
                  end
          args.push b unless @base
        end
        args
      end
      def abs()
        return self if @uri.absolute?
        self.class.new(@base.merge(@uri),@base) 
      end
      def path_no_slash
        path.sub(/\/$/,'')
      end
      def path=(pt)
        @uri.path = pt
      end
      extend Forwardable
      def_instance_delegators(:@uri,:to_s,:path,:absolute?,:host)
      alias abs? absolute?
    end
  end
end
