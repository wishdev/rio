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


module RIO
  module Cx #:nodoc: all
    class  Vars
      def initialize(h=Hash.new,exp=Hash.new)
        @values = h
        @explicit = exp
      end
      def initialize_copy(*args)
        super
        @values = @values.clone
        @explicit = @explicit.clone
      end
      def delete(key)
        @values.delete(key)
        @explicit.delete(key)
      end
      def set_(key,val)
        @values[key] = val unless @explicit[key]
      end
      def []=(key,val)
        @values[key] = val
        @explicit[key] = true
      end
      def inspect()
        str = sprintf('#<Cx:0x%08x ',self.object_id)
        vary = {}
        @values.each { |k,v|
          name = k
          name += '_' unless @explicit[k]
          if v == true
            vary[name] = nil
          elsif v == false
            vary[name] = 'false'
          else 
            vary[name] = v
          end
        }
        strs = []
        vary.each { |k,v|
         if v.nil?
           strs << k
         else
           strs << "#{k}(#{v.inspect})"
         end
        }
        str += strs.join(',')
        str +='>'
        str
      end
      def bequeath()
        keys = %w[chomp strip closeoneof rename]
        q = {}
        p = {}
        ncx = Vars.new(q,p)
        keys.each { |key|
          ncx.set_(key,@values[key]) if @values.has_key?(key)
        }
        ncx
      end
      def bequeath0()
        q = @values.clone()
        p = @explicit.clone()
        keys = ['dirs_args','all']
        keys.each { |key|
          q.delete(key)
          p.delete(key)
        }
        Vars.new(q,p)
      end
      extend Forwardable
      def_instance_delegators(:@values,:[],:has_key?,:values_at,:keys)
    end
  end
#  module Cx
#    def init_cx
#      @cx = Vars.new
#    end
#    
#  end
end  
