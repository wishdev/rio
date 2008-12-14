#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'
require 'tc/csvutil'

class TC_csv2 < Test::RIO::TestCase
  include CSV_Util

  @@once = false
  def self.once
    @@once = true
  end
  def setup()
    super
    @src = rio(?")
    @dst_name = 'dst.csv'
    @records,@strings,@lines,@string = create_test_csv_data(@src,3, 3, ',', $/, true)
    if $USE_FASTER_CSV
      opts = {:headers => true, :return_headers => true}
      @rows = []
      ::CSV.parse(@string, opts) do |row|
        @rows << row
      end
    else
      @rows = []
      @records.each do |rec|
        h = {}
        (0...rec.size).each do |n|
          h["Col#{n}"] = rec[n]
        end
        @rows << h
      end
    end
      
  end

  def test_rows
    rio('src1.csv') < @src

    rio('src1.csv') > rio('dst.csv')
    first_row = ($USE_FASTER_CSV ? 1 : 0)
    assert_equal(@rows[first_row,@rows.size-first_row],rio('dst.csv').csv.rows[])
    ans = []
    rio('dst.csv').csv.rows do |row|
      ans << row
    end
    assert_equal(@rows[first_row,@rows.size-first_row],ans)
  end
  def test_read
    rio('src1.csv') < @src


    rio('src1.csv') > rio('dst.csv')
    assert_equal(@string,rio('dst.csv').contents)
    assert_equal(@string,rio('dst.csv').csv.contents)
    assert_equal(@lines,rio('dst.csv')[])
    assert_equal(@strings,rio('dst.csv').chomp[])
    assert_equal(@lines,rio('dst.csv').to_a)
    assert_equal(@strings,rio('dst.csv').chomp.to_a)
    assert_equal(@lines,rio('dst.csv').readlines)
    assert_equal(@strings,rio('dst.csv').chomp.readlines)

    assert_equal(@records,rio('dst.csv').csv[])
    assert_equal(@lines,rio('dst.csv').csv.lines[])
    assert_equal(@strings,rio('dst.csv').csv.chomp.lines[])
    assert_equal(@records,rio('dst.csv').csv.records[])
    exp  = ($USE_FASTER_CSV ? @records : @lines)
    assert_equal(exp,rio('dst.csv').csv.records.readlines)
    assert_equal(@lines[1..2],rio('dst.csv').csv.lines[1..2])
    assert_equal(@lines[1..2],rio('dst.csv').csv.lines(1..2).to_a)
    exp  = ($USE_FASTER_CSV ? @records : @lines)
    assert_equal(exp,rio('dst.csv').csv.lines(1..2).readlines)

  end
  def test_getrec

    rio('src1.csv') < @src

    assert_equal(@string,rio('src1.csv').contents)
    assert_equal(@string,rio('src1.csv').csv.contents)
    assert_equal(@lines[0],rio('src1.csv').getrec)
    assert_equal(@strings[0],rio('src1.csv').chomp.getrec)

    assert_equal(@lines[1],rio('src1.csv').lines(1).getrec)
    assert_equal(@lines[1],rio('src1.csv').records(1).getrec)
    assert_equal(@lines[1],rio('src1.csv').rows(1).getrec)

    assert_equal(@records[1],rio('src1.csv').csv.lines(1).getrec)
    assert_equal(@records[1],rio('src1.csv').csv.records(1).getrec)

    assert_equal(@records[8000],rio('src1.csv').csv.records(8000).getrec)

    assert_equal(@string[0,23],rio('src1.csv').bytes(23).getrec)

    rec_ary = @records[0]
    rec_rio = rio('src1.csv').csv.getrec
    assert_kind_of(::Array,rec_rio)
    exp = $EXTEND_CSV_RESULTS ? @strings[0] : @records[0].to_s
    assert_equal(exp,rec_rio.to_s)

    rec_rio = rio('src1.csv').csv.lines.getrec
    assert_kind_of(::Array,rec_rio)
    assert_equal(@records[0],rec_rio.to_a)

    ary = rio('src1.csv').csv[]
    assert_kind_of(::Array,ary[0])
    exp = $EXTEND_CSV_RESULTS ? @strings[0] : @records[0].join
    assert_equal(exp,ary[0].join)

    recs = rio('src1.csv').csv.lines[]
    assert_kind_of(::String,recs[0])
    exp = $EXTEND_CSV_RESULTS ? @records[0] : @strings[0]+$/
    assert_equal(exp,recs[0])
    return
  end


end
