#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'test/unit'
require 'test/unit/testsuite'
require 'extensions/symbol'
require 'tc/testcase'
require 'tmpdir'

class TC_tempfile < Test::RIO::TestCase
  @@once = false
  def self.once
    @@once = true
  end
  def setup
    super
    self.class.once unless @@once
    @tmpdir = ::Dir::tmpdir
    @pfx = 'rio'
  end

  def pathinfo(ario)
    [:scheme,:opaque,:path,:fspath,:to_s,:to_url,:to_uri].each do |sym|
      puts "#{sym}: #{ario.__send__(sym)}"
    end
  end

  def test_io
    str = "Hello Tempfile"
    assert_equal(str,rio(??).puts(str).rewind.chomp.gets)
  end


end
