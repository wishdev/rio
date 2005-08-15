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
#
require 'tmpdir'
module RIO
  module Temp
    RESET_STATE = 'Temp::Reset'

    require 'rio/rl/base'
    class RL < RL::Base 
      RIOSCHEME = 'temp'
      RIOPATH = RIO::RL::CHMAP.invert[RIOSCHEME].to_s.freeze
      DFLT_PREFIX = 'rio'
      DFLT_TMPDIR = ::Dir::tmpdir
      attr_reader :prefix,:tmpdir
      def initialize(file_prefix=DFLT_PREFIX,temp_dir=DFLT_TMPDIR)
        #puts "initialize(#{file_prefix.inspect},#{temp_dir.inspect})"
        @prefix = file_prefix || DFLT_PREFIX
        @tmpdir = temp_dir || DFLT_TMPDIR
      end
      #def path() nil end
      def scheme() self.class.const_get(:RIOSCHEME) end
      def opaque()
        td = @tmpdir.to_s
        td += '/' unless td.nil? or td.empty? or (td.ends_with?('/') and td != '/')
        td+@prefix
      end
      
      SPLIT_RE = %r|(?:(.*)/)?([^/]*)$|.freeze
      def self.splitrl(s)
        sub,opq,whole = split_riorl(s)
        if opq.nil? or opq.empty?
          []
        elsif bm = SPLIT_RE.match(opq)
          tdir = bm[1] unless bm[1].nil? or bm[1].empty?
          tpfx = bm[2] unless bm[2].nil? or bm[2].empty?
          [tpfx,tdir]
        else
          []
        end
      end
    end
    module Dir
      require 'rio/rl/path'
      RESET_STATE = RIO::RL::PathBase::RESET_STATE
      require 'tmpdir'
      class RL < RIO::RL::PathBase 
        RIOSCHEME = 'tempdir'
        DFLT_PREFIX = Temp::RL::DFLT_PREFIX
        DFLT_TMPDIR = Temp::RL::DFLT_TMPDIR
        attr_reader :prefix,:tmpdir,:tmprl
        def initialize(file_prefix=DFLT_PREFIX,temp_dir=DFLT_TMPDIR)
          #puts "initialize(#{file_prefix.inspect},#{temp_dir.inspect})"
          @prefix = file_prefix || DFLT_PREFIX
          @tmpdir = temp_dir || DFLT_TMPDIR
          require 'rio/tempdir'
          @td = ::Tempdir.new( @prefix.to_s, @tmpdir.to_s)
          super(@td.to_s)
        end
        SPLIT_RE = Temp::RL::SPLIT_RE
        def self.splitrl(s)
          Temp::RL.splitrl(s)
        end
      end
    end
    module File
      require 'rio/rl/path'
      RESET_STATE = 'Temp::Stream::Open'
      class RL < RIO::RL::PathBase 
        RIOSCHEME = 'tempfile'
        DFLT_PREFIX = Temp::RL::DFLT_PREFIX
        DFLT_TMPDIR = Temp::RL::DFLT_TMPDIR
        attr_reader :prefix,:tmpdir,:tmprl
        def initialize(file_prefix=DFLT_PREFIX,temp_dir=DFLT_TMPDIR)
          #puts "initialize(#{file_prefix.inspect},#{temp_dir.inspect})"
          @prefix = file_prefix || DFLT_PREFIX
          @tmpdir = temp_dir || DFLT_TMPDIR
          require 'tempfile'
          @tf = ::Tempfile.new( @prefix.to_s, @tmpdir.to_s)
          super(@tf.path)
        end
        def open(mode='ignored',tf=nil,td=nil)
          @tf
        end
        def close 
          super
          @tf = nil
        end
        SPLIT_RE = Temp::RL::SPLIT_RE
        def self.splitrl(s)
          Temp::RL.splitrl(s)
        end
      end
    end
    require 'rio/state'
    class Reset < State::Base
      def initialize(*args)
        super
        @tempobj = nil
      end
      def check?() true end
      def dir(prefix=rl.prefix,tmpdir=rl.tmpdir)
        self.rl = RIO::Temp::Dir::RL.new(prefix, tmpdir)
        become 'Dir::Existing'
      end
      def mkdir()
        dir()
      end
      def chdir(&block)
        dir.chdir(&block)
      end
      def file(prefix=rl.prefix,tmpdir=rl.tmpdir)
        self.rl = RIO::Temp::File::RL.new(prefix, tmpdir)
        become 'Temp::Stream::Open'
      end
      def scheme() rl.scheme() end
      def host() rl.host() end
      def opaque() rl.opaque() end
      def to_s() rl.url() end
      def exist?() false end
      def file?() false end
      def dir?() false end
      def open?() false end
      def closed?() true end
      def when_missing(sym,*args)
        if @tempobj.nil?
          file()
        else
          gofigure(sym,*args)
        end
      end
    end
    require 'rio/stream/open'
    module Stream
      class Open < RIO::Stream::Open
        def iostate(sym)
          mode('w+').noautoclose_.open_.inout()
        end
#        def inout() stream_state('Temp::Stream::InOut') end
      end
#      require 'rio/stream'
#      class InOut < RIO::Stream::InOut
#        def base_state() 'Temp::Stream::Close' end
#      end
#      class Close < RIO::Stream::Close
#        def base_state() 'Temp::Reset' end
#      end

    end
  end
end
