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



module RIO
  module Tempfile #:nodoc: all
    require 'rio/rl/ioi'
    require 'rio/scheme/path'
    RESET_STATE = RL::IOIBase::RESET_STATE

    require 'tmpdir'
    class RL < RL::IOIBase 
      RIOSCHEME = 'tempfile'
      RIOPATH = RIO::RL::CHMAP.invert[RIOSCHEME]
      DFLT_PREFIX = 'rio'
      DFLT_TMPDIR = '/tmp' # ::Dir::tmpdir
      attr_reader :prefix,:tmpdir,:tmprl
      def initialize(file_prefix=DFLT_PREFIX,temp_dir=DFLT_TMPDIR)
        @prefix = file_prefix || DFLT_PREFIX
        @tmpdir = RIO::Path::RL.new(temp_dir || DFLT_TMPDIR)
        @tmprl = nil
      end
      def path()
        return @tmprl.path unless @tmprl.nil?
        RIOPATH
      end
      def fspath() 
        return nil if @tmprl.nil?
        self.class.path_to_fspath(self.path)
      end
      def uri()
        return @tmprl.uri unless @tmprl.nil?
        nil
      end
      def url()
        return @tmprl.url unless @tmprl.nil?
        super
      end
      def opaque()
        td = @tmpdir.to_s
        td += '/' unless td.nil? or td.empty? or (td.ends_with?('/') and td != '/')
        td+@prefix
        end
      def open(mode='ignored',tf=nil,td=nil)
        require 'tempfile'
        tf ||= @prefix
        td ||= @tmpdir
        hnd = ::Tempfile.new( tf.to_s, td.to_s)
        @tmprl = RIO::Path::RL.new(RIO::RL::fs2url(hnd.path))
        hnd
      end
      def close()
        @tmprl = nil
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
  end
end
