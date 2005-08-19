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

#


require 'rio/version'
require 'rio/base'
require 'rio/exception'
require 'extensions/symbol'
require 'extensions/enumerable'
require 'extensions/string'
require 'forwardable'
$trace_states = false
module RIO 
  # See also: RIO::Doc::SYNOPSIS; RIO::Doc::INTRO; RIO::Doc::HOWTO.
  class Rio < Base #:doc:
  end
end

require 'rio/kernel'
require 'rio/constructor'

module RIO
  SEEK_SET = IO::SEEK_SET
  SEEK_END = IO::SEEK_END
  SEEK_CUR = IO::SEEK_CUR
end

module RIO
  class Rio #:doc:
    require 'rio/local'
    include Local
    require 'rio/factory'
    
    protected

    attr_reader :state

    public

    # See RIO.rio
    def initialize(*args)
      @state = Factory.instance.create_state(*args)
    end

    def initialize_copy(*args)
      #p callstr("initialize_copy",*args)
      super
      @state = Factory.instance.clone_state(@state)
    end

    # See RIO.rio
    def self.rio(*args,&block) # :yields: self
      ario = new(*args)
      if block_given?
        old_closeoncopy = ario.closeoncopy?
        begin
          yield ario.nocloseoncopy
        ensure
          ario.reset.closeoncopy(old_closeoncopy)
        end
      end
      ario
    end

    def open(m,*args,&block) 
      target.open(m,*args)
      if block_given?
        old_closeoncopy,old_closeoneof = closeoncopy?,closeoneof?
        begin
          return yield(nocloseoncopy.nocloseoneof)
        ensure
          reset.closeoncopy(old_closeoncopy).closeoneof(old_closeoneof)
        end
      end
      self 
    end

    # returns the Rio#fspath, which is the path for the Rio on the underlying filesystem
    def to_s() target.to_s end
    alias :to_str :to_s
    def dup
      self.class.new(self.to_s)
    end

  def method_missing(sym,*args,&block) #:nodoc:
    #p callstr('method_missing',sym,*args)

    result = target.__send__(sym,*args,&block)
    return result unless result.kind_of? State::Base and result.equal? target

    self
  end

    def inspect()
      cl = self.class.to_s[5..-1]
      st = state.target.class.to_s[5..-1]
      sprintf('#<%s:0x%x:"%s" (%s)>',cl,self.object_id,self.to_url,st)
    end
    
    USE_IF = true #:nodoc:

    if USE_IF
      require 'rio/if'
      include Enumerable
    end
    protected

    def target() @state.target end

    def callstr(func,*args)
      self.class.to_s+'.'+func.to_s+'('+args.join(',')+')'
    end

  end # class Rio
end # module RIO


if $0 == __FILE__
  eval DATA.read, nil, $0, __LINE__+4
end

__END__

puts
puts("Run the tests that came with the distribution")
puts("From the distribution directory use 'test/runtests.rb'")
puts
