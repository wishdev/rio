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
module RIO
  module RL
    module PathMethods
      def urlroot()
        return nil unless absolute?
        cp = self.clone
        cp.urlpath = self.pathroot
        cp.url
      end
      def _parts()
        pr = self.pathroot
        ur = self.urlroot.sub(/#{pr}$/,'')
        up = self.urlpath.sub(/^#{pr}/,'')

        [ur,pr,up]
      end
      def pathdepth()
        pth = self.path_no_slash
        (pth == '/' ? 0 : pth.count('/'))
      end
      def split()
        if absolute?
          parts = self._parts
          sparts = []
          sparts << parts[0] + parts[1]
          sparts += parts[2].split('/')
        else
          sparts = self.urlpath.split('/')
        end
        require 'rio/to_rio'
        rlparts = sparts.map { |str| self.class.new(str) }
        (1...sparts.length).each { |i|
          rlparts[i].base = rlparts[i-1].abs.url + '/'
        }
        rlparts
      end

      def join(*args)
        return self if args.empty?
        sa = args.map { |arg| ::URI.escape(arg.to_s,ESCAPE) }
        sa.unshift(self.urlpath) unless self.urlpath.empty?
        self.urlpath = sa.join('/').squeeze('/')
        self
      end

      def parse_url(str)
        ::URI.parse(::URI.escape(str,ESCAPE))
      end

      def route_from(other)
        self.class.new(uri.route_from(other.uri),{:base => other.url})
      end
      def route_to(other)
        self.class.new(uri.route_to(other.uri),{:base => self.url})
      end
      def merge(other)
        self.class.new(uri.merge(other.uri))
      end

      def dirname()
        ::File.dirname(self.path_no_slash)
      end


    end
  end
end
