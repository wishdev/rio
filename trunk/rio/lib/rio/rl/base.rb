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


require 'uri'
require 'rio/local'
require 'rio/uri/file'
#require 'extensions/class'

module RIO
  module RL
    CHMAP = { 
      '_'    => 'sysio',
      '-'    => 'stdio',
      '='    => 'stderr',
      '"'    => 'strio',
      '?'    => 'temp',
      '['    => 'aryio',
      '`'    => 'cmdio',
      '#'    => 'fd',

      ?_    => 'sysio',
      ?-    => 'stdio',
      ?=    => 'stderr',
      ?"    => 'strio',
      ??    => 'temp',
      ?[    => 'aryio',
      ?`    => 'cmdio',
      ?#    => 'fd',
    }.freeze
  end
end
module RIO
  module RL #:nodoc: all
    PESCAPE = Regexp.new("[^-_.!~*'()a-zA-Z0-9;?:@&=+$,]",false, 'N').freeze
    ESCAPE = Regexp.new("[^-_.!~*'()a-zA-Z0-9;\/?:@&=+$,]",false, 'N').freeze
    def fs2url(pth)
#      Base.fs2url(pth)
      pth.sub!(/^[a-zA-Z]:/,'')
      pth = URI.escape(pth,ESCAPE)
#      (Local::SEPARATOR == '/' ? pth : pth.gsub(Local::SEPARATOR,%r|/|))
    end

    def url2fs(pth)
#      pth = pth.chop if pth.length > 1 and pth[-1] == ?/      cwd = RIO::RL.fs2url(::Dir.getwd)

      pth = pth.chop if pth != '/' and pth[-1] == ?/
      pth = ::URI.unescape(pth)
#      (Local::SEPARATOR == '/' ? pth : pth.gsub(%r|/|,Local::SEPARATOR))
    end

    def getwd()
      ::URI::FILE.build({:path => fs2url(::Dir.getwd)+'/'})
    end

    module_function :url2fs,:fs2url,:getwd
  end
end
module RIO
  module RL

    SCHEME = 'rio'
    SCHC = SCHEME+':'
    SPLIT_RIORL_RE = %r{\A([a-z][a-z]+)(?:(:)(.*))?\Z}.freeze
    SUBSEPAR = ':'

    class Base
      def self.subscheme(s)
#        sch,opq,whole = split_riorl(s)
#        sch
        /^rio:([^:]+):/.match(s)[1]
#        s[4...s.index(SUBSEPAR,4)]
#        e = s.index(SUBSEPAR,b)
#        s.split(SUBSEPAR,3)[1]
      end
      def self.split_riorl(s)
        body = s[SCHC.length...s.length]
        m = SPLIT_RIORL_RE.match(body) 
        return [] if m.nil?
        return m[1],m[3],m[0]
      end

      def self.is_riorl?(s)
        s[0...SCHC.length] == SCHC
      end

      def self.parse(*a)
        parms = splitrl(a.shift) || []
        new(*(parms+a))
      end

      def rl()
        SCHC+self.url
      end
      def riorl() SCHC+self.url end

      def to_s() self.fspath || '' end
      def ==(other) self.to_s == other.to_s end
      def ===(other) self == other end
      def =~(other) other =~ self.to_str end
      def length() self.to_s.length end
      def fspath() nil end
      def path() nil end

      def to_rl() self.rl end

      def url() self.scheme+SUBSEPAR+self.opaque end
      def callstr(func,*args)
        self.class.to_s+'['+self.to_s+']'+'.'+func.to_s+'('+args.join(',')+')'
      end
      def close() nil end

    end
  end
end
