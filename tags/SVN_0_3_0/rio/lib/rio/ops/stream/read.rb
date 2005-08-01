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
    module Stream
      module Read
        def slurp() 
          auto { ioh.gets(nil) }
        end
        alias :to_string :slurp
        alias :contents :slurp
        def readlines(*args)
          auto { ioh.readlines(*args) }
        end
        def read(*args)
          auto { ioh.read(*args) }
        end
        def ungetc(*args)
          ioh.ungetc(*args)
          self
        end
        def each_line(*args,&block)
          auto { 
#            self.ioh.each_line(*args,&block) 
            self.ioh.each_line { |line|
              yield line
            } #(*args,&block) 
          }
        end
        def each_byte(*args,&block)
          auto { ioh.each_byte(*args,&block) }
        end
        def each_bytes(nb,*args,&block)
          #p callstr('each_bytes',nb,*args)
          auto {
            until ioh.eof?
              break unless s = ioh.read(nb)
              yield s
            end
          }
        end

        extend Forwardable
        def_instance_delegators(:ioh,:readline,:readchar,:gets,:lineno)
      end 
    end 
  end
end
