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



require 'rio/abstract_method'

module RIO
  module Mode #:nodoc: all
    class Base
      attr_reader :mode
      protected :mode
      
      def initialize(arg)
        if arg.kind_of? self.class
          copy(arg)
        else
          @mode = arg
        end
      end
      
      def copy(other)
        @mode = other.mode
      end
      
      def to_s() @mode.to_s end

      abstract_method :primarily_read?, :primarily_write?, :allows_both?

      def read_only?()
        allows_read? and !allows_write?
      end
      def write_only?()
        !allows_read? and allows_read?
      end
      def allows_read?()
        primarily_read? or allows_both?
      end
      def allows_write?()
        primarily_write? or allows_both?
      end
      extend Forwardable
      def_instance_delegators(:@mode,:=~,:==,:===)
    end
  end
  module Mode
    module StrMethods
      def primarily_read?() @mode[0,1] == 'r' end
      def primarily_write?() @mode[0,1] == 'w' or primarily_append? end
      def primarily_append?() @mode[0,1] == 'a' end
      def allows_both?()
        @mode[1,1] == '+'
      end
    end
    class Str < Base
      include StrMethods
    end
  end
  module Mode
    class Int < Base
    end
  end
end
