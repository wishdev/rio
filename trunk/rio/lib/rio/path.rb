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


# cell phone number: 954-6752.
require 'rio/state'
require 'rio/ops/path'
require 'rio/ops/symlink'
require 'rio/cp'
module RIO

  module Path #:nodoc: all
    # Empty: 
    #  nil? or empty? => Emp
    #  else => Sin
    class Empty < State::Base
      include Ops::Path::Empty
      def check?() fspath.nil? or fspath.empty? end
      def when_missing(sym,*args) gofigure(sym,*args) end
    end 

    # Primary State for Rio as path manipulator
    class Str < State::Base 
      include Ops::Path::Str
      include Ops::Path::Change
      public 
      
      def check?() not fspath.nil? and not fspath.empty? end
      def when_missing(sym,*args) 
        #p callstr('when_missing',sym,*args)+" file?=#{file?} symlink?=#{symlink?} dir?=#{directory?}"
        case
        when file? then efile()
        when directory? then edir()
        else npath()
        end
      end

      protected

      def edir()
        #rl.path += '/' unless rl.path.empty? or rl.path[-1] == ?/
        next_state = become('Dir::Existing')
        next_state.extend(Ops::Symlink::Existing) if symlink?
        next_state
      end
      def efile() 
        next_state = become('File::Existing')
        next_state.extend(Ops::Symlink::Existing) if symlink?
        next_state
      end
      def npath() 
        next_state = become('Path::NonExisting')
        next_state.extend(Ops::Symlink::NonExisting) if symlink?
        next_state
      end

    end # class PathString

    # A transition state. Anything but simple path tests must cause a transition out of this state.
    class NonExisting < State::Base
      include Ops::Path::NonExisting
      include Cp::NonExisting::Output

      def check?() not exist? end

      def ndir() 
        #rl.path += '/' unless rl.path.empty? or rl.path[-1] == ?/
        become('Dir::NonExisting')
      end
      def nfile() become('File::NonExisting') end

      def when_missing(sym,*args)
        case sym
        when :mkdir,:mkpath
          ndir()
        else 
          nfile()
        end
      end
    end # class NPath

  end # module Rsc

end
