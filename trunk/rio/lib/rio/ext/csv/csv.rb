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

class StringIO
  def to_io() self end
end
$EXTEND_CSV_RESULTS = false
module RIO
  module Ext
    module CSV
      module Cx
        def csv(*args,&block) 
          cx['csv_args'] = args
          cxx('csv',true,&block) 
        end
        def csv?() cxx?('csv') end 
        def csv_(*args) 
          cx['csv_args'] = args
          cxx_('csv',true) 
        end
        protected :csv_
        def headers(*args,&block) 
          if args.empty?
            cx['headers_args'] = true
          else
            cx['headers_args'] = args[0]
          end
          cxx('csv',true,&block) 
        end
        def columns(*ranges,&block)
          if skipping?
            cx['skipping'] = false
            skipcolumns(*args,&block)
          else
            @cnames = nil
            cx['col_args'] = ranges.flatten
            cxx('columns',true,&block)
          end
        end
        def skipcolumns(*ranges,&block)
          @cnames = nil
          cx['nocol_args'] = ranges.flatten
          cxx('columns',true,&block)
        end
        def columns?() 
          cxx?('columns') 
        end 
        def fields(*ranges,&block)
          if skipping?
            cx['skipping'] = false
            skipfields(*args,&block)
          else
            @cnames = nil
            cx['field_args'] = ranges.flatten
            cxx('fields',true,&block)
          end
        end
        def skipfields(*ranges,&block)
          @cnames = nil
          cx['nofield_args'] = ranges.flatten
          cxx('fields',true,&block)
        end
        def fields?() 
          cxx?('fields') 
        end 
      end
    end
  end
end
module RIO
  module Ext
    module CSV
      module Ary
        attr_accessor :csv_rec_to_s
        def to_s()
          @csv_rec_to_s.call(self)
        end
      end
      module Str
        attr_accessor :csv_s_to_rec
        def to_a()
          @csv_s_to_rec.call(self)
        end
      end
    end
  end
end


module RIO
  module Ext
    module CSV
      module Input

        def contents()                  
          _post_eof_close { 
            self.to_io.read || "" 
          }         
        end

        protected

        def get_(sep_string=get_arg_)
          #p callstr('get_',sep_string.inspect)
          self.ior.gets
        end
        def cpto_string_(arg)
          #p "CSV: cpto_string_(#{arg}) itertype=#{cx['stream_itertype']}"
          if cx['stream_itertype'].nil?
            get_type('lines') { super }
          else
            super
          end
        end
        def cpto_rio_(arg,sym)
          #p callstr('csv:cpto_rio_',arg.inspect)
          ario = ensure_rio(arg)
          ario = ario.join(self.filename) if ario.dir?
          ario.cpclose {
            ario = ario.iostate(sym)
            self.copying(ario).each { |el|
              case el
              when ::Array
                ario.putrec(el)
              else
                ario.putrec(el.parse_csv(*ario.cx['csv_args']))
              end
              #p el
              #ario << el
              #ario.putrec(el)
            }.copying_done(ario)
            ario
          }
        end

        def to_rec_(raw_rec)
          if ::CSV::Row === raw_rec
            #p 'OKOKOKOK'
            unless cx['field_args'].nil?
              cx['csv_columns'] ||= []
              #p raw_rec
              cx['csv_columns'] += fields_to_columns(raw_rec.headers,cx['field_args'])
              cx['field_args'] = nil
            end
          end
          raw_rec
#           case cx['stream_itertype']
#           when 'lines' 
#             _trim(raw_rec).to_csv(*cx['csv_args'])
#           when 'records'
#             case raw_rec
#             when ::Array then _trim(raw_rec)
#             else _trim(raw_rec.fields)
#             end
#           when 'rows'
#             _trim_row(raw_rec)
#           else
#             _trim(raw_rec)
#           end
        end

        private
