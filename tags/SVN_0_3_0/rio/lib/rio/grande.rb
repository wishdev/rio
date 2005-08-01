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
  end
end
module RIO
  module Grande
    module Dir

      def each_(*args,&block)
        #p "#{callstr('each_',*args)} sel=#{cx['sel'].inspect} nosel=#{cx['nosel'].inspect}"
        sel = Match::Entry::Selector.new(cx['sel'],cx['nosel'])
        selfstr = (self.to_s == '.' ? nil : self.to_s)
        self.ioh.each do |estr|
          next if estr =~ /^\.(\.)?$/
          begin
            erio = new_rio_cx(selfstr ? Impl::U.join(selfstr,estr) : estr )
            
            if stream_iter?
              _add_stream_iter_cx(erio).each(&block) if erio.file? and sel.match?(erio)
            else
              yield _add_iter_cx(erio) if sel.match?(erio)
            end
            
            if cx.has_key?('all') and erio.dir?
              rsel = Match::Entry::Selector.new(cx['r_sel'],cx['r_nosel'])
              _add_recurse_iter_cx(erio).each(&block) if rsel.match?(erio)
            end
            
          rescue ::Errno::ENOENT, ::URI::InvalidURIError => ex
            $stderr.puts(ex.message+". Skipping.")
          end
        end
        closeoneof? ? self.close.softreset : self
      end



      private
      
      def _ss_keys()  Cx::SS::ENTRY_KEYS + Cx::SS::STREAM_KEYS end
      CX_ALL_SKIP_KEYS = ['retrystate']
      def _add_recurse_iter_cx(ario)
        new_cx = ario.cx
        cx.keys.reject { |k| CX_ALL_SKIP_KEYS.include?(k) }.each { |k|
          new_cx.set_(k,cx[k])
        }
        ario.cx = new_cx
        ario
      end
      def _add_cx(ario,keys)
        new_cx = ario.cx
        keys.each {|k|
          next unless cx.has_key?(k)
          new_cx.set_(k,cx[k])
        }
        ario.cx = new_cx
      end
      CX_DIR_ITER_KEYS = %w[sel nosel]
      CX_STREAM_ITER_KEYS = %w[stream_rectype stream_itertype stream_sel stream_nosel]
      def _add_iter_cx(ario)
        if nostreamenum?
          _add_cx(ario,CX_DIR_ITER_KEYS)
        end
        _add_stream_iter_cx(ario)
      end
      def _add_stream_iter_cx(ario)
        _add_cx(ario,CX_STREAM_ITER_KEYS)
        new_cx = ario.cx
        if stream_iter?
          new_cx.set_('ss_args',cx['ss_args']) if cx.has_key?('ss_args')
          new_cx.set_('ss_type',cx['ss_type']) if cx.has_key?('ss_type')
        end
        ario.cx = new_cx
        ario
      end
    end
  end
end
