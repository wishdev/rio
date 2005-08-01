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


require 'rio/abstract_method'
class ::Object #:nodoc: all
  def true?() true end
  def false?() false end
end
# 2314
module RIO
  module Match  #:nodoc: all
    module Entry
      class Base
        attr_reader :match_to
        def initialize(match_to)
          @match_to = match_to
        end
        def inspect()
          @match_to.to_s
        end
        def ===(el) self =~ el end 
        abstract_method :=~
                         
      end
      class Any < Base
        def =~(entry) true end
      end
      class None < Base
        def =~(entry) false end
      end
      class Glob < Base
        def =~(entry) Impl::U.fnmatch?(entry.filename.to_s,@match_to) end
      end
      class Regexp < Base
        def =~(entry) @match_to =~ entry.filename.to_s end
      end
      class Proc < Base
        def =~(entry) @match_to[entry] end
      end
      class Symbol < Base
        def =~(entry) entry.__send__(@match_to) end
      end
      def create(arg)
        case arg
        when ::String     then Glob.new(arg)
        when ::Regexp     then Regexp.new(arg)
        when ::Proc       then Proc.new(arg)
        when ::Symbol     then Symbol.new(arg)
        when ::TrueClass  then Any.new(arg)
        when ::FalseClass then None.new(arg)
        else raise ArgumentError,"a String,Regexp,Proc or Symbol is required (#{arg})"
        end
      end
      module_function :create
    end
  end
end
module RIO
  module Match
    module Entry
      class List
        def callstr(func,*args)
          self.class.to_s+'['+self.to_s+']'+'.'+func.to_s+'('+args.join(',')+')'
        end
        attr_reader :sym
        attr_accessor :list
        def initialize(sym,*args)
          @sym = sym
          @list = args.map { |arg| Match::Entry.create(arg) }
        end
        def inspect()
          @sym.to_s+"("+@list.inspect+")"
        end
        def <<(el)
          @list << el
        end
        def ===(me_list)
          @sym == me_list.sym
        end
        def =~(el)
          el.__send__(@sym) and (@list.empty? or @list.detect { |sel| sel =~ el })
        end
        extend Forwardable
        def_instance_delegators(:@list,:each)
      end
      class Sels < Array
        def <<(entry_list)
          same_sym = self.grep(entry_list)
          if same_sym.empty?
            super
          else
            same_sym[0].list = entry_list.list
          end
        end
      end
      class Selector
        def initialize(sel,nosel)
          @sel = sel
          @nosel = nosel
        end
        def inspect()
          str = sprintf('#<Selector:0x%08x',self.object_id)
          str += " @sel=#{@sel.inspect}"
          str += " @nosel=#{@nosel.inspect}"
          str += ">"
          str
        end

        private

        def yes?(el)
          @sel.nil? or @sel.detect { |match_entry| match_entry =~ el }
#          @sel.nil? or @sel.grep(el)
        end
        def no?(el)
          @nosel.detect { |match_entry| match_entry =~ el } unless @nosel.nil?
        end

        public

        def match?(el)
          yes?(el) and not no?(el)
        end
      end
    end
    
  end
end
