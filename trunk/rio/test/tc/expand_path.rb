#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'test/unit'
require 'test/unit/testsuite'

class TC_RIO_expand_path < Test::Unit::TestCase
  require 'extensions/symbol'
  def initialize(*args)
    super
    @once = false
    @tdir = rio('qp/expand_path')
  end
  def assert!(a,msg="negative assertion")
    assert((!(a)),msg)
  end
  def smap(a) a.map( &:to_s ) end
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
      rel = rio('groovy')
      base = rio('/tmp')
      exp = rio(base,rel)
      ans = rel.expand_path(base)
      assert_kind_of(RIO::Rio,ans)
      assert_equal(exp,ans)
    end
  end

  def test_expand_path_from_base_string
    @tdir.chdir do
      rel = rio('groovy')
      base = rio('/tmp')
      exp = rio(base,rel)
      ans = rel.expand_path(base.to_s)
      assert_kind_of(RIO::Rio,ans)
      assert_equal(exp.to_s,ans.to_s)
    end
  end

  def test_expand_path_from_tilde
    return unless $supports_symlink
    @tdir.chdir do
      file = rio('groovy')
      rel = rio('~/' + file.to_s)
      home =  rio(RIO::RL.fs2url(ENV['HOME'].dup))
      exp = rio(home,file)
      ans = rel.expand_path
      assert_equal(exp.to_s,ans.to_s)
    end
  end

  def test_expand_path_from_tilde_user
    return unless $supports_symlink
    @tdir.chdir do
      home =  rio(RIO::RL.fs2url(ENV['HOME'].dup))
      user =  RIO::RL.fs2url(ENV['USER'].dup)
      file = rio('groovy')
      rel = rio('~' + user)
      exp = rio(home)
      ans = rel.expand_path
      assert_equal(exp.to_s,ans.to_s)
    end
  end


end
