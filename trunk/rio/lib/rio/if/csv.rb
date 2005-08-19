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


module RIO
  class Rio
    #def file() target.file end
    #def dir() target.dir end
    
    # Puts a Rio in CSV mode and sets the field and record separators.
    # In csv mode selecting with Rio#records will cause each line
    # read to be parsed into a line with the CSV standard library.
    # Specifying using Rio#lines to select will return unparsed strings
    # as normal.
    #
    #  # copy a csv file, changing the field separator
    #  rio('afile.csv').csv > rio('afile_semicolons.csv').csv(';')
    #
    # CSV mode also adds two methods Rio#columns and Rio#nocolumns which 
    # allows selecting columns by column index using Fixnums or Ranges
    # in a way similar to how lines are selected.
    #
    #  # iterate through every line but only get the first three columns
    #  rio("afile.csv").csv.columns(0..2) { |array_of_fields| ... }
    #
    #  # iterate through every line but skip the columns 2 and 3 through 5
    #  rio("afile.csv").csv.nocolumns(2,3..5) { |array_of_fields| ... }
    #
    #  # an array containg all but the first line returning columns 5,6 and 7
    #  rio("afile.csv").csv.columns(5..7).nolines[0]
    #
    # See RIO::Doc::INTRO for complete documentation on csv mode.
    def csv(field_separator=',',record_separator=nil,&block) 
      target.csv(field_separator,record_separator,&block); 
      self 
    end
    # Select columns from a CSV file. See Rio#csv and RIO::Doc::INTRO.
    def columns(*ranges,&block) target.columns(*ranges,&block); self end
    # Reject columns from a CSV file. See Rio#csv and RIO::Doc::INTRO.
    def nocolumns(*ranges,&block) target.nocolumns(*ranges,&block); self end
  end
end

