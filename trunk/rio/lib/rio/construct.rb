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
  require 'rio/ops/construct'
  include Ops::Construct

  module_function :strio
  module_function :stdio
  module_function :stderr
  module_function :temp
  module_function :tempfile
  module_function :tempdir
  module_function :tcp
  module_function :cmdio
  module_function :cmdpipe
  module_function :sysio
  module_function :fd
end

module RIO
  class Rio
    def self.strio(*args,&block) rio(:strio,*args,&block) end
    def self.stdio(*args,&block) rio(:stdio,*args,&block) end
    def self.stderr(*args,&block) rio(:stderr,*args,&block) end
    def self.temp(*args,&block)  rio(:temp,*args,&block)  end
    def self.tempfile(*args,&block)  rio(:tempfile,*args,&block)  end
    def self.tempdir(*args,&block)  rio(:tempdir,*args,&block)  end
    def self.tcp(*args,&block)  rio(:tcp,*args,&block)  end
    def self.cmdio(*args,&block)  rio(:cmdio,*args,&block)  end
    def self.cmdpipe(*args,&block)  rio(:cmdpipe,*args,&block)  end
    def self.sysio(*args,&block)  rio(:sysio,*args,&block)  end
    def self.fd(*args,&block)  rio(:fd,*args,&block)  end
  end
end
