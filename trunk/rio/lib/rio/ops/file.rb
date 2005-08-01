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


require 'rio/cp'
module RIO
  module Impl
    module U
      def self.copy(s,d)
        require 'fileutils'
        ::FileUtils.cp(s.to_s,d.to_s)
      end
      def self.rm(s)
        require 'fileutils'
        ::FileUtils.rm(s.to_s)
      end
      def self.touch(s)
        require 'fileutils'
        ::FileUtils.touch(s.to_s)
      end
    end
  end
end
module RIO
  module Ops
    module File
      module ExistOrNot
        require 'rio/ops/either'
        include FileOrDir::ExistOrNot
       end
      module Existing
        include ExistOrNot
        include FileOrDir::Existing
        include Cp::File::Output
        include Cp::File::Input

        def selective?
          %w[stream_sel stream_nosel].any? { |k| cx.has_key?(k) }
        end
        def rm(*args) 
          rtn_reset { 
            Impl::U.rm(self,*args) 
          } 
        end
        alias :delete :rm
        alias :delete! :rm

        def touch(*args) rtn_self { Impl::U.touch(self,*args) } end
      end
      module NonExisting
        include ExistOrNot
        include FileOrDir::NonExisting

        def rm(*args) rtn_self { ; } end
        alias delete rm
        alias delete! rm
        def touch(*args) rtn_reset { Impl::U.touch(self,*args) } end
      end
    end
  end
end
