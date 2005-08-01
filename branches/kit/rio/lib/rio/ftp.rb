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


require 'net/ftp'
require 'rio/state'
require 'rio/ops/path'
require 'rio/ftp/ioh'
require 'rio/grande'
require 'rio/cp'

module RIO

  module FTP #:nodoc: all
    module State
      class Base < RIO::State::Base
        include Ops::Path::URI
        include Ops::Path::Query
        include Ops::Path::Create
        def closed?() ioh.nil? || ioh.closed? end
        def open?() not closed? end
      end
      class Reset < Base
        def check?() true end
        def when_missing(sym,*args)  
          become('FTP::State::Open')
        end
      end
      class Open < Base
        def check?() true end
        def open_(*args)
          unless open?
            ios = self.rl.open(*args)
            self.ioh = FTP::IOH.new(ios)
            #self.ioh = self.rl.open(*args)
          end
          self
        end
        def open(*args)
          open_(*args)
        end
        def es()
          begin
            ioh.chdir(rl.path)
            become('FTP::State::Dir')
          rescue ::Net::FTPPermError
            ioh.chdir(dirname.path.to_s)
            become('FTP::State::File')
          end
        end
        def when_missing(sym,*args)
          open_.es()
        end

      end
      class Common < Base
        def pwd() ioh.pwd end
        def cwd()
          nr = self.dup
          nr.rl.path = ioh.pwd
          new_rio(nr) 
        end
        def help(*args) ioh.help(*args) end
        def status() ioh.status(self.path.to_s) end
        def system(*args) ioh.system(*args) end
        def quit() 
          ioh.quit unless closed?
          self
        end

        def softreset()
          close unless closed?
          super
        end
        def close() 
          ioh.close unless closed?
          softreset
        end 
      end
      class File < Common
        #include Cp::File::Input
        def check?() true end
        def when_missing(sym,*args)  
          fstream()
        end
        def fstream()
          self.rl = RIO::FTP::Stream::RL.new(rl.uri)
          @ioh = nil
          become('FTP::Stream::Open')
        end
        def mkdir()
          #ioh.chdir(dirname.path.to_s) {
          ioh.mkdir(self.path.to_s)
          softreset
        end
        def put(src)
          #p callstr('put',src)
          ioh.chdir(dirname.path.to_s)
          ioh.put(src.to_s,filename.to_s)
          self
        end
        def cpto_err(sym,*args)
          cs = "#{sym}("+args.map(&:to_s).join(',')+")"
          msg = "Go Figure! rio('#{self.to_s}').#{cs} Failed"

          raise ArgumentError,"#{msg}\nArgument to '#{sym}' must be a Rio was a '#{args[0].class}'\n"
        end
        def <(src)
          cpto_err(:<,src) unless src.kind_of?(Rio)
          put(src)
        end
        def <<(src)
          cpto_err(:<<,src) unless src.kind_of?(Rio)
          put(src)
        end
        def mdtm() ioh.mdtm(rl.path) end
        def rename(dst) 
          ioh.rename(rl.path,dst.to_s)
          softreset
        end
        def delete()
          ioh.delete(rl.path) if exist?
          softreset
        end
        def exist?()
          begin
            mdtm()
          rescue ::Net::FTPPermError
            return false
          end
          true
        end
        def file?() exist? end
        def dir?() false end
      end
      class Dir < Common
        include Enumerable
        include Grande
        include Grande::Dir
        include Cp::Dir::Input
        include Cp::Dir::Output
        def check?() true end
        def when_missing(sym,*args)  
          gofigure(sym,*args)
        end
        def mkdir()
          self
        end
        def rmdir() 
#          ioh.chdir(dirname.to_s)
#          ioh.rmdir(filename.to_s)
          ioh.rmdir(rl.path)
          softreset
        end
        def getents(ents=[])
          each do |el|
            el.getents(ents) if el.dir?
            ents << el
          end
          ents
        end

        def rmtree()
          ents = getents()
          ents.each do |ent|
            ent.delete
          end
          self.delete
        end
        alias :delete :rmdir
        def nlst() ioh.nlst() end
        def chdir(*args,&block)
          if block_given?
            wd = ioh.pwd
            ioh.chdir(rl.path)
            rtn = yield
            ioh.chdir(wd)
            rtn
          else
            ioh.chdir(rl.path)
          end
          self
        end
        def list()
          ioh.list
        end
        def exist?() true end
        def dir?() true end
        def file?() false end
        def put(srio)
          ioh.chdir(rl.path)
          ioh.put(srio.to_s,srio.filename.to_s)
          self
        end
        def each(&block)
          ioh.chdir(rl.path)
          each_(&block)
          self
        end
      end
    end
  end
end
module RIO
  module FTP
    module Stream

      require 'rio/stream/open'
      require 'rio/ops/path'
      class Open < RIO::Stream::Open
        include Ops::Path::Status
        include Ops::Path::URI
        include Ops::Path::Query
        def input() 
          self.rl.base = self.ioh.base_uri
          stream_state('FTP::Stream::Input') 
        end
        def base_state() 'FTP::Stream::Close' end
      end
      class Close < RIO::Stream::Close
        def base_state() 'FTP::Stream::Reset' end
      end
      require 'rio/stream'
      class Reset < RIO::Stream::Reset
        def when_missing(sym,*args)
          self.rl = FTP::RL.new(rl.uri)
          super
        end
      end
      require 'rio/stream'
      class Input < RIO::Stream::Input
        include Ops::Path::Status
        include Ops::Path::URI
        include Ops::Path::Query
        def base_state() 'FTP::Stream::Close' end
        extend Forwardable
        def_instance_delegators(:ioh,:meta,:status,:charset,:content_encoding,:content_type,:last_modified,:base_uri)
      end

    end
  end 
end # module RIO
