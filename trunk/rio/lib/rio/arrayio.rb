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



module RIO
  class NotSupportedException < ArgumentError  #:nodoc: all
    def self.emsg(fname,obj)
      "#{fname}() is not supported for #{obj.class} objects" 
    end

  end
  class AIOMode #:nodoc: all
    def initialize(mode_string)
      @str = mode_string
    end
    def to_s() @str end
    def can_write?
      @str =~ /^[aw]/ or @str =~ /\+/
    end
    def can_read?
      @str =~ /^r/ or @str =~ /\+/
    end
    def appends?
      @str =~ /^a/
    end
    def =~(re)
      re =~ @str
    end
  end
  class AIOH  #:nodoc: all
    attr_accessor :array,:lineno,:mode,:ln
    def initialize(a,m)
      @array = a || []
      @mode = AIOMode.new(m)
      @lineno = 0
      @ln = 0
    end
  end

  class ArrayIO  #:nodoc: all
    def initialize(a=nil,m='r')
#      p "#{callstr('initialize',a,m)} hnd=#{@hnd.inspect}"
      raise ArgumentError,"ArrayIO.new() requires an array but got #{a.inspect}" unless a.kind_of?(::Array)
      a = a.array if a.kind_of?(ArrayIO)
      @hnd = AIOH.new(a,m)
      _open(@hnd.mode)
    end
    def array() @hnd.array end
    def array=(a) @hnd.array = a end
    def lineno() @hnd.lineno end
    def lineno=(a) @hnd.lineno = a end
    def to_a() array.dup end

    def _open(m)
      @hnd.mode = AIOMode.new(m.to_s)
      @hnd.ln = 0
#      p m.to_s,@hnd.mode.to_s,@hnd.array
      @hnd.array.clear if @hnd.mode.to_s =~ /^w/
      @hnd.ln = @hnd.array.size if @hnd.mode.to_s =~ /^a/
    end
    def self.open(a=nil,m='r',&block)
      rtn = io = self.class.new(a,m)
      if block_given?
        rtn = yield(io)
        io.close
      end
      rtn
    end
    def fileno() nil end
    def flush() nil end
    def fsync() nil end
    def isatty() false end
    def tty?() false end
    def pos() @hnd.ln end
    def pos=(n) @hnd.ln = n end

    def readchar() raise NotSupportedException,NotSupportedException.emsg('readchar',self) end
    def read() raise NotSupportedException,NotSupportedException.emsg('read',self) end
    def getc() raise NotSupportedException,NotSupportedException.emsg('getc',self) end

    def closed?
      @hnd.ln.nil?
    end
    def close_read
      @hnd.ln = @hnd.lineno = nil
    end
    def close_write
      @hnd.ln = nil
    end
    def close
      close_read
      close_write
    end
    def eof?()
      raise IOError,"ArrayIO is not open for reading" unless @hnd.mode.can_read?
      @hnd.ln >= @hnd.array.size
    end
    def each_line(sep_string=$/,&block) 
      while line = gets(sep_string)
        yield(line)
      end
      self
    end
    alias each each_line
    def gets(sep_string=$/)
      raise IOError,"ArrayIO is not open for reading" unless @hnd.mode.can_read?
      return nil if @hnd.ln >= @hnd.array.size
      str = nil
      if sep_string.nil?
        str = @hnd.array[@hnd.ln...@hnd.array.size].join('')
        @hnd.lineno += @hnd.array.size - @hnd.ln
        @hnd.ln = @hnd.array.size
      else
        str = @hnd.array[@hnd.ln]
        @hnd.lineno += 1
        @hnd.ln += 1
      end
      $_ = str
    end
    def readline(sep_string=$/)
      raise EOFError unless str = gets(sep_string)
      str
    end
    
    def readlines(sep_string=$/)
      ary = []
      until eof?
        ary.push(gets(sep_string))
      end
      ary
    end
    def rewind
      @hnd.ln = @hnd.lineno = 0
    end
    def print(*objs)
      raise IOError,"ArrayIO is not open for writing" unless @hnd.mode.can_write?
      if objs.empty?
        @hnd.array[@hnd.ln] = $_
        @hnd.ln += 1
      else
        for obj in objs
          @hnd.array[@hnd.ln] = obj.to_s
          @hnd.ln += 1
        end
      end
      nil
    end
    def <<(obj)
      print(obj.to_s)
      self
    end
    def puts(*objs)
      for obj in objs
        print(obj.to_s.chomp + $/)
      end
    end
    def printf(fmt,*args)
      print(sprintf(fmt,*args))
    end
    def callstr(func,*args)
      self.class.to_s+'['+self.to_s+']'+'.'+func.to_s+'('+args.join(',')+')'
    end
    
  end
end
