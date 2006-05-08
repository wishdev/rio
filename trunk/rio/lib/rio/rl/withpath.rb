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


require 'rio/rl/uri'
require 'rio/rl/pathmethods'

module RIO
  module RL
    class WithPath < Base
#       def self.get_opts_from_args_(args)
#         base = nil
#         fs = nil
#         if !args.empty? and args[-1].kind_of?(::Hash) 
#           opts = args.pop
#           if b = opts[:base]
#             base = case b
#                    when URIBase then  b.uri if b.uri.absolute?
#                    when ::URI then b if b.absolute?
#                    when %r%^file://(#{HOST})?(/.*)?$% then b
#                    when %r%^/% then b
#                    when /^#{SCHEME}:/ then ::URI.parse(b)
#                    else RL.fs2url(::Dir.getwd)+'/'+b
#                    end
#           end
#           fs = opts[:fs]
#         end
#         [base,fs,args]
#       end

#       def self.build(sch,*args)
#         base,fs,args = get_opts_from_args_(args)
#         if base and base.kind_of?(::URI)
#           case sch
#           when 'file','path'
#             if ['http' 'ftp'].include?(sch)
              
#             end
#           end
#       end
    end
  end
end

