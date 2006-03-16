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


require 'rio/state'
require 'rio/ops/path'
require 'rio/ops/file'

module RIO


  module File #:nodoc: all
    class Base < State::Base
      include Ops::Path::Str

      protected

      def stream_rl_
        RIO::File::RL.new(self.to_uri,{:fs => self.fs})
      end

      public

      def fstream() 
        #p self.rl.class
        self.rl = self.stream_rl_
        become 'Path::Stream::Open'
      end

      def when_missing(sym,*args) 
        fstream() 
      end
    end
    
    class NonExisting < Base
      include Ops::File::NonExisting
      def check?() !exist? end
    end

    class Existing < Base
      include Ops::File::Existing
      def check?() self.file? end
      def each(*args,&block)
        #p "#{callstr('each',*args)} ss_type=#{ss_type?}"
        if ss_type? == 'files' and !stream_iter?
          #sel = Match::Entry::Selector.new(cx['sel'],cx['nosel'])
          sel = Match::Entry::Selector.new(cx['entry_sel'])
          yield new_rio_cx(self) if sel.match?(self)
        else
          fstream.each(*args,&block)
        end
      end
    end
    
  end
  
end
