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


module RIO
  module Ext
    module CSV
      module Filter
        module CSVMissing
          def set_cx(context)
            @cx = context
          end
          def cx() @cx end
          def _calc_csv_columns()
            require 'rio/arraynge'
            ycols = cx['col_args']
            ncols = cx['nocol_args']
            if ncols and ncols.empty?
              cx['csv_columns'] = []
            elsif ycols.nil? and ncols.nil?
              cx['csv_columns'] = nil
            else
              ncols = [] if ncols.nil?
              ycols = [(0..1000)] if ycols.nil? or ycols.empty?
              cx['csv_columns'] = Arraynge.ml_diff(ycols,ncols)
            end
          end
          def _trim(fields)
            _calc_csv_columns()
            return fields if cx['csv_columns'].nil?
            case fields
            when ::CSV::Row
              fields.fields(*cx['csv_columns'])
            else
              cx['csv_columns'].map{|idx| fields[idx]}.flatten
            end
          end
          def _trim_row(row)
            _calc_csv_columns()
            return row if cx['csv_columns'].nil?
            cols = _trim_col(row.size-1,cx['csv_columns'])
            case row
            when ::CSV::Row
              hdrs = cols.map{|idx| row.headers[idx]}.flatten
              flds = cols.empty? ? [] : row.fields(*cols)
              row.class.new(hdrs,flds,row.header_row?)
            else
              flds = cols.map{|idx| row[idx]}.flatten
              ::CSV::Row.new([],flds)
            end
          end
          def _trim_col(mx,cols)
            cols.map do |el|
              (el.is_a?(::Range) and el.max > mx) ? (el.min..mx) : el
            end
          end
          def each_line(*args,&block)
            self.each(*args) do |raw_rec|
              case cx['stream_itertype']
              when 'lines' 
                yield _trim(raw_rec).to_csv(*cx['csv_args'])
              when 'records'
                case raw_rec
                when ::Array then yield _trim(raw_rec)
                else yield _trim(raw_rec.fields)
                end
              when 'rows'
                yield _trim_row(raw_rec)
              else
                yield _trim(raw_rec)
              end
            end
          end
        end
      end
      module Output
        def add_csv_filter
          #p "add_csv_filter(#{self.ioh.ios})"
          csvio = ::CSV.new(self.ioh.ios,*cx['csv_args'])
          self.ioh.ios = csvio
        end
      end
      module Input
        def add_csv_filter
          #_calc_csv_columns()
          begin
            if cx['headers_args']
              cx['csv_args'][0] ||= {}
              cx['csv_args'][0][:headers] = cx['headers_args']
            else
              if cx['stream_itertype'] == 'rows'
                cx['csv_args'][0] ||= {}
                cx['csv_args'][0][:headers] = true
                #cx['csv_args'][0][:return_headers] = true
              end
            end
          end
          csvio = ::CSV.new(self.ioh.ios,*cx['csv_args'])
          csvio.extend Filter::CSVMissing
          csvio.set_cx(cx)
          self.ioh.ios = csvio
        end
      end
    end
  end
end

__END__
