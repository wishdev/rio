#--
# =============================================================================== 
# Copyright (c) 2005,2006,2007,2008 Christopher Kleckner
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
# from the distribution directory.
#
# Suggested Reading
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Doc::EXAMPLES
# * RIO::Rio
#


require 'rio/context/cxx.rb'

module RIO  
  module Cx
    module Methods
      def closeoneof(arg=true,&block) cxx('closeoneof',arg,&block) end
      def nocloseoneof(arg=false,&block) nocxx('closeoneof',arg,&block) end
      def closeoneof?() cxx?('closeoneof') end 
      def closeoneof_(arg=true)  cxx_('closeoneof',arg) end
      protected :closeoneof_
    end
  end

  module Cx
    module Methods
      def closeoncopy(arg=true,&block) cxx('closeoncopy',arg,&block) end
      def nocloseoncopy(arg=false,&block) nocxx('closeoncopy',arg,&block) end
      def closeoncopy?() cxx?('closeoncopy') end 
      def closeoncopy_(arg=true)  cxx_('closeoncopy',arg) end
      protected :closeoncopy_
    end
  end

  module Cx
    module Methods
      def noautoclose(arg=false,&block)
        closeoncopy(arg).closeoneof(arg,&block)
      end
      def noautoclose_(arg=false)
        closeoncopy_(arg).closeoneof_(arg)
      end
      protected :noautoclose_
    end
  end

end
