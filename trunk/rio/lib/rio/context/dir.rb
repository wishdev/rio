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


require 'rio/context/cxx.rb'

require 'rio/entrysel'

module RIO
  module Cx
    module Methods
      
      private

      def _addselkey(key,sym,*args)
        cx[key] ||= Match::Entry::Sels.new
        cx[key] << Match::Entry::List.new(sym,*args)
        self
      end


      def _set_select(ss_type,key,sym,*args,&block)
        cx['ss_type'] = ss_type
        _addselkey(key,sym,*args)
        return each(&block) if block_given?
        self
      end

      public

      def recurse(*args,&block)
        _addselkey('r_sel',:dir?,*args).all_
        return each(&block) if block_given?
        self
      end
      def norecurse(*args,&block)
        _addselkey('r_nosel',:dir?,*args).all_
        return each(&block) if block_given?
        self
      end
      def entries(*args,&block) _set_select('entries','sel',:true?,*args,&block) end
      def files(*args,&block)   _set_select('files','sel',:file?,*args,&block)   end
      def dirs(*args,&block)    _set_select('dirs','sel',:dir?,*args,&block)     end

      def noentries(*args,&block) 
        _set_select('noentries','nosel',:true?,*args,&block) 
      end
      def nofiles(*args,&block)
        _addselkey('sel',:file?) unless args.empty?
        _set_select('nofiles','nosel',:file?,*args,&block)
      end
      def nodirs(*args,&block)
        _addselkey('sel',:dir?) unless args.empty?
        _set_select('nodirs','nosel',:dir?,*args,&block)
      end
    end
  end
end
      
