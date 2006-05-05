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


#
# = uri/file.rb
#
# Author:: Akira Yamada <kit_kleckner@yahoo.com>
# License:: You can redistribute it and/or modify it under the same term as Ruby.
#

require 'uri/generic'

module URI #:nodoc: all
  

  #
  # RFC1738 section 3.10.
  #
=begin
RFC 1738            Uniform Resource Locators (URL)        December 1994

3.10 FILES

   The file URL scheme is used to designate files accessible on a
   particular host computer. This scheme, unlike most other URL schemes,
   does not designate a resource that is universally accessible over the
   Internet.

   A file URL takes the form:

       file://<host>/<path>

   where <host> is the fully qualified domain name of the system on
   which the <path> is accessible, and <path> is a hierarchical
   directory path of the form <directory>/<directory>/.../<name>.

   For example, a VMS file

     DISK$USER:[MY.NOTES]NOTE123456.TXT

   might become

     <URL:file://vms.host.edu/disk$user/my/notes/note12345.txt>

   As a special case, <host> can be the string "localhost" or the empty
   string; this is interpreted as `the machine from which the URL is
   being interpreted'.

   The file URL scheme is unusual in that it does not specify an
   Internet protocol or access method for such files; as such, its
   utility in network protocols between hosts is limited.
=end

  module REGEXP
    EMPTYHOST = Regexp.new("^$", false, 'N').freeze #"
  end # module REGEXP

  class FILE < Generic

    COMPONENT = [
      :scheme, 
      :host,
      :path, 
    ].freeze 

    def check_host(v)
      return true if v && EMPTYHOST =~ v
      super
    end
    private :check_host

    def normalize!
      super
      if host && host == 'localhost'
        set_host('')
      end
    end

    def file(*args)
      pth = self.path(*args)
      pth.chop! if pth[-1,1] == '/' && pth != '/'
      return pth
    end

    #
    # == Description
    #
    # Create a new URI::FILE object from components of URI::FILE with
    # check.  It is scheme, userinfo, host, port, path, query and
    # fragment. It provided by an Array of a Hash.
    #
    def self.build(args)
      #p "In build: "+args.inspect
      tmp = Util::make_components_hash(self, args)
      return super(tmp)
    end

    #
    # == Description
    #
    # Create a new URI::FILE object from ``generic'' components with no
    # check.
    #
    def initialize(*arg)
      super(*arg)
      self.host = '' if self.host.nil?
    end
  end

  @@schemes['FILE'] = FILE
end
