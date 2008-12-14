#--
# =============================================================================== 
# Copyright (c) 2005,2006,2007,2008 Christopher Kleckner
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


# begin
#   require 'faster_csv'  # first choice--for speed

#   # A CSV compatible interface for FasterCSV.
#   module CSV  # :nodoc:
#     def self.parse_line( line, field_sep=nil, row_sep=nil )
#       FasterCSV.parse_line( line, :col_sep => field_sep || ",",
#                                   :row_sep => row_sep   || :auto )
#     end
    
#     def self.generate_line( array, field_sep=nil, row_sep=nil )
#       FasterCSV.generate_line( array, :col_sep => field_sep || ",",
#                                       :row_sep => row_sep   || "" )
#     end
#   end
# rescue LoadError
#   require 'csv'         # second choice--slower but standard
# end

$USE_FASTER_CSV = false
if RUBY_VERSION[0,3] >= '1.9'
  require 'csv'
  require 'rio/ext/csv/csv'
  $USE_FASTER_CSV = true
  p 'FASTER CSV 1.9'
else
  begin 
    CSV.const_defined?('Reader')
    require 'rio/ext/csv/csv-legacy'
    p 'LEGACY CSV'
  rescue NameError
    begin
      require 'faster_csv'
      class CSV < ::FasterCSV
      end
      require 'rio/ext/csv/csv'
      $USE_FASTER_CSV = true
      p 'FASTER CSV'
    rescue LoadError
      require 'csv'
      require 'rio/ext/csv/csv-legacy'
      p 'LEGACY CSV'
    end
  end
end

__END__
