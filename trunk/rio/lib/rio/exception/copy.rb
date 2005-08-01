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


require 'rio/exception'
module RIO
  module Exception
    class Copy < Base
      attr :syserr
      attr :src
      attr :dst
      def initialize(s,d,rerror)
        @src = ::RIO::Rio.new(s)
        @dst = ::RIO::Rio.new(d)
        @syserr = rerror
      end
      def submsg(s)
        "\n\t" + s
      end
      def file_info(f)
        return unless f.file?
        "is a file"
      end
      def symlink_info(f)
        return unless f.symlink?
        t = f.readlink
        s = "is a symlink refering to #{t}"
        f.dirname.chdir {
          s += submsg("   : '#{t}' " + finfo(t))
        }
        return s
      end
      def dir_info(f)
        return unless f.dir?
        return "is a directory"
      end
      def finfo(f)
        case 
        when (not f.exist?)
          return "does not exist"
        when f.symlink?
          return symlink_info(f)
        when f.dir?
          return dir_info(f)
        when f.file?
          return file_info(f)
        end
        return ""
      end
      def explain()
        s = "#{self.class}: failed copying '#{@src}' => #{@dst}"
        s += submsg("Err: #{@syserr}") if @syserr
        s += submsg("Src: '#{@src}' " + finfo(@src))
        s += submsg("Dst: '#{@dst}' " + finfo(@dst))
        target = ::RIO::rio(@dst,@src.filename) if @dst.dir?
        p target
        if target.exist?
          s += submsg("Tgt: '#{target} " + finfo(target))
        end
                              
        s += "\n"
      end
    end
  end
end
