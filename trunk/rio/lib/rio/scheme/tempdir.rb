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
  module Tempdir #:nodoc: all
    require 'rio/rl/path'
    RESET_STATE = RL::PathBase::RESET_STATE
    require 'tmpdir'
    class RL < RL::PathBase 
      RIOSCHEME = 'tempdir'
      RIOPATH = RIO::RL::CHMAP.invert[RIOSCHEME].to_s.freeze
      DFLT_PREFIX = 'rio'
      DFLT_TMPDIR = ::Dir::tmpdir
      attr_reader :prefix,:tmpdir,:tmprl
      def initialize(file_prefix=DFLT_PREFIX,temp_dir=DFLT_TMPDIR)
        #puts "initialize(#{file_prefix.inspect},#{temp_dir.inspect})"
        @prefix = file_prefix || DFLT_PREFIX
        @tmpdir = temp_dir || DFLT_TMPDIR
        require 'rio/tempdir'
        @td = ::Tempdir.new( @prefix.to_s, @tmpdir.to_s)
        super(@td.to_s)
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
