#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'

class TC_skiplines < Test::RIO::TestCase
  @@once = false
  N_LINES = 4
  def self.once
    @@once = true
    rio('f1') < (0...N_LINES).map { |i| "L#{i}:f1\n" }
    rio('f2') < (0...N_LINES).map { |i| "L#{i}:f2\n" }
    rio('g1') < (0...N_LINES).map { |i| "L#{i}:g1\n" }
    rio('g2') < (0...N_LINES).map { |i| "L#{i}:g2\n" }
  end
  def setup
    super
    self.class.once unless @@once
    
  end

  def test_prefix_lines
#    exprio = rio(@d0).skipfiles(/1/)
#    ansrio = rio(@d0).skip.files(/1/)
    r = rio('f1').skip.lines(1)
#    p r.cx
#    p r.to_a
#    assert_equal(smap(exprio[]),smap(ansrio[]))
  end
  def test_skip_param
#    exprio = rio(@d0).skipfiles(/1/)
#    ansrio = rio(@d0).skip.files(/1/)
    r = rio('f1').lines(/^L/).skip(1..2)
#    p r.to_a
#    assert_equal(smap(exprio[]),smap(ansrio[]))
  end

end
