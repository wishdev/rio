#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require 'rio'
require 'test/unit'
class TC_RIO_copylines < Test::Unit::TestCase
  def test_copylines
    qp = RIO.rio('qp')
    rio(qp,'test_copylines').rmtree.mkpath.chdir {
      str = 'peter piper picked a peck of pickled peppers'
      words = str.split(/\s+/)
      line = words.map { |w| w+"\n" }.join('')
      src = rio('src').print!(line)
      
      #$trace_states = true
      out = rio('$')
      rio('src').chomp.lines(/^[^p]/) > out
      out.close
      $trace_states = false
      assert_equal('aof',out.contents)
      
      out < rio('src').lines(/^[^p]/)
      assert_equal("a\nof\n",out.contents)
      
      aout = Array.new
      rio('src').chomp.lines(1,4..6) > aout
      assert_equal(%w{piper peck of pickled},aout)
      
      out < rio('src').chomp.lines(0..1)
      assert_equal("peterpiper",out.contents)
      
      rio('src').chomp.lines(0..1) > aout
      assert_equal(%w{peter piper},aout)
      rio('src').chomp.lines(0..1) >> aout
      assert_equal(%w{peter piper peter piper},aout)
    }
  end
end
