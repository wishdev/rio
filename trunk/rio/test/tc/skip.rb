#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'

class TC_skip < Test::RIO::TestCase
  @@once = false
  def self.once
    @@once = true
    rio('d0').rmtree.mkpath.chdir {
      rio('f1') < (0..1).map { |i| "L#{i}:d0/f1\n" }
      rio('f2') < (0..1).map { |i| "L#{i}:d0/f2\n" }
      rio('g1') < (0..1).map { |i| "L#{i}:d0/g1\n" }
      rio('g2') < (0..1).map { |i| "L#{i}:d0/g2\n" }
      rio('x1').symlink('n1')
      rio('x2').symlink('n2')
      rio('f1').symlink('l1')
      rio('f2').symlink('l2')
      rio('d1').symlink('c1')
      rio('d2').symlink('c2')
    }
  end
  def setup
    super
    self.class.once unless @@once
    @d0 = rio('d0')
  end

  def test_prefix_files
    exprio = rio(@d0).skipfiles(/1/)
    ansrio = rio(@d0).skip.files(/1/)
    assert_equal(smap(exprio[]),smap(ansrio[]))
  end
  def test_prefix_dirs
    exprio = rio(@d0).skipdirs(/1/)
    ansrio = rio(@d0).skip.dirs(/1/)
    assert_equal(exprio[],ansrio[])
  end
  def test_prefix_entries
    exprio = rio(@d0).skipentries(/1/)
    ansrio = rio(@d0).skip.entries(/1/)
    assert_equal(exprio[],ansrio[])
  end
  def test_prefix_alone
    exprio = rio(@d0).skipentries(/1/)
    ansrio = rio(@d0).skip(/1/)
    assert_equal(exprio[],ansrio[])
  end
end
