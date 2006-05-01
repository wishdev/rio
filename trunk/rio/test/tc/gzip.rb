#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'

class TC_gzip < Test::RIO::TestCase
  @@once = false
  def self.once
    @@once = true
  end
  def setup()
    super
  end

  def test_string
    plain_string = "Hello World\n"

    gzip_string = ""
    ans_string = ""
    rio(?",plain_string) > rio(?",gzip_string).gzip
    rio(?",gzip_string).gzip > rio(?",ans_string)
    assert_equal(plain_string,ans_string)
    
    gzip_string = ""
    ans_string = ""
    rio(?",gzip_string).gzip < rio(?",plain_string)
    rio(?",ans_string) < rio(?",gzip_string).gzip
    assert_equal(plain_string,ans_string)
    
  end

  def test_string2
    str = "Hello World\n"
    src = rio(?").print!(str)
    ans = rio(?")

    ans.string = ""
    rio(?").gzip < src > ans
    assert_equal(str,ans.string)
    
    ans.string = ""
    src | rio(?").gzip | ans
    assert_equal(str,ans.string)
    
  end

  def test_file
    str = "Hello World\n"
    rio('src').print!(str)

    rio('src.gz').delete!
    rio('ans').delete!
    rio('src') > rio('src.gz').gzip
    rio('src.gz').gzip > rio('ans')
    assert_equal(str,rio('ans').contents)
    
    rio('src.gz').delete!
    rio('ans').delete!
    rio('src.gz').gzip < rio('src') 
    rio('ans') < rio('src.gz').gzip
    assert_equal(str,rio('ans').contents)
    
  end

  def test_tempfile
    str = "Hello World\n"
    src = rio(?").print!(str)
    ans = rio(?")

    tmp = rio(??).gzip
    tmp < src
    assert_equal(str,tmp.rewind.contents)
    tmp.rewind > ans
    assert_equal(str,ans.contents)
  end


end
