#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'
require 'tc/csvutil'

class TC_yaml < Test::RIO::TestCase
  include CSV_Util

  @@once = false
  TRIO = rio('test.yaml')
  TOBJS = [
    ['zero','one','two'],
    {'zero' => 0, 'one' => 1, 'two' => 2},
    "the crux of the biscuit",
  ]
  def self.once
    @@once = true
    tdir.delete!.mkpath.chdir {
      TRIO.puts!(YAML.dump_stream(*TOBJS))
    }
  end
  def setup()
    self.class.once unless @@once
    super
  end

  def test_ss
    0.upto(2) do |n|
      exp = [TOBJS[n]]
      ans = rio(TRIO).yaml[n]
      assert_equal(exp,ans)
      ans = rio(TRIO).yaml[TOBJS[n].class]
      assert_equal(exp,ans)
    end
  end
  def test_copyop
    objs = rio(TRIO).yaml[]
    assert_equal(TOBJS,objs)
    ofile = 'out.yml'
    yout = rio(ofile).yaml.delete << objs[0] << objs[1] << objs[2]
    assert_equal(rio(TRIO)[],rio(ofile)[])
    rio(?",ostring = "").yaml < yout
    assert_equal(rio(TRIO).contents,ostring)
  end
  def test_copytypes
    ofile = 'out.yml'
    [1,"1",{'one'=>1},[1]].each do |obj|
      rio(ofile).yaml < obj
      assert_equal(obj,rio(ofile).yaml.load)
    end
  end
  def test_copytoary
    ofile = 'out.yml'
    in_ary = [1,"1",{'one'=>1},[1]]
    ary = []
    in_ary.each do |obj|
      rio(ofile).yaml < obj
      assert_equal(obj,rio(ofile).yaml.load)
      rio(ofile).yaml >> ary
    end
    assert_equal(in_ary,ary)
  end
  def test_get
    exp = TOBJS[0]

    obj = rio(TRIO).yaml.get
    assert_instance_of(exp.class,obj)
    assert_equal(exp,obj)

    obj = rio(TRIO).yaml.records.get
    assert_instance_of(exp.class,obj)
    assert_equal(exp,obj)

    obj = rio(TRIO).yaml.lines.get
    assert_instance_of(::String,obj)
    assert_equal(rio(TRIO).lines[0],[obj])

    exp = ::YAML.dump(exp)
    obj = rio(TRIO).yaml.rows.get
    assert_instance_of(::String,obj)
    assert_equal(exp,obj)

  end
  def test_each
    exp = TOBJS

    ans = []
    rio(TRIO).yaml do |obj|
      ans << obj
    end
    (0...exp.size).each do |i|
      assert_equal(exp[i],ans[i])
    end

    ans = []
    rio(TRIO).yaml.records do |obj|
      ans << obj
    end
    (0...exp.size).each do |i|
      assert_equal(exp[i],ans[i])
    end

    ans = []
    rio(TRIO).yaml.rows do |obj|
      ans << ::YAML.load(obj)
    end
    (0...exp.size).each do |i|
      assert_equal(exp[i],ans[i])
    end

    exp = rio(TRIO).lines[]
    ans = []
    rio(TRIO).yaml.lines do |obj|
      ans << obj
    end
    (0...exp.size).each do |i|
      assert_equal(exp[i],ans[i])
    end

  end
  def test_array
    exp = TOBJS

    ans = rio(TRIO).yaml[]
    assert_equal(exp,ans)

    ans = rio(TRIO).yaml.records[]
    assert_equal(exp,ans)

    ans = rio(TRIO).yaml.rows[]
    assert_equal(exp,ans.map{|obj| ::YAML.load(obj)})

    exp = rio(TRIO).lines[]
    ans = rio(TRIO).yaml.lines[]
    assert_equal(exp,ans)

  end
  def test_getrec
    exp = TOBJS[0]

    obj = rio(TRIO).yaml.getrec
    assert_instance_of(::Array,obj)
    assert_equal(exp,obj)

    obj = rio(TRIO).yaml.lines.getrec
    assert_instance_of(::Array,obj)
    assert_equal(exp,obj)

    obj = rio(TRIO).yaml.records.getrec
    assert_instance_of(::Array,obj)
    assert_equal(exp,obj)

    obj = rio(TRIO).yaml.rows.getrec
    assert_instance_of(::Array,obj)
    assert_equal(exp,obj)

  end
  def test_getrow
    exp = TOBJS[0].to_yaml

    obj = rio(TRIO).yaml.getrow
    assert_instance_of(::String,obj)
    assert_equal(exp,obj)

    obj = rio(TRIO).yaml.lines.getrow
    assert_instance_of(::String,obj)
    assert_equal(exp,obj)

    obj = rio(TRIO).yaml.records.getrow
    assert_instance_of(::String,obj)
    assert_equal(exp,obj)

    obj = rio(TRIO).yaml.rows.getrow
    assert_instance_of(::String,obj)
    assert_equal(exp,obj)

  end
  def test_getline
    exp = rio(TRIO).gets

    obj = rio(TRIO).yaml.getline
    assert_instance_of(::String,obj)
    assert_equal(exp,obj)

    obj = rio(TRIO).yaml.lines.getline
    assert_instance_of(::String,obj)
    assert_equal(exp,obj)

    obj = rio(TRIO).yaml.records.getline
    assert_instance_of(::String,obj)
    assert_equal(exp,obj)

    obj = rio(TRIO).yaml.rows.getline
    assert_instance_of(::String,obj)
    assert_equal(exp,obj)

  end


end
