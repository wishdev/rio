#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'tc/testcase'
require 'open-uri'
require 'ftp/testdef'

class TC_ftp_anon_misc < Test::RIO::TestCase
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

  def test_dir
    ftproot = rio(FTPROOT)
    ftproot.chdir
    assert_equal('/',ftproot.pwd)
    assert_equal(ftproot,ftproot.cwd)

    rwdir = rio(FTP_RWROOT).chdir
    assert_equal(FTP_RWROOT,rwdir.cwd)
  end
  def test_mkdir
    rwdir = rio(FTP_RWROOT).chdir
    assert_equal(FTP_RWROOT.to_s,rwdir.cwd.to_s)
    rio(rwdir,'dir0').mkdir
    assert_equal(smap([FTP_RWROOT/'dir0']),smap(FTP_RWROOT.entries[/^dir/]))
  end

end
