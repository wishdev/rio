#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'

class TC_copy_from_http < Test::RIO::TestCase
  @@once = false
  def self.once
    @@once = true

    rio('d0').rmtree.mkpath
    rio('d1').rmtree.mkpath
    rio('d0/d2').rmtree.mkpath
    make_lines_file(1,'d0/f0')
    make_lines_file(2,'d0/f1')
    make_lines_file(3,'d1/f2')
    make_lines_file(4,'d1/f3')
    make_lines_file(5,'d0/d2/f4')
    make_lines_file(6,'d0/d2/f5')
  end
  def setup
    super
    self.class.once unless @@once

    @d0 = rio('d0')
    @d2 = rio('d0/d2')
  end
  def cptest(src)
    dst = rio('dst').delete!.mkpath
    dst < src.clone
    assert_rios_equal(src.clone,rio(dst,src.filename),"rio copy")
  end

  def test_uri_rio_to_file
    ario = rio('out').delete!.touch
    url = 'http://localhost/riotest/hw.html'
    urio = rio(url)
    ario < urio
    exp = urio.contents
    assert_equal(exp,ario.contents)
  end
  def test_uri_rio_to_dir
    ario = rio('ud').delete!.mkdir
    url = 'http://localhost/riotest/hw.html'
    urio = rio(url)
    #p "HERE1 urio=#{urio.rl.inspect}"
    #$trace_states = true
    ario < urio
    $trace_states = false
    #p "HERE2 urio=#{urio.rl.inspect}"
    drio = rio(ario,urio.filename)
    #p drio,urio,urio.filename
    assert(drio.file?)
    assert(urio.contents,drio.contents)
  end
  def test_uri_string_to_dir
    ario = rio('uds').delete!.mkdir
    url = 'http://localhost/riotest/hw.html'
    urio = rio(url)
    #$trace_states = true
    ario < url
    $trace_states = false
    drio = rio(ario,urio.filename)
    assert(drio.file?)
    assert(urio.contents,drio.contents)
  end
  def test_url_string_to_file
    ario = rio('out').delete!.touch
    url = 'http://localhost/riotest/hw.html'
    ario < url
    exp = url
    assert_equal(exp,ario.contents)
  end
  def test_url_array_to_file
    ario = rio('out').delete!.touch
    url = 'http://localhost/riotest/hw.html'
    ario < [url]
    exp = url
    assert_equal(exp,ario.contents)
  end
  def test_url_string_to_nonex
    ario = rio('outz').delete!
    url = 'http://localhost/riotest/hw.html'
    ario < url
    exp = url
    assert_equal(exp,ario.contents)
  end
end
