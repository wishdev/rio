#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'test/unit'
require 'test/unit/testsuite'

class TC_RIO_expand_path < Test::Unit::TestCase
  def initialize(*args)
    super
    @once = false
    @tdir = rio('qp/expand_path')
  end
  def assert!(a,msg="negative assertion")
    assert((!(a)),msg)
  end
  def smap(a) a.map{|el| el.to_s} end
  def setup
    s_dir = ''
    #$trace_states = true
    unless @once
      @once =  true
      @tdir.rmtree.mkpath
    end
  end

  def test_expand_path_from_cwd
    require 'tmpdir'
    tmp = rio('/tmp')
    unless tmp.dir?
      tmp = rio(RIO::RL.fs2url(::Dir.tmpdir))
    end
    tmp.chdir do
      rel = rio('groovy')
      exp = rio(tmp,rel)
      ans = rel.expand_path
      assert_kind_of(RIO::Rio,ans)
      assert_equal(exp,ans)
    end
  end

  def test_expand_path_from_base_rio
    @tdir.chdir do
      srel = 'groovy'
      sbase = '/tmp'
      rel = rio(srel)
      base = rio(sbase)
      exp = File.expand_path(srel,sbase)
      ans = rel.expand_path(base)
      assert_kind_of(RIO::Rio,ans)
      assert_equal(exp,ans)
    end
  end

  def test_expand_path_from_base_string
    @tdir.chdir do
      srel = 'groovy'
      sbase = '/tmp'
      rel = rio(srel)
      base = rio(sbase)
      exp = File.expand_path(srel,sbase)
      ans = rel.expand_path(sbase)
      assert_kind_of(RIO::Rio,ans)
      assert_equal(exp,ans)
    end
  end

  def test_expand_path_from_tilde
    @tdir.chdir do
      srel = 'groovy'
      sbase = '~'
      rel = rio(srel)
      base = rio(sbase)
      exp = File.expand_path(srel,sbase)
      ans = rel.expand_path(sbase)
      assert_kind_of(RIO::Rio,ans)
      assert_equal(exp,ans)
    end
  end




end
