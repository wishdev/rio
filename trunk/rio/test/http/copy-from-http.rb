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

  end
  def setup
    super
    self.class.once unless @@once
    
  end
  HWURL = 'http://localhost/riotest/hw.html'
  def cptest(src)
    dst = rio('dst').delete!.mkpath
    dst < src.clone
    assert_rios_equal(src.clone,rio(dst,src.filename),"rio copy")
  end

  def test_uri_rio_to_file
    ario = rio('outf').delete!.touch
    url = HWURL
    urio = rio(url)
    ario < urio
    exp = urio.contents
    assert_equal(exp,ario.contents)
  end
  def test_uri_rio_to_dir
    ario = rio('ud').delete!.mkdir
    url = HWURL
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
    url = HWURL
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
    url = HWURL
    ario < url
    exp = url
    assert_equal(exp,ario.contents)
  end
  def test_url_array_to_file
    ario = rio('out').delete!.touch
    url = HWURL
    ario < [url]
    exp = url
    assert_equal(exp,ario.contents)
  end
  def test_url_string_to_nonex
    ario = rio('outz').delete!
    url = HWURL
    ario < url
    exp = url
    assert_equal(exp,ario.contents)
  end
end
