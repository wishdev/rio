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


require 'rio/impl/path'
module RIO
  module Ops #:nodoc: all
    module Path
      module Test
        def blockdev?(*args) Impl::U.blockdev?(self.to_s,*args) end
        def chardev?(*args) Impl::U.chardev?(self.to_s,*args) end
        def directory?(*args) Impl::U.directory?(self.to_s,*args) end
        def exist?(*args) Impl::U.exist?(self.to_s,*args) end
        def file?(*args) Impl::U.file?(self.to_s,*args) end
        def pipe?(*args) Impl::U.pipe?(self.to_s,*args) end
        def socket?(*args) Impl::U.socket?(self.to_s,*args) end
        def symlink?(*args) Impl::U.symlink?(self.to_s,*args) end
        alias :dir? :directory?
        def open?() not self.closed? end
        def closed?() self.ioh.nil? end
      end
      module Status
        include Test
        def fnmatch(*args) Impl::U.fnmatch(self.to_s,*args) end
        def fnmatch?(*args) Impl::U.fnmatch?(self.to_s,*args) end
        def ftype(*args) Impl::U.ftype(self.to_s,*args) end
        def stat(*args) Impl::U.stat(self.to_s,*args) end
        def atime(*args) Impl::U.atime(self.to_s,*args) end
        def ctime(*args) Impl::U.ctime(self.to_s,*args) end
        def mtime(*args) Impl::U.mtime(self.to_s,*args) end
        def executable?(*args) Impl::U.executable?(self.to_s,*args) end 
        def executable_real?(*args) Impl::U.executable_real?(self.to_s,*args) end 
        def readable?(*args) Impl::U.readable?(self.to_s,*args) end 
        def readable_real?(*args) Impl::U.readable_real?(self.to_s,*args) end 
        def writable?(*args) Impl::U.writable?(self.to_s,*args) end 
        def writable_real?(*args) Impl::U.writable_real?(self.to_s,*args) end
        def sticky?(*args) Impl::U.sticky?(self.to_s,*args) end 
        def owned?(*args) Impl::U.owned?(self.to_s,*args) end 
        def grpowned?(*args) Impl::U.grpowned?(self.to_s,*args) end 
        def setgid?(*args) Impl::U.setgid?(self.to_s,*args) end 
        def setuid?(*args) Impl::U.setuid?(self.to_s,*args) end
        def size(*args) Impl::U.size(self.to_s,*args) end 
        def size?(*args) Impl::U.size?(self.to_s,*args) end 
        def zero?(*args) Impl::U.zero?(self.to_s,*args) end
        def root?(*args) Impl::U.root?(self.to_s) end

      end
      module URI
        def abs(base=nil)
          if base.nil?
            new_rio(rl.abs)
          else
            new_rio(rl,ensure_rio(base).abs.to_uri).abs
          end
        end
        def abs?
          rl.abs?
        end
        alias :absolute? :abs?
        def route_from(other)
          new_rio(rl.abs.route_from(ensure_rio(other).rl.abs))
        end
        def rel(other)
          route_from(other)
        end
