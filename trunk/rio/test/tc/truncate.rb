#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require 'rio'
require 'tc/testcase'
require 'pp'

class TC_truncate < Test::RIO::TestCase
  @@once = false
  def self.once
    @@once = true

  end

  def setup
    super
    self.class.once unless @@once

  end

  def setup_files(tag)
    str = "1234567890"
    fnbase = "out." + tag
    fnruby = fnbase + '.ruby'
    rio(fnruby).print!(str)
    fnrio = fnbase + '.rio'
    rio(fnrio).print!(str)
    [str,fnruby,fnrio]
  end

  def do_changesize(str,fnruby,fnrio,inc)
    n = str.size + inc
    File.truncate(fnruby,n)
    rio(fnrio).truncate(n)
    assert_equal(File.size(fnruby),rio(fnrio).size)
    assert_equal(n,rio(fnrio).size)

    fruby_contents = nil
    f = File.open(fnruby,'r') do |io|
      fruby_contents = io.read
    end
    assert_equal(fruby_contents, rio(fnrio).contents)
  end

  def test_setup
    str,fnruby,fnrio = setup_files('setup')

    assert_equal(File.size(fnruby),rio(fnrio).size)

    fruby_contents = nil
    f = File.open(fnruby,'r') do |io|
      fruby_contents = io.read
    end
    assert_equal(fruby_contents, rio(fnrio).contents)
  end

  def test_nochange
    str,fnruby,fnrio = setup_files('nochange')

    File.truncate(fnruby,str.size)
    rio(fnrio).truncate(str.size)
    assert_equal(File.size(fnruby),rio(fnrio).size)
  end

  def test_clear1
    str,fnrio1,fnrio2 = setup_files('clear1a')

    assert_equal(rio(fnrio1).truncate(0).size,rio(fnrio2).clear.size)
    str,fnrio1,fnrio2 = setup_files('clear1b')
    assert_equal(rio(fnrio1).truncate(0).contents,rio(fnrio2).clear.contents)
  end

  def test_clear2
    str,fnrio1,fnrio2 = setup_files('clear2a')

    assert_equal(rio(fnrio1).truncate.size,rio(fnrio2).clear.size)
    str,fnrio1,fnrio2 = setup_files('cleara')
    assert_equal(rio(fnrio1).truncate.contents,rio(fnrio2).clear.contents)
  end

  def test_clear3
    str,fnrio1,fnrio2 = setup_files('clear3a')

    assert_equal(0,rio(fnrio2).clear.size)

    str,fnrio1,fnrio2 = setup_files('clear3b')
    assert_equal("",rio(fnrio2).clear.contents)
  end

  def test_shorten
    str,fnruby,fnrio = setup_files('shorten')
    do_changesize(str,fnruby,fnrio,-1)
  end

  def test_lengthen
    str,fnruby,fnrio = setup_files('lengthen')
    do_changesize(str,fnruby,fnrio,1)
  end

  def test_shorten_to_zero
    str,fnruby,fnrio = setup_files('shorten_to_zero')
    do_changesize(str,fnruby,fnrio,-str.size)
  end

  def test_shorten_to_less_than_zero
    str,fnruby,fnrio = setup_files('shorten_to_less_than_zero')
    n = -1
    assert_raise Errno::EINVAL do
      File.truncate(fnruby,n)
    end
    assert_equal(str.size,File.size(fnruby))

    rio(fnrio).truncate(n)
    assert_equal(0,rio(fnrio).size)
    assert_equal("",rio(fnrio).contents)
    #do_changesize(str,fnruby,fnrio,-(str.size+1))
  end

  def test_nonexistent
    str,fnruby,fnrio = setup_files('nonexistent')
    rio(fnruby).rm
    assert!(rio(fnruby).exist?)
    assert_raise Errno::ENOENT do
      File.truncate(fnruby,0)
    end
    rio(fnrio).rm
    assert!(rio(fnrio).exist?)
    rio(fnrio).truncate(0)
    assert_equal(0,rio(fnrio).size)
    assert_equal("",rio(fnrio).contents)
  end



end
