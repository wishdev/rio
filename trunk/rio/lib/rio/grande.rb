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


require 'rio/match'
module RIO
  module Grande #:nodoc: all
    include Match::Common
    def [](*args)
      #p "#{callstr('[]',*args)} ss_type=#{cx['ss_type']} stream_iter=#{stream_iter?}"
      ss_args = cx['ss_args'] = args
      if ss_args and (ss_type = ss_type?(_ss_keys()))
        return self.__send__(ss_type,*(ss_args)).to_a
      else
        return to_a()
      end
    end

    def fixnumss(*args)
      #p "#{callstr('[]',*args)} ss_type=#{cx['ss_type']} stream_iter=#{stream_iter?}"
      #p args[0].class,ss_type?(_ss_keys())
      ss_args = cx['ss_args'] = args
      if ss_args.length == 1 and ss_args[0].kind_of?(Fixnum) and !cx.has_key?('dirlines')
        ans = nil
        ss_type = ss_type?(_ss_keys())

        if ss_args and ss_type
          ans = self.__send__(ss_type,*(ss_args)).to_a
        else
          ans = to_a()
        end
        
        return (ans.empty? ? nil : ans[0])
      else
        if ss_args and (ss_type = ss_type?(_ss_keys()))
          return self.__send__(ss_type,*(ss_args)).to_a
        else
          return to_a()
        end
      end
    end

  end
end
