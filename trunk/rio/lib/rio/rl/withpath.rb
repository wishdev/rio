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
require 'rio/exception/notimplemented'
require 'rio/rl/builder'

module RIO
  module RL
    module PathUtil
    end
  end
end
      # 

module RIO
  module RL
    class WithPath < RIO::RL::Base
      include RIO::RL::PathUtil
      include RIO::Error::NotImplemented

      # returns an appriate FS object for the scheme
      def openfs_() nodef() end

      # returns the path portion of a URL. All spaces would be %20
      # returns a String
      def urlpath() nodef() end
      def urlpath=(arg) nodef(arg) end

      # For RLs that are on the file system this is fspath()
      # For RLs that are remote (http,ftp) this is urlpath()
      # For RLs that have no path this is nil
      # returns a String
      def path() nodef{} end
      def path=(arg) nodef(arg) end

      # returns A URI object representation of the RL if one exists
      # otherwise it returns nil
      # returns a URI
      def uri() nodef() end

      # when the URL is legal it is the URI scheme
      # otherwise it is one of Rio's schemes
      # returns a String
      def scheme() nodef() end

      # returns the host portion of the URI if their is one
      # otherwise it returns nil
      # returns a String
      def host() nodef() end
      def host=(arg) nodef(arg) end

      # returns the portion of the URL starting after the colon
      # following the scheme, and ending before the query portion
      # of the URL
      # returns a String
      def opaque() nodef() end

      # returns the portion of the path that when prepended to the 
      # path would make it usable.
      # For paths on the file system this would be '/'
      # For http and ftp paths it would be http://host/
      # For zipfile paths it would be ''
      # For windows paths with a drive it would be 'C:/'
      # For windows UNC paths it would be '//host/'
      # returns a String
      def pathroot() nodef() end


      # returns the base of a path. 
      # merging the value returned with this yields the absolute path
      def base(thebase=nil) nodef(thebase) end

    end
  end
end

module RIO
  module RL
    class WithPath < RIO::RL::Base
      SCHEME = URI::REGEXP::PATTERN::SCHEME
      HOST = URI::REGEXP::PATTERN::HOST

      # returns the path as the file system sees it. Spaces are spaces and not
      # %20 etc. This is the path that would be passed to the fs object.
      # For windows RLs this includes the '//host' part and the 'C:' part
      # returns a String
      def fspath() 
        RL.url2fs(self.urlpath)
      end

      # The value of urlpath() with any trailing slash removed
      # returns a String
      def path_no_slash() 
        self.urlpath.sub(/\/$/,'')
      end
      def pathdepth()
        pth = self.path_no_slash
        (pth == '/' ? 0 : pth.count('/'))
      end

      def _uri(arg)
        arg.kind_of?(::URI) ? arg.clone : ::URI.parse(arg.to_s)
      end
      # returns the absolute path. combines the urlpath with the
      # argument, or the value returned by base() to create an
      # absolute path.
      # returns a RL
      def abs(thebase=nil) 
        thebase ||= self.base
        base_uri = _uri(thebase)
        path_uri = self.uri
        #p "abs: base_uri=#{base_uri.inspect}"
        #p "abs: path_uri=#{path_uri.inspect}"
        if path_uri.scheme == 'file' and base_uri.scheme != 'file'
          abs_uri = base_uri.merge(path_uri.path)
        else
          abs_uri = base_uri.merge(path_uri)
        end
        #p "abs: abs_uri=#{abs_uri.inspect}"
        _build(abs_uri,{:fs => self.fs})
      end


      # returns an array of parts of a RL.
      # 'a/b/c' => ['a','b','c']
      # For absolute paths the first component is the pathroot
      # '/topdir/dir/file' => ['/','topdir','dir','file']
      # 'http://host/dir/file' => ['http://host/','dir','file']
      # '//host/a/b' => ['file://host/','a','b']
      # each element of the array is an RL whose base is
      # set such that the correct absolute path would be returned
      # returns an array of RLs
      def _parts()
        pr = self.pathroot
        ur = self.urlroot.sub(/#{pr}$/,'')
        up = self.urlpath.sub(/^#{pr}/,'')

        [ur,pr,up]
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
        rlparts = sparts.map { |str| self.class.new(str) }
        (1...sparts.length).each { |i|
          base_str = rlparts[i-1].abs.url
          base_str += '/' unless base_str[-1] == ?/
          rlparts[i].base = base_str
        }
        rlparts

      end

      # changes this RLs path so that is consists of this RL's path
      # combined with those of its arguments.
      def join(*args)
        return self if args.empty?
        sa = args.map { |arg| ::URI.escape(arg.to_s,ESCAPE) }
        sa.unshift(self.urlpath) unless self.urlpath.empty?
        self.urlpath = sa.join('/').squeeze('/')
        self
      end

      # returns the directory portion of the path
      # like File#dirname
      # returns a RL
      def dirname() 
        new_rl = self.clone
        new_rl.urlpath = fs.dirname(self.path_no_slash)
        new_rl
      end
        
      # returns the tail portion of the path
      # returns a RL
      def filename() 
        base_rl = self.abs
        base_rl.urlpath = fs.dirname(self.path_no_slash)
        path_str = fs.filename(self.path_no_slash)
        _build(path_str,{:base => base_rl.to_s, :fs => self.to_s})
      end

      # calls URI#merge
      # returns a RL
      def merge(other) _build(self.uri.merge(other.uri)) end

      # calls URI#route_from
      # returns a RL
      def route_from(other) _build(self.uri.route_from(other.uri),{:base => other.uri}) end

      # calls URI#route_to
      # returns a RL
      def route_to(other) _build(self.uri.route_to(other.uri),{:base => self.uri}) end

      def _build(*args) RIO::RL::Builder.build(*args) end

      def uri_from_string_(str)
        case str
        when %r%^file://(#{HOST})?(/.*)?$% then ::URI.parse(str)
        when %r/^#{SCHEME}:/ then ::URI.parse(str)
        #when %r{^/} then ::URI.parse('file://'+str+( ( str[-1,0] == '/' ) ? "" : "/"))
        when %r{^/} then ::URI.parse('file://'+str)
        else ::URI.parse(str)
        end
      end
    end
  end
end


