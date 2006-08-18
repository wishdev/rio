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
# from the distribution directory.
#
# Suggested Reading
# * RIO::Doc::SYNOPSIS
# * RIO::Doc::INTRO
# * RIO::Doc::HOWTO
# * RIO::Doc::EXAMPLES
# * RIO::Rio
#


# module RIO
#   module Impl #:nodoc: all
#     module U
#       def self.fnmatch?(s,globstr,*flags) ::File.fnmatch?(globstr,s,*flags) end
#       def self.expand_path(s,*args) ::File.expand_path(s,*args) end
#       def self.extname(s,*args) ::File.extname(s,*args) end

#       def self.basename(s,*args) ::File.basename(s,*args) end
#       def self.dirname(s,*args) ::File.dirname(s,*args) end

#       def self.ftype(s,*args) ::File.ftype(s,*args) end
#       def self.symlink(s,d) ::File.symlink(s.to_s,d.to_s) end

#       def self.stat(s,*args) ::File.stat(s,*args) end

#       def self.atime(s,*args) ::File.atime(s,*args) end
#       def self.ctime(s,*args) ::File.ctime(s,*args) end
#       def self.mtime(s,*args) ::File.mtime(s,*args) end

#       def self.blockdev?(s,*args) ::FileTest.blockdev?(s,*args) end
#       def self.chardev?(s,*args) ::FileTest.chardev?(s,*args) end
#       def self.directory?(s,*args) ::FileTest.directory?(s,*args) end
#       def self.dir?(s,*args) ::FileTest.directory?(s,*args) end
#       def self.executable?(s,*args) ::FileTest.executable?(s,*args) end
#       def self.executable_real?(s,*args) ::FileTest.executable_real?(s,*args) end
#       def self.exist?(s,*args) ::FileTest.exist?(s,*args) end
#       def self.file?(s,*args) ::FileTest.file?(s,*args) end
#       def self.grpowned?(s,*args) ::FileTest.grpowned?(s,*args) end
#       def self.owned?(s,*args) ::FileTest.owned?(s,*args) end
#       def self.pipe?(s,*args) ::FileTest.pipe?(s,*args) end
#       def self.readable?(s,*args) ::FileTest.readable?(s,*args) end
#       def self.readable_real?(s,*args) ::FileTest.readable_real?(s,*args) end
#       def self.setgid?(s,*args) ::FileTest.setgid?(s,*args) end
#       def self.setuid?(s,*args) ::FileTest.setuid?(s,*args) end
#       def self.size(s,*args) ::FileTest.size(s,*args) end
#       def self.size?(s,*args) ::FileTest.size?(s,*args) end
#       def self.socket?(s,*args) ::FileTest.socket?(s,*args) end
#       def self.sticky?(s,*args) ::FileTest.sticky?(s,*args) end
#       def self.symlink?(s,*args) ::FileTest.symlink?(s,*args) end
#       def self.writable?(s,*args) ::FileTest.writable?(s,*args) end
#       def self.writable_real?(s,*args) ::FileTest.writable_real?(s,*args) end
#       def self.zero?(s,*args) ::FileTest.zero?(s,*args) end
#       require 'pathname'
#       def self.root?(s) ::Pathname.new(s).root? end
#       def self.mountpoint?(s) ::Pathname.new(s).mountpoint? end
#       def self.realpath(s) ::Pathname.new(s).realpath end
#       def self.cleanpath(s,*args) ::Pathname.new(s).cleanpath(*args) end
#     end
#   end
# end
