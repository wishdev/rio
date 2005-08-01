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


# class String
#  def to_fs
#    require 'rio/resource'
#    RIO::Resource::Pathname.new(self)
#  end
# end
require 'singleton'
require 'rio/handle'
require 'rio/rl/builder'


module RIO

#  module TryState
#    attr_accessor :try_state
#  end
  class Factory  #:nodoc: all
    include Singleton
    def initialize()
      @ss_module = {}
      @reset_class = {}
      @state_class = {}
      @ss_class = {}
    end
    def subscheme_module(sch)
      @ss_module[sch] ||= case sch
                          when 'file','path'
                            require 'rio/scheme/path'
                            Path
                          when 'stdio','stdin','stdout'
                            require 'rio/scheme/stdio'
                            StdIO
                          when 'stderr'
                            require 'rio/scheme/stderr'
                            StdErr
                          when 'tempfile'
                            require 'rio/scheme/tempfile'
                            Tempfile
                          when 'strio'
                            require 'rio/scheme/strio'
                            StrIO
                          when 'aryio'
                            require 'rio/scheme/aryio'
                            AryIO
                          when 'http','https'
                            require 'rio/scheme/http'
                            HTTP
                          when 'ftp'
                            require 'rio/scheme/ftp'
                            FTP
                          when 'tcp'
                            require 'rio/scheme/tcp'
                            TCP
                          when 'sysio'
                            require 'rio/scheme/sysio'
                            SysIO
                          when 'fd'
                            require 'rio/scheme/fd'
                            FD
                          when 'cmdio'
                            require 'rio/scheme/cmdio'
                            CmdIO
                          else
                            require 'rio/scheme/path'
                            Path
                          end
    end

    def riorl_class(sch)
      subscheme_module(sch).const_get(:RL) 
    end

    def reset_state(rl)
      mod = subscheme_module(rl.scheme)
      mod.const_get(:RESET_STATE) unless mod.nil?
      #p st
#       @reset_class[st] ||= case st
#                            when 'Path::Reset'
#                              require 'rio/path/reset'
#                              Path::Reset
#                            when 'Stream::Open'
#                              require 'rio/stream/open'
#                              Stream::Open
#                            else
#                              raise ArgumentError,"Unknown RESET_STATE (#{st})"
#                            end
      

    end
    STATE2FILE = {
      'Path::Reset' => 'rio/path/reset',
      'Path::Empty' => 'rio/path',
      'Path::Str' => 'rio/path',
      'Path::NonExisting' => 'rio/path',

      'File::Existing' => 'rio/file',
      'File::NonExisting' => 'rio/file',

      'Dir::Existing' => 'rio/dir',
      'Dir::Open' => 'rio/dir',
      'Dir::Close' => 'rio/dir',
      'Dir::Stream' => 'rio/dir',
      'Dir::NonExisting' => 'rio/dir',

      'Stream::Close' => 'rio/stream/open',
      'Stream::Reset' => 'rio/stream',

      'Stream::Open' => 'rio/stream/open',
      'Stream::Input' => 'rio/stream',
      'Stream::Output' => 'rio/stream',
      'Stream::InOut' => 'rio/stream',

      'Stream::Duplex::Open' => 'rio/stream/duplex',
      'Stream::Duplex::Input' => 'rio/stream/duplex',
      'Stream::Duplex::Output' => 'rio/stream/duplex',
      'Stream::Duplex::InOut' => 'rio/stream/duplex',

      'Path::Stream::Input' => 'rio/scheme/path',
      'Path::Stream::Output' => 'rio/scheme/path',
      'Path::Stream::InOut' => 'rio/scheme/path',
      'Path::Stream::Open' => 'rio/scheme/path',

      'StrIO::Stream::Input' => 'rio/scheme/strio',
      'StrIO::Stream::Output' => 'rio/scheme/strio',
      'StrIO::Stream::InOut' => 'rio/scheme/strio',
      'StrIO::Stream::Open' => 'rio/scheme/strio',

      'HTTP::Stream::Input' => 'rio/scheme/http',
      'HTTP::Stream::Open' => 'rio/scheme/http',

      'FTP::State::Dir' => 'rio/ftp',
      'FTP::State::File' => 'rio/ftp',
      'FTP::State::Reset' => 'rio/ftp',
      'FTP::State::Open' => 'rio/ftp',
      'FTP::Stream::Input' => 'rio/ftp',
      'FTP::Stream::Open' => 'rio/ftp',
      'FTP::Stream::Close' => 'rio/ftp',
      'FTP::Stream::Reset' => 'rio/ftp',

      'AryIO::Stream::Input' => 'rio/scheme/aryio',
      'AryIO::Stream::Output' => 'rio/scheme/aryio',
      'AryIO::Stream::InOut' => 'rio/scheme/aryio',
      'AryIO::Stream::Open' => 'rio/scheme/aryio',
    }
    def state2class(state_name)
      #p "state_name=#{state_name}"
      return @state_class[state_name] if @state_class.has_key?(state_name)
      if STATE2FILE.has_key?(state_name)
        require STATE2FILE[state_name]
        return @state_class[state_name] = RIO.module_eval(state_name)
      else
        raise ArgumentError,"Unknown State Name (#{state_name})" 
      end
    end
    def try_state_proc(current_state,rio_handle)
      proc { |new_state_name|
#        new_state_class = state2class(new_state_name)
        _change_state(state2class(new_state_name),current_state,rio_handle)
      }
    end

    def _change_state(new_state_class,current_state,rio_handle)
      # wipe out the reference to this proc so GC can get rid of rsc
      current_state.try_state = proc { p "try_state for "+current_state.to_s+" used already??" }
      new_state = new_state_class.new_other(current_state)
      new_state.try_state = try_state_proc(new_state,rio_handle)
      
      rio_handle.target = new_state
      return rio_handle.target
    end
    private :_change_state

    # factory creates a state from args
    def create_state(*args)
      riorl = RIO::RL::Builder.build(*args)
#      state_class = state2class(reset_state(riorl))
      create_handle(state2class(reset_state(riorl)).new_r(riorl))
    end
    def clone_state(state)
      create_handle(state.clone)
    end
    def create_handle(new_state)
      hndl = Handle.new(new_state)
      new_state.try_state = try_state_proc(new_state,hndl)
      hndl
    end

  end
end


if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

__END__

require 'test/unit'

