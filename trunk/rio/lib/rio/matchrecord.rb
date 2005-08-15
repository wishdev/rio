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
  module Match #:nodoc: all
    module Record
      
      class Base
        def initialize(arg)
        @select_arg = arg
        end
        def inspect
          @select_arg.inspect
        end
        def val()
          @select_arg
        end
        def match_all?() false end
        def match_none?() false end
      end
      class All < Base
        def match?(val,recno) true end
        def match_all?() true end
        def =~(record) true end
      end
      class None < Base
        def match?(val,recno) false end
        def match_none?() true end
        def =~(record) false end
      end
      class RegExp < Base
        def match?(val,recno) 
          @select_arg.match(val)
        end
        def =~(record) 
          @select_arg =~ record 
        end
      end
      class Range < Base
        def match?(val,recno)
          #p "match?(#{val},#{recno}) select_arg=#{@select_arg}"
          @select_arg === recno
        end
        def =~(record) 
          #p "=~(#{record},#{record.recno}) select_arg=#{@select_arg}"
          @select_arg === record.recno 
        end
      end
      class Fixnum < Base
        def match?(val,recno)
          #p "match?(#{val},#{recno}) select_arg=#{@select_arg}"
          @select_arg === recno
        end
        def =~(record) 
          #p "=~(#{record},#{record.recno}) select_arg=#{@select_arg}"
          @select_arg === record.recno 
        end
      end
      class Proc < Base
        def initialize(arg,therio)
          super(arg)
          @therio = therio
        end
        def match?(val,recno)
          #p "match?(#{val},#{recno}) select_arg=#{@select_arg}"
          @select_arg.call(val,recno,@therio)
        end
        def =~(record)
          @select_arg.call(record,record.recno,@therio)
        end
      end
      class Symbol < Base
        def match?(val,recno)
          #p "match?(#{val},#{recno}) select_arg=#{@select_arg}"
          val.__send__(@select_arg)
        end
        def =~(record)
          record.__send__(@select_arg)
        end
      end
    end
  end

  module Match
    module Record
      # for a sellist
      # nil indicates no call was made, so nothing selected
      # empty indicates a call was made, so all selected
      # contents should be checked for matches
      # if contents are removed the list should become nil, not empty
      class SelList
        def initialize(therio,args)
          if args.nil?
            @list = nil
          else
            @list = []
            args.each do |arg|
              @list << create_sel(therio,arg)
            end
          end
          #p "SelList(#{args.inspect},#{@list.inspect})"
        end
        def inspect
          @list.inspect
        end
        def size() @list.size unless @list.nil? end
        def only_one_fixnum?()
          @list && @list.size == 1 && @list[0].kind_of?(Match::Record::Fixnum)
        end
        def delete_at(index)
          @list.delete_at(index)
          @list = nil if @list.empty?
        end
        def self.create(therio,args)
          new(therio,args) unless args.nil?
        end
        def ranges()
          @list.nil? ? [] : @list.select { |sel| sel.kind_of?(Record::Range) }
        end
        def remove_passed_ranges(n)
          return nil if @list.nil?
          return self if @list.empty?
          newlist = []
          @list.each do |sel| 
            newlist << sel unless sel.kind_of?(Match::Record::Range) and sel.val.max < n 
          end
          @list = (newlist.empty? ? nil : newlist) if newlist.length != @list.length
          @list.nil? ? nil : self
        end
        def create_sel(therio,arg)
          case arg
          when ::Regexp
            Match::Record::RegExp.new(arg)
          when ::Range
            Match::Record::Range.new(arg)
          when ::Proc
            Match::Record::Proc.new(arg,therio)
          when ::Symbol
            Match::Record::Symbol.new(arg)
          when ::Fixnum
            Match::Record::Fixnum.new(arg)
          else
            raise ArgumentError,"Argument must be a Regexp,Range,Fixnum,Proc, or Symbol"
          end
        end
        def match?(val,recno)
          # !@list.nil? && (@list.empty? || @list.detect { |sel| sel.match?(val,recno) } || false) && true
          return false if @list.nil?
          return true if @list.empty?
          as = nil
          al = @list.detect { |sel| as = sel.match?(val,recno)
            #p "1: #{$1} as[match?]: #{as.inspect}"
            as
          }
          #p "[SelList.match?] as:#{as.inspect} al:#{al.inspect}"
          return as if al
          return false
        end
        def =~(el)
          !@list.nil? && (@list.empty? || @list.detect { |sel| sel =~ el } || false) && true
        end
        def always?() !@list.nil? && @list.empty? end
        def never?() @list.nil? end
      end


      class SelRej
        def initialize(therio,sel_args,rej_args)
          @sel = SelList.create(therio,sel_args)
          @rej = SelList.create(therio,rej_args)
          @always = init_always()
        end
        def only_one_fixnum?()
          @rej.nil? && @sel && @sel.only_one_fixnum?
        end
        def init_always(reset=false)
          if @sel.nil? and @rej.nil?
            !reset
          elsif @rej.nil? and @sel.always?
            true
          elsif @sel.nil?
            false
          elsif !@rej.nil? and @rej.always?
            false
          else
            nil
          end
        end
        def remove_passed_ranges(n)
          @sel = @sel.remove_passed_ranges(n) unless @sel.nil?
          @rej = @rej.remove_passed_ranges(n) unless @rej.nil?
          @always = init_always(true)
          self
        end
        def rangetops()
          rtops = ranges.map { |r| r.val.max }.sort.uniq
          rtops.empty? ? nil : rtops
        end
        def ranges()
          (@sel.nil? ? [] : @sel.ranges) + (@rej.nil? ? [] : @rej.ranges)
        end
        def class_tail
          self.class.to_s.sub(/^.+::/,'')
        end
        def inspect
          sprintf("#<%s:0x%08x @always=%s @sel=%s @rej=%s>",self.class_tail,self.object_id,@always.inspect,
                  @sel.inspect,@rej.inspect)
        end
        def always?()
          @always == true
        end
        def never?()
          @always == false
        end
        def match?(val,recno)
          #p "match?(#{val},#{recno}) #{self.inspect}"
          return @always unless @always.nil?
          as = nil
          ok = ((!@sel.nil? && (as = @sel.match?(val,recno))) && !(!@rej.nil? && @rej.match?(val,recno)))
          return (ok ? as : ok)
        end
        def =~(el)
          return @always unless @always.nil?
          (!@sel.nil? && (@sel =~ el)) && !(!@rej.nil? && (@rej =~ el))

          #yes = (!@sel.nil? && (@sel =~ el))
          #no = (!@rej.nil? && (@rej =~ el))
          #p "yes=#{yes} no=#{no} el=#{el}"
          #return yes && !no
          #(@sel =~ el) && !(@rej =~ el)
        end
      end
    end
  end
end




