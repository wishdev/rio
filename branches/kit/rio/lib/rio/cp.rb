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


require 'rio/exception/copy'
class String #:nodoc: all
  def clear()
    self[0..-1] = ''
    self
  end
end
module RIO
  module Cp #:nodoc: all
    module Util
      module InOut
        def cpclose(*args,&block)
          if args.empty?
            oldcoc,self.cx['closeoncopy'] = self.cx['closeoncopy'],false
            rtn = yield
            rtn.cx['closeoncopy'] = oldcoc
            rtn.copyclose
          else
            if (ario = args[0]).kind_of?(Rio)
              oldcoc,ario.cx['closeoncopy'] = ario.cx['closeoncopy'],false
              rtn = yield
              ario.cx['closeoncopy'] = oldcoc
              ario.copyclose
              rtn
            else
              yield
            end
          end
        end
      end
      module Input
        include InOut
        protected

        def cpto_obj_(obj)
          self.each do |el|
            obj << el
          end
        end

      end
      module Output
        include InOut


        protected

        def cpfrom_obj_(obj)
          obj.each do |el|
            self << el
          end
        end
        def cpfrom_array_(ary)
          ary.inject(self) { |anio,el| anio << el }
        end
      end
    end
  end
end

module RIO
  module Cp
    module Stream
      module Input
        include Util::Input
        def >>(arg)
          cpclose(arg) {
            case arg
            when ::Array,::String,::IO then cpto_obj_(arg)
            else _cpto_rio(arg,:<<)
            end
            self
          }
        end
        def >(arg)
          cpclose(arg) {
            case arg 
            when ::Array,::String then cpto_obj_(arg.clear)
            when ::IO then cpto_obj_(arg)
            else _cpto_rio(arg,:<)
            end
            self
          }
        end
        private
        def _cpto_rio(arg,sym)
          ario = ensure_rio(arg)
          ario = ario.join(self.filename) if ario.dir?
          ario.cpclose {
            ario = ario.iostate(sym)
            self.each do |el|
              ario << el
            end
            ario
          }
        end
      end
      module Output
        include Util::Output
        def <<(arg) cpclose { _cpfrom(arg) } end
        def <(arg) cpclose { _cpfrom(arg) } end

        private

        def _cpfrom(arg)
            case arg
            when ::Array then cpfrom_array_(arg)
            when ::IO then cpfrom_obj_(arg)
            when ::String then self.put_(arg)
            else _cpfrom_rio(arg)
            end
            self
        end
        def _cpfrom_rio(arg)
          ensure_rio(arg).each do |el|
            self << el
          end
        end
      end
    end
  end
end
module RIO
  module Cp
    module File
      module Output
        include Util::Output
        def <(arg) cpclose { self.iostate(:<) < arg } end
        def <<(arg) cpclose { self.iostate(:<<) << arg } end
      end
      module Input
        include Util::Input
        def >(arg)  
          spcp(arg) || cpclose(arg) { self.iostate(:>) > arg  } 
        end
        def >>(arg) 
          spcp(arg) || cpclose(arg) { self.iostate(:>>) >> arg } 
        end
        def copy_as_file?(arg)
          arg.kind_of?(Rio) and arg.scheme == 'ftp'
        end
        def spcp(arg)
          if arg.kind_of?(Rio) and arg.scheme == 'ftp'
            arg < new_rio(rl.path)
            self
          else
            nil
          end
        end
        alias :copy :>
      end
    end
  end
end
module RIO
  module Cp
    module Open
      module Output
        include Util::Output
        def <(arg) cpclose { self.iostate(:<) < arg } end
        def <<(arg) cpclose { self.iostate(:<<) << arg } end
      end
      module Input
        include Util::Input
        def >(arg) cpclose(arg) { self.iostate(:>) > arg } end
        def >>(arg) cpclose(arg) { self.iostate(:>>) >> arg } end
        alias :copy :>
      end
    end
  end
end
module RIO
  module Cp
    module Dir
      module Output
        include Util::Output
        def <<(arg)  _cpfrom(arg); self  end
        def <(arg)  _cpfrom(arg); self end

        private

        def _cpfrom(arg)
          case arg
          when ::Array then cpfrom_array_(arg)
          else _cpfrom_rio(ensure_rio(arg))
          end
        end
        def _cpfrom_rio(ario)
          #p callstr('_cpfrom_rio',ario)
          dest = self.join(ario.filename)
          if ario.dir?
            dest.mkdir
            ario.nostreamenum.each do |el|
              dest < el
            end
          else
            dest < ario
          end
        end
      end
      module Input
        include Util::Input
        def >>(arg)
          case arg
          when ::Array then cpto_obj_(arg)
          else _cpto_rio(ensure_rio(arg))
          end
          self
        end
        def >(arg)
          case arg
          when ::Array then cpto_obj_(arg.clear)
          else _cpto_rio(ensure_rio(arg))
          end
          self
        end
        alias :copy :>

        private

        def _cpto_rio(ario)
          ario = ario.join(self.filename) if ario.exist?
          nostreamenum.cpto_obj_(ario.mkdir)
        end
      end
    end
  end
end
module RIO
  module Cp
    module NonExisting
      module Output
        include Util::Output
        def <(arg)  
          if _switch_direction?(arg)
            arg > self
            self
          else 
            _cpsrc(arg) < arg
          end
        end
        def <<(arg)  
          if _switch_direction?(arg)
            arg >> self
            self
          else 
            _cpsrc(arg) << arg
          end
        end

        private

        def _cpsrc(arg)
          if arg.kind_of?(::Array) and !arg.empty? and arg[0].kind_of?(Rio)
            self.mkdir.reset
          else
            self.nfile
          end
        end
        def _switch_direction?(arg)
          arg.kind_of?(Rio) and arg.dir? and !arg.stream_iter?
        end
      end
    end
  end
end

__END__
