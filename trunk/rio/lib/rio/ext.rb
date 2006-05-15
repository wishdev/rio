#--
# =============================================================================== 
# Copyright (c) 2005, 2006 Christopher Kleckner
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
#  ruby build_doc.rb
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


require 'rio/ext/csv'
require 'rio/ext/splitlines'
require 'rio/ext/yaml'
#require 'rio/ext/zipfile'

require 'rio/util'
module RIO
  module Ext #:nodoc: all
    @@extensions = {}

    module_function
    def add(cl,meth)
      @@extensions[cl] ||= []
      @@extensions[cl].push(meth)
    end
    def extend_state(state_class,ext_module)
      ext_proc = proc{ |obj| obj.extend(ext_module) }
      RIO::Ext.add(state_class,ext_proc)
    end

    def became(obj)
      if @@extensions[obj.class]
        @@extensions[obj.class].each { |meth|
          meth[obj]
        }
      end
    end
  end
end

module RIO
  module Ext #:nodoc: all
    OUTPUT_SYMS = Util::build_sym_hash(CSV::Output.instance_methods + YAML::Output.instance_methods)

    module Cx
      include CSV::Cx
      include SplitLines::Cx
      include YAML::Cx
      #include ZipFile::Cx
    end
  end
  module Ext
    module Input
      def add_extensions(obj)
        #p "add_extensions(#{obj.inspect})"
        #p obj.ioh
        #p obj.splitlines?
        if obj.csv?
          obj.extend(CSV::Input)
        end
        if obj.splitlines?
          obj.extend(SplitLines::Input)
        end
        obj.extend(YAML::Input) if obj.yaml?
#        if obj.zipfile?
#          require 'rio/ext/zipfile/state'
#          obj.extend(ZipFile::Input) 
#        end
        obj
      end
      module_function :add_extensions
    end
    module Output
      def add_extensions(obj)
        obj.extend(CSV::Output) if obj.csv?
        obj.extend(SplitLines::Output) if obj.splitlines?
        obj.extend(YAML::Output) if obj.yaml?
        obj
      end
      module_function :add_extensions
    end
  end
end

