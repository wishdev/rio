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


require 'rio/rl/path'
module RIO
  module Path #:nodoc: all
    RESET_STATE = RL::PathBase::RESET_STATE

    class RL < RL::PathBase 
    end
  end
  module File
    RESET_STATE = RL::PathBase::RESET_STATE

    class RL < RL::PathBase 
      def open(m)
        ::File.open(self.fspath,m.to_s)
      end
    end
  end
  module Dir
    RESET_STATE = RL::PathBase::RESET_STATE

    class RL < RL::PathBase 
      def open()
        ::Dir.open(self.fspath)
      end
    end
  end
  require 'rio/stream'
  require 'rio/stream/open'
  require 'rio/ops/symlink'
  module Path
    module Stream
      class Open < RIO::Stream::Open
        include Ops::Path::Status
        include Ops::Path::URI
        include Ops::Path::Query
        def stream_state(cl)
          next_state = super
          next_state.extend(RIO::Ops::Symlink::Existing) if symlink?
          next_state
        end
        def input() stream_state('Path::Stream::Input') end
        def output() stream_state('Path::Stream::Output') end

        def inout() stream_state('Path::Stream::InOut') end
      end

      module Ops
        include RIO::Ops::Path::Str
      end

      class Input < RIO::Stream::Input
        include Ops
      end

      class Output < RIO::Stream::Output
        include Ops
      end

      class InOut < RIO::Stream::InOut
        include Ops
      end
    end
  end
end
