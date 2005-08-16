#!/usr/bin/env ruby

require 'rio/kernel'
require 'test/unit'
require 'test/unit/testsuite'

class TC_RIO_nolines < Test::Unit::TestCase
  def tdir() rio(%w/qp nolines/) end
  def assert!(a,msg="negative assertion")
    assert((!(a)),msg)
  end
  require 'extensions/symbol'
  def smap(a) a.map( &:to_s ) end
  def mkafile(*args)
    file = rio(*args)
    file < (0..1).map { |i| "L#{i}:#{file.to_s}\n" }
    file
  end
  def mkalinesfile(n_lines,*args)
    file = rio(*args)
    file < (0...n_lines).map { |i| "L#{i}:#{file.to_s}\n" }
    file
  end
  def setup
    #$trace_states = true
    @cwd = ::Dir.getwd
    tdir.mkpath.chdir
  end
  def teardown
    ::Dir.chdir @cwd
  end

  def test_symbol
    rio('a').delete!.mkpath.chdir

    file,lines = file_lines()

    lines[1] = "\n"
    lines[6] = "\n"
    file < lines

    exp = lines[0..0] + lines[2..5] + lines[7...8]
    ans = file.chomp.nolines[:empty?]
    assert_equal(exp.map(&:chomp),ans)

    ans = file.nolines(:empty?).chomp.to_a
    assert_equal(exp.map(&:chomp),ans)

    file.close
    rio('..').chdir
  end
  def file_lines(n_lines=8)
    file = mkalinesfile(n_lines,'f1')
    lines = file[]
    (2..4).each do |n|
      lines[n] = '#' + lines[n]
    end
    (0..3).each do |n|
      lines[n].sub!(/f1/,'f2')
    end
    file < lines
    [file,lines]
  end
  def test_basic
    rio('a').delete!.mkpath.chdir
    file,lines = file_lines()
    exp = lines[1..1] + lines[5...8]

    # iterate over the first line and comment lines
    begin
      f0 = file.dup
      ans = f0.nolines[0,/^\s*#/]
      assert_equal(exp,ans)
    end

    begin
      f0 = file.dup
      ans = f0.nolines[proc { |rec,rnum,rio| rnum == 0 || rec =~ /^\s*#/ }]
      assert_equal(exp,ans)
    end
    begin
      f0 = file.dup
      
      #$trace_states = true
      exp0 = lines[0..1] + lines[5...8] 
      ans = f0.nolines[/^\s*#/]
      #p f0.cx
      #$trace_states = false
      assert_equal(exp0,ans)
    end
  end
  def test_proc
    file,lines = file_lines()
    #p lines
    exp1 = lines[4...8]
    ans = file.lines[proc { |rec,rnum,ario| rec =~ /#{ario.filename}/ }]
    assert_equal(exp1,ans)

    exp2 = lines[2..4]
    exp = exp1 - exp2
    ans = file.lines(proc { |rec,rnum,ario| rec =~ /#{ario.filename}/ }).nolines[/^\s*#/]
    assert_equal(exp,ans)

    ans = file.nolines(/^\s*#/).lines[proc { |rec,rnum,ario| rec =~ /#{ario.filename}/ }]
    assert_equal(exp,ans)
  end

  def test_ranges_ss
#    $trace_states = true
    lfile,lines = file_lines()

    ans = rio('f1').nolines(2..4).lines[0..2]
    exp = lines[6..6]

    ans = rio('f1').norecords(0).records(0..2).norecords(2..4).records[6]
    assert_equal(exp,ans)

    ans = rio('f1').lines(0..2).nolines(0,2..4).lines[6]
    assert_equal(exp,ans)
    ans = rio('f1').nolines(0,2..4).lines[0..2,6]

    assert_equal(lines[1..1]+lines[6..6],ans)


    ans = rio('f1').nolines(0).lines(0..2).nolines(2..4).lines[6]
    assert_equal(exp,ans)
    ans = rio('f1').nolines(0).lines(0..2).nolines(2..4).lines[6]
    assert_equal(exp,ans)
    ans = rio('f1').records(0..2).norecords(0,2..4).records[6]
    assert_equal(exp,ans)
    ans = rio('f1').norecords(0,2..4).records[0..2,6]
    assert_equal(lines[1..1]+lines[6..6],ans)

    exp = lines[1..1] + lines[5..7]
    ans = rio('f1').nolines(0,2..4).lines[0..2,6,/f1/]
    assert_equal(exp,ans)


    lfile.close
    rio('..').chdir
  end
  def iter_tests(file,exp)
    ans = file.clone.to_a
    assert_equal(exp,ans)


    ans = []
    file.clone.each { |rec| ans << rec }
    assert_equal(exp,ans)

    ans = []
    file.clone.each_record { |rec| ans << rec }
    assert_equal(exp,ans)

    ans = []
    f = file.clone
    while rec = f.getrec
      ans << rec
    end
    assert_equal(exp,ans)

    
  end
  def test_ranges
#    $trace_states = true
    lfile,lines = file_lines()

    file = lfile.dup.nolines(2..4).lines(0..2)
    exp = lines[0..1]
    #p "HEE"
#    breakpoint
    iter_tests(file,exp)

    file = lfile.dup.norecords(0).records(0..2).norecords(2..4).records(6)
    exp = lines[6..6]
    iter_tests(file,exp)

    file = lfile.dup.lines(0..2).nolines(0,2..4).lines(6)
    iter_tests(file,exp)

    file = lfile.dup.nolines(0,2..4).lines(0..2,6)
    iter_tests(file,lines[1..1]+lines[6..6])

    file = lfile.dup.nolines(0).lines(0..2).nolines(2..4).lines(6)
    iter_tests(file,exp)

    file = lfile.dup.records(0..2).norecords(0,2..4).records(6)
    iter_tests(file,exp)

    file = lfile.dup.norecords(0,2..4).records(0..2,6)
    iter_tests(file,lines[1..1]+lines[6..6])

    exp = lines[1..1] + lines[5..7]
    file = lfile.dup.nolines(0,2..4).lines(0..2,6,/f1/)
    iter_tests(file,exp)


    lfile.close
    rio('..').chdir
  end
end