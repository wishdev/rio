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
      class Depth < Base
        def =~(entry)
          @match_to === entry.rl.pathdepth
        end
      end
      class Any < Base
        def =~(entry) true end
      end
      class None < Base
        def =~(entry) false end
      end
      class Glob < Base
        def =~(entry) 
          ::File.fnmatch?(@match_to,entry.filename.to_s) 
        end
      end
      class Regexp < Base
        def =~(entry) 
          @match_to =~ entry.filename.to_s 
        end
      end
      class PathGlob < Base
        def =~(entry) 
          ::File.fnmatch?(@match_to,entry.to_s) 
        end
      end
      class PathRegexp < Base
        def =~(entry) 
          @match_to =~ entry.to_s 
        end
      end
      class Proc < Base
        def =~(entry) @match_to[entry] end
      end
      class Symbol < Base
        def =~(entry) entry.__send__(@match_to) end
      end
      class And < Base
        def initialize(matches)
          super(matches.flatten.map { |arg| Match::Entry.create(arg) })
        end
        def =~(el)
          (@match_to.empty? or @match_to.all? { |sel| sel =~ el })
        end
      end
      def create(arg)
        case arg
        when ::Fixnum     then Depth.new(arg)
        when ::Range     then Depth.new(arg)
        when ::String     then Glob.new(arg)
        when ::Regexp     then Regexp.new(arg)
        when ::Proc       then Proc.new(arg)
        when ::Symbol     then Symbol.new(arg)
        when ::TrueClass  then Any.new(arg)
        when ::FalseClass then None.new(arg)
        when ::Array      then And.new(arg)
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
        def callstr(func,*args)
          self.class.to_s+'['+self.to_s+']'+'.'+func.to_s+'('+args.join(',')+')'
        end
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
        def callstr(func,*args)
          self.class.to_s+'['+self.to_s+']'+'.'+func.to_s+'('+args.join(',')+')'
        end
      end
      class Selector
        attr_reader :sel,:nosel
        def initialize(entry_sel)
          @entry_sel = entry_sel
          @sel = @nosel = nil
          process_entry_sel() if @entry_sel
        end
        def es_args() 
          es = @entry_sel
          es['args']
        end
        def something_selected?
          %w[entries files dirs].any? { |k| es_args.has_key?(k) }
        end
        def something_skipped?
          %w[skipentries skipfiles skipdirs].any? { |k| es_args.has_key?(k) }
        end
        def skip_type(skip_args)
          
        end
        def process_entry_sel()
          ea = es_args
          raise RuntimeError, "Internal error: entry_sel_args not set" unless ea
          if something_selected?
            @sel = Match::Entry::Sels.new 
            @sel << Match::Entry::List.new(:true?,*ea['entries']) if ea.has_key?('entries')
            @sel << Match::Entry::List.new(:file?,*ea['files']) if ea.has_key?('files')
            @sel << Match::Entry::List.new(:dir?,*ea['dirs']) if ea.has_key?('dirs')
          end
          if something_skipped?
            @nosel = Match::Entry::Sels.new 
            if ea.has_key?('skipentries')
              @nosel << Match::Entry::List.new(:true?,*ea['skipentries'])
            end
            if ea.has_key?('skipfiles')
              @nosel << Match::Entry::List.new(:file?,*ea['skipfiles'])
              unless ea['skipfiles'].empty? or ea.has_key?('files')
                @sel ||= Match::Entry::Sels.new 
                @sel << Match::Entry::List.new(:file?)
              end
            end
            if ea.has_key?('skipdirs')
              @nosel << Match::Entry::List.new(:dir?,*ea['skipdirs'])
              unless ea['skipdirs'].empty? or ea.has_key?('dirs')
                @sel ||= Match::Entry::Sels.new 
                @sel << Match::Entry::List.new(:dir?)
              end
            end
          end
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
        def callstr(func,*args)
          self.class.to_s+'['+self.to_s+']'+'.'+func.to_s+'('+args.join(',')+')'
        end
      end
      class SelectorClassic < Selector
        def initialize(sel,nosel)
          @sel = sel
          @nosel = nosel
        end
      end
    end
  end
end