#        def rel(other=nil)
#          if other.nil?
#            route_from(other)
#          else
#            route_from(base.to_url + '/')
#          end
#        end
        def route_to(other)
          new_rio(rl.abs.route_to(ensure_rio(other).rl.abs))
        end
        def merge(other)
          new_rio(rl.merge(ensure_rio(other).rl))
        end
        def base(b=nil)
          new_rio(rl.base(b))
        end
        def setbase(b)
          rl.base(b)
          self
        end
        extend Forwardable
        def_instance_delegators(:rl,:scheme,:host,:opaque)

      end
      module Query
        def expand_path(*args)
          args[0] = args[0].to_s unless args.empty?
          new_rio(RL.fs2url(Impl::U.expand_path(self.to_s,*args)))
        end
        def extname(*args) 
          en = Impl::U.extname(rl.path_no_slash,*args) 
          (en.empty? ? nil : en)
        end
        def split()
          require 'rio/to_rio'
          pth = rl.path_no_slash
          parts = pth.split(RIO::Local::SEPARATOR)
          if abs?
            rooturi = rl.uri.clone
            rooturi.path = '/'
            parts[0] = rooturi
          end
          # give each rio the correct base
          parts.inject([rio(parts.shift)]) { |ary,d| ary << rio(d,{ 'base' => ary[-1].abs.to_url+'/'} ) }.extend(ToRio::Array)
        end
        def basename(*args)
          unless args.empty?
            ex = args[0] || self.extname
            self.ext(ex)
          end
          #p self.ext?.inspect
          fn = Impl::U.basename(rl.path_no_slash,self.ext?)
          new_rio(fn,{'base' => _calc_base()})
        end
        def filename()
          fn = Impl::U.basename(rl.path_no_slash)
          new_rio(fn,{'base' => _calc_base()})
        end
        def _calc_base()
          dn = Impl::U.dirname(rl.path_no_slash)
          if dn[0] == ?/
            dn 
          else
            self.base.to_url + dn + '/'
          end
        end
        def dirname(*args)
          new_rio(Impl::U.dirname(rl.path_no_slash,*args))
        end

        def sub(re,arg)
          new_rio(softreset.to_s.sub(re,arg.to_s))
        end
        def gsub(re,arg)
          new_rio(softreset.to_s.gsub(re,arg.to_s))
        end

        def +(arg)
          new_rio(softreset.to_str + ensure_rio(arg).to_str)
        end

        private

        def _path_with_basename(arg)
          old =  rl.path_no_slash
          old[0,old.length-basename.length-ext?.length]+arg.to_s+ext?
        end
        def _path_with_filename(arg)
          old =  rl.path_no_slash
          old[0,old.length-filename.length]+arg.to_s
        end
        def _path_with_ext(ex)
          old =  rl.path_no_slash
          old[0,old.length-ext?.length]+ex
        end
        def _path_with_dirname(arg)
          old =  rl.path_no_slash
          arg.to_s + old[-(old.length-dirname.length),old.length]
        end
      end
      module Change
        def sub!(*args)
          rl.path = rl.path.sub(*args)
          softreset
        end
        
        def rename(*args,&block)
          if args.empty?
            cxx('rename',true,&block)
          else
            rtn = must_exist.rename(*args)
            return rtn.each(&block) if block_given?
            rtn
          end
        end
        def rename?() cxx?('rename') end
        def norename(arg=false,&block) nocxx('rename',&block) end
        
        def filename=(arg)
          if cx['rename']
            must_exist.filename = arg
          else
            rl.path = _path_with_filename(arg)
            softreset
          end
        end
        
        def basename=(arg)
          if cx['rename']
            must_exist.basename = arg
          else
            rl.path = _path_with_basename(arg)
            softreset
          end
        end
        
        def extname=(arg)
          #p callstr('extname=',arg)
          
          if cx['rename']
            must_exist.extname = arg
          else
            rl.path = _path_with_ext(arg)
            softreset
          end
        end
        
        def dirname=(arg)
          if cx['rename']
            must_exist.dirname = arg
          else
            rl.path = _path_with_dirname(arg)
            softreset
          end
        end
        
      end
    end 
  end
end
require 'rio/ops/create'
require 'rio/ops/construct'
module RIO
  module Ops
    module Path
      module Empty
        include Ops::Path::Create
        include Ops::Path::URI
        include Ops::Construct
      end
      module ExistOrNot
        def symlink(d) 
          rtn_self { 
            dst = self.ensure_rio(d)
            dst /= self.filename if dst.directory?
            if self.abs?
              Impl::U.symlink(self,dst) 
            else
              #p "symlink(#{dst.route_to(self)},#{dst})"
              Impl::U.symlink(dst.route_to(self),dst.to_s) 
            end
            dst.reset
          } 
        end
      end
      module NonExisting
        include Test
        include Create
        include ExistOrNot
        # Rio does not consider an attempt to remove something that does not exist an error. 
        # Rio says "You called this method because you didn't want the thing to exist on the 
        # file system. After the call it doesn't exist. You're welcome"
        # 
        def delete!() softreset  end
        def delete() softreset  end
        def rmdir() softreset  end
        def rmtree() softreset  end
        def rm() softreset  end
        
      end
      module Str
        include Status
        include Query
        include Create        
        include URI
        include ExistOrNot
      end
    end
    
  end
end # FS
