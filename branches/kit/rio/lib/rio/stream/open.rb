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


require 'rio/ioh'
require 'rio/stream/base'
require 'rio/ops/stream'
require 'rio/ops/path'
require 'rio/cp'

module RIO
  module Stream
    class Open < Base
      include Ops::Stream::Status
      #include Ops::Path::Status
      include Ops::Path::URI
      #include Ops::Path::Query
      include Cp::Open::Output
      include Cp::Open::Input

      def check?() true end

      def open(m=nil,*args)
        #p callstr('open',m,*args)
        case

        when open? then open_(*args)
        when m.nil? then open_(*args)
        else mode(m).open_(*args)
        end
      end
      def open_(*args)
        #p callstr('open_',args.inspect)+" mode='#{mode?}' (#{mode?.class}) ioh=#{self.ioh} open?=#{open?}"
        unless open?
          ios = self.rl.open(mode?,*args)
          noclose_(false) if ios.tty?
          self.ioh = IOH::Stream.new(ios)
        end
        self
      end

      protected :open_
    end
  end
end



module RIO
  module Stream
    class Open < Base
      def size() 
        self.slurp.size
      end
      OUTPUT_SYMS = [:print,:printf,:puts,:putc,:write,
                     :print!,:printf!,:puts!,:putc!,:write!,
                     :put_,:putrec,:<,:<<
      ].build_hash { |sym| [sym.to_s,1] }
      def sym_state(sym,im,om)
       if OUTPUT_SYMS[sym.to_s] or RIO::Ext::OUTPUT_SYMS[sym.to_s]
         om ||= (sym.to_s == '<<' ? 'a' : 'w')
         #p "HEREHEREHERE om=#{om.inspect}"
         mode_(om).open_.output()
        else
         im ||= 'r'
         mode_(im).open_.input()
       end
      end

      def implicit_state(sym,*args)
        #p callstr('implicit_state',sym,*args) + " mode='#{mode?}' im='#{inputmode?}' om='#{outputmode?}'"
        case
        when (inputmode?.nil? and outputmode?.nil?)
          sym_state(sym,nil,nil)
        when outputmode?.nil?
          im = inputmode?
          if im.allows_both?
            mode_(im).open_.inout()
          else
            sym_state(sym,im,nil)
          end
        when inputmode?.nil?
          om = outputmode?
          if om.allows_both?
            mode_(om).open_.inout()
          else
            sym_state(sym,nil,om)
          end
        else
          sym_state(sym,inputmode?,outputmode?)
        end
      end
      def iostate(sym)
        #p callstr('iostate',sym)
        if mode? && mode?.allows_both?
          open_.inout()
        else
          implicit_state(sym)
        end
      end
      def when_missing(sym,*args) 
        #p callstr('when_missing',sym,*args)+" mode?(#{mode?.class})=#{mode?}"
        nobj = iostate(sym)
        return nobj unless nobj.nil?
        gofigure(sym,*args)
      end
      # TEMP
      def dir?() false end
      def stream_state(cl)
        #p "LOOP: retry:#{cx['retrystate']} => #{cl}" 
        return nil if cx['retrystate'] == cl
        cx['retrystate'] = cl

        become(cl).add_rec_methods.add_filters.add_extensions.setup
        #next_state.extend(Ops::Symlink::Existing) if symlink?
        #next_state
      end
      def output() 
        stream_state('Stream::Output')
      end
      def input() 
        stream_state('Stream::Input')
      end
      def inout() 
        stream_state('Stream::InOut')
      end
      
      def gofigure(sym,*args)
        super
      end
    end
    class Close < State::Base
      include Ops::Stream::Status
      def clear_selection()
        cx.delete('stream_sel')
        cx.delete('stream_nosel')
        self
      end
      def close_() 
        #p callstr('close_')+" mode='#{mode?}' ioh=#{self.ioh} open?=#{open?}"
        return self unless self.open? 
        #clear_selection
        self.ioh.close 
        self.ioh = nil
        self.rl.close
        self
      end
      protected :close_
      def close() 
        #p callstr('close')+" mode='#{mode?}' ioh=#{self.ioh} open?=#{open?}"
        return self unless self.open? 
        self.close_
        cx['retrystate'] = nil
        self
      end
      def getrec()
        self.close_.softreset
        nil
      end

      def check?() true end
      def base_state() 'Stream::Reset'  end
      def when_missing(sym,*args) 
#        p callstr('when_missing',sym,*args)
        self.close_.retryreset()
      end
    end

  end
end # module RIO
