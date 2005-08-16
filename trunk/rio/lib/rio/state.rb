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


require 'rio/exception/state'
require 'rio/context'
require 'rio/context/methods'
require 'rio/ext'
require 'rio/symantics'
$trace_states = false
module RIO

                   
  module State #:nodoc: all
    # = State
    # the abstract state from which all are derived
    # this level handles 
    # * some basic house keeping methods
    # * the methods to communicate with the fs object
    # * the state changing mechanism
    # * and some basic error handling stubs
    class Base
      KIOSYMS = [:gets,:open,:readline,:readlines,:chop,:to_a,:putc,:puts,:print,:printf,:split,
                 :=~,:===,:==,:eql?,:sub,:sub!,:gsub,:gsub!]
      @@kernel_cleaned ||= KIOSYMS.each { |sym| undef_method(sym) } 
    end 
    
    class Base
      attr_accessor :rl
      attr_accessor :ioh
      attr_accessor :try_state
      attr_accessor :cx

      attr_accessor :handled_by

      # Context handling
      include Cx::Methods

      include RIO::Ext::Cx

      
      def initialize()
        @rl = @cx = @ioh = nil
#        @handled_by = self.class.to_s
      end

      def initialize_copy(*args)
        #p callstr('enter state initialize_copy',*args)
        super
        @rl = @rl.clone unless @rl.nil?
        @cx = @cx.clone unless @cx.nil?
        @ioh = @ioh.clone unless @ioh.nil?
      end

      def self.new_r(riorl)
        new.init(riorl,Cx::Vars.new( { 'closeoneof' => true, 'closeoncopy' => true } ))
      end
      def init(riorl,cntx,iohandle=nil)
        @rl = riorl
        @cx = cntx
        @ioh = iohandle
#        raise Exception::FailedCheck.new(self) unless check?
        self
      end
      
      def self.new_other(other)
        new.copy_state(other)
      end

      def copy_state(other)
        init(other.rl,other.cx,other.ioh)
      end

      # Section: State Switching

      # the method for changing states
      # it's job is create an instance of the next state
      # and change the value in the handle that is shared with the fs object
      def become(new_class,*args)
        p "become : #{self.class.to_s} => #{new_class.to_s} (#{self.mode?})" if $trace_states
#
        return self if new_class == self.class

        begin
          try_state[new_class,*args]
        rescue Exception::FailedCheck => ex
          p "not a valid "+new_class.to_s+": "+ex.to_s+" '"+self.to_s+"'"
          raise
        end
      end
      def method_missing_trace_str(sym,*args)
        "missing: "+self.class.to_s+'['+self.to_url+']'+'.'+sym.to_s+'('+args.join(',')+')'
      end
      def method_missing(sym,*args,&block)
        p method_missing_trace_str(sym,*args) if $trace_states

        obj = when_missing(sym,*args)
        raise RuntimeError,"when_missing returns nil" if obj.nil?
        obj.__send__(sym,*args,&block) #unless obj == self
      end
      
      def when_missing(sym,*args) gofigure(sym,*args) end


      def base_state() Factory.instance.reset_state(@rl) end

      def softreset 
        #p "softreset(#{self.class}) => #{self.base_state}"
        cx['retrystate'] = nil
        become(self.base_state) 
      end
      def retryreset 
        #p "retryreset(#{self.class}) => #{self.base_state}"
        become(self.base_state) 
      end
      def reset
        softreset()
      end

      # Section: Error Handling
      def gofigure(sym,*args)
        cs = "#{sym}("+args.map(&:to_s).join(',')+")"
        msg = "Go Figure! rio('#{self.to_s}').#{cs} Failed"
        error(msg,sym,*args)
      end

      def error(emsg,sym,*args)
        require 'rio/state/error'
        Error.error(emsg,self,sym,*args)
      end

      def to_rl() self.rl.rl end


      extend Forwardable
#      def_instance_delegators(:rl,:path,:to_s,:fspath,:opaque,:host,:length)
      def_instance_delegators(:rl,:path,:to_s,:fspath,:length)

#      def fspath() @rl.fspath end
#      def path() @rl.path() end
#      def opaque() @rl.opaque() end
#      def scheme() @rl.scheme() end
#      def host() @rl.host() end
#      def to_s() @rl.to_s() end
#      def length() @rl.length end


      def ==(other) @rl == other end
      def ===(other) self == other end
      def =~(other) other =~ self.to_s end
      def to_url() @rl.url end
      def to_uri() @rl.uri end
      alias to_str to_s

      def hash() @rl.to_s.hash end
      def eql?(other) @rl.to_s.eql?(other.to_s) end

      def stream?() false end

      # Section: Rio Interface
      # gives states the ability to create new rio objects
      # (should this be here???)
      def new_rio(arg0,*args,&block)
        #return arg0 if arg0.nil? # watch out for dir.read! if you remove this line
        Rio.rio(arg0,*args,&block)
      end
      def new_rio_cx(*args)
        n = new_rio(*args)
        n.cx = self.cx.bequeath
        n
      end
      def ensure_rio(arg0)
        return arg0 if arg0.kind_of?(::RIO::Rio)
        new_rio(arg0)
      end

      include Symantics

      def callstr(func,*args)
        self.class.to_s+'['+self.to_url+']'+'.'+func.to_s+'('+args.join(',')+')'
      end

    end

  end

end # module RIO
