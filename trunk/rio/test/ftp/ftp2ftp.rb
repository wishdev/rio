#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'
require 'open-uri'
require 'ftp/test'

class TC_ftp2ftp < Test::RIO::TestCase
  @@once = false
  include Test::RIO::FTP::Const

  def self.once
    @@once = true
  end
  def setup
    super
    self.class.once unless @@once
    FS_RWROOT.entries { |ent| ent.delete! }
  end
  def test_cp_ro2rw_file1
    fname = 'f0'
    src = FTP_ROROOT/fname
    dst = FTP_RWROOT/fname
    dst < src
    assert_equal(src.contents,dst.contents)
  end
  def test_cp_ro2rw_file2
    fname = 'f0'
    src = FTP_ROROOT/fname
    dst = FTP_RWROOT
    dst < src
    fdst = dst/fname
    assert_equal(src.contents,fdst.contents)
  end
  def test_cp_ro2rw_dir
    fname = 'd0'
    src = FTP_ROROOT/fname
    dst = FTP_RWROOT
    dst < src
    fs_src = FS_ROROOT/fname
    fs_dst = FS_RWROOT/fname
    assert_rios_equal(fs_src,fs_dst)
  end


end
