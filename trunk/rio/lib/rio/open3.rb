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
# = open3.rb
#
# = Rio
#
# Copyright (c) 2005, Christopher Kleckner
#
#


require 'rio'
require 'open3'

module RIO
  def popen3(*args,&block)
    if block_given?
      i,o,e = nil,nil,nil
      begin
        Open3.popen3(*args) do |si,so,se|
          yield(i=Rio.new(si),o=Rio.new(so),e=Rio.new(se))
        end
      ensure
        [i,o,e].each { |el| el.reset if el }
      end
    else
      si,so,se = Open3.popen3(*args)
      [Rio.new(si),Rio.new(so),Rio.new(se)]
    end
  end
  module_function :popen3
end
__END__
