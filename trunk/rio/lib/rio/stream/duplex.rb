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


require 'rio/stream'
require 'rio/stream/open'

module RIO
  module Stream
    module Duplex
      class Open < RIO::Stream::Open
        def input() stream_state('Stream::Duplex::Input') end
        def output() stream_state('Stream::Duplex::Output') end
        def inout() stream_state('Stream::Duplex::InOut') end
      end

      module Ops
        module Output
          def wclose()
            ioh.close_write
            return self.close.softreset if ioh.closed?
            self
          end
        end
        module Input
        end
      end

      class Input < RIO::Stream::Input
        include Ops::Input
      end

      class Output < RIO::Stream::Output
        include Ops::Output
      end
      
      class InOut < RIO::Stream::InOut
        include Ops::Output
        include Ops::Input
      end
    end
  end
end