#         def _trim_row(row)
#           return row if cx['csv_columns'].nil?
#           return case row
#                  when ::CSV::Row
#                    #p "HERE: headers: #{row.headers.inspect} row: #{row.inspect}"
#                    hdrs = cx['csv_columns'].map{|idx| row.headers[idx]}.flatten
#                    flds = row.fields(*cx['csv_columns'])
#                    row.class.new(hdrs,flds,row.header_row?)
#                  else
#                    #p 'THERE'
#                    flds = cx['csv_columns'].map{|idx| row[idx]}.flatten
#                    ::CSV::Row.new([],flds)
#                  end
#         end
#         def _trim(fields)
#           #p "_trim(#{fields.inspect})"
#           #p cx['csv_columns']
#           return fields if cx['csv_columns'].nil?
#           return case fields
#                  when ::CSV::Row
#                    fields.fields(*cx['csv_columns'])
#                  else
#                    cx['csv_columns'].map{|idx| fields[idx]}.flatten
#                  end
#         end
#         #         def to_rec_(raw_rec)
#         #           return raw_rec
#         #_init_cols_from_line(raw_rec) if @recno == 0
#         #p "#{callstr('to_rec_',raw_rec.inspect,@recno)} ; itertype=#{cx['stream_itertype']}"
#         #           case cx['stream_itertype']
#         #           when 'lines' 
#         #             raw_rec
#         #           when 'records'
#         #             _l2record(raw_rec)
#         #           when 'rows'
#         #             _l2row(raw_rec)
#         #           else
#         #             _l2record(raw_rec)
#         #           end
#         #         end

        def fields_to_columns(row,flds)
          cols = []
          flds.each do |fld|
            case fld
            when Range
              ibeg = fld.begin.is_a?(Integer) ? fld.begin : row.index(fld.begin)
              iend = fld.end.is_a?(Integer) ? fld.end : row.index(fld.end)
              rng = fld.exclude_end? ? (ibeg...iend) : (ibeg..iend)
              cols << rng
            when Integer
              cols << fld
            else
              cols << row.index(fld)
            end
          end
          cols.flatten
        end
        private
        def _rec_to_s_proc(*csv_args)
          proc { |a|
            ::CSV.generate_line(a,*csv_args) 
          }
        end

        def _s_to_rec_proc(*csv_args)
          proc { |s|
            ::CSV.parse_line(s,*csv_args) 
          }
        end

        def _init_cols_from_line(line)
          ary = _l2record(line)
          _init_cols_from_ary(ary)
        end

        def _init_cols_from_num(num)
          fake_rec = (0...num).map { |n| "Column#{num}" }
          _init_cols_from_ary(fake_rec)
        end
        def _init_cols_from_hash(hash)
          _init_cols_from_ary(hash.keys)
        end
        def _init_cols_from_ary(ary)
          #p callstr('_init_cols_from_ary',ary)
          if columns?
            cx['col_names'] = []
            cx['col_nums'] = []

            ary.each_with_index do |cname,idx|
              cx['col_args'].each do |arg|
                if arg === ( arg.kind_of?(::Regexp) || arg.kind_of?(::String) ? cname : idx )
                  cx['col_names'] << cname
                  cx['col_nums'] << idx
                end
              end
            end
          else
            cx['col_names'] = ary
          end
          cx.values_at('col_nums','col_names')
        end

      end
    end

    module CSV
      module Output

        public

        def putrow(*argv)
          row = ( argv.length == 1 && argv[0].kind_of?(::Array) ? argv[0] : argv )
          self.puts(::CSV.generate_line(row,*cx['csv_args']))
        end
        def putrow!(*argv)
          putrow(*argv)
          close
        end

        def putrec(rec,*args)
          #p callstr('csv:putrec',rec.inspect,args.inspect)
          case rec
          when ::Array
            self.puts(rec)
          else
            self.puts(rec.parse_csv)
          end
          self
        end
        protected

        def cpfrom_(arg)
          #p callstr('cpfrom_',arg.inspect)
          case arg
          when ::String
            ::CSV.parse(arg,*cx['csv_args']) {|el| puts(el) }
          else 
            super
          end
          self
        end

        def cpfrom_rio_(arg)
          #p callstr('csv:cpfrom_rio_',arg.inspect)
          
          ario = ensure_rio(arg)
          ario.copying(self).each { |el|
            case el
            when ::Array
              self.puts(el)
            else
              self.puts(el.parse_csv(*cx['csv_args']))
            end
          }.copying_done(self)
        end

        def put_(arg)
          #p callstr('put_',arg.inspect)
          puts(arg)
        end

        def cpfrom_array_(ary)
          #p callstr('copy_from_array',ary.inspect)
          if ary.empty?
            super
          else
            case ary[0]
            when ::Array, ::CSV::Row
              #p callstr('copy_from_array_of_array_or_rows',ary.inspect)
              ary.each do |el|
                puts(el)
              end
            else
              #p callstr('copy_from_array_of_objs',ary.inspect)
              ary.each do |el|
                puts(el.parse_csv(*cx['csv_args']))
              end
            end
          end
        end

        private

        def _to_header_line(arg,*csv_args)
          case arg
          when ::String
            arg
          when ::Array
            _ary_to_line(arg,*csv_args)
          when ::Hash
            _ary_to_line(arg.keys,*csv_args)
          else
            arg.to_s
          end
        end

        def _to_line(arg,*csv_args)
          p callstr('_to_line',arg.inspect,csv_args)
          case arg
          when ::Array
            _ary_to_line(arg,*csv_args)
          when ::Hash
            _ary_to_line(arg.values,*csv_args)
          else
            arg
          end
        end
        def _csv_options(*args)
        end
        def _ary_to_line(ary,*csv_args)
          rs ||= $/
          _csv_options(csv_args)
          #h = {:col_sep => fs, :row_sep => rs}
          #p 'HERE',csv_args
          ::CSV.generate_line(ary,*csv_args)
        end
        public
      end
    end
  end
end
__END__
