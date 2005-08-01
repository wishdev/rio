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
  module CxDir #:nodoc: all
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
