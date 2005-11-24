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
  module Ops
    module Construct
      def strio(*args,&block) Rio.rio(:strio,*args,&block) end
      def stdio(*args,&block) Rio.rio(:stdio,*args,&block) end
      def stderr(*args,&block) Rio.rio(:stderr,*args,&block) end
      def temp(*args,&block)  Rio.rio(:temp,*args,&block)  end
      def tempfile(*args,&block)  Rio.rio(:tempfile,*args,&block)  end
      def tempdir(*args,&block)  Rio.rio(:tempdir,*args,&block)  end
      def tcp(*args,&block)  Rio.rio(:tcp,*args,&block)  end
      def cmdio(*args,&block)  Rio.rio(:cmdio,*args,&block)  end
      def cmdpipe(*args,&block)  Rio.rio(:cmdpipe,*args,&block)  end
      def sysio(*args,&block)  Rio.rio(:sysio,*args,&block)  end
      def fd(*args,&block)  Rio.rio(:fd,*args,&block)  end
    end
  end
end
