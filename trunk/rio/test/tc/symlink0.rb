#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end

require 'rio'
require 'test/unit'
require 'test/unit/testsuite'

class TC_RIO_symlink0 < Test::Unit::TestCase
  require 'extensions/symbol'
  def assert!(a,msg="negative assertion")
    assert((!(a)),msg)
  end
  def smap(a) a.map( &:to_s ) end
  def tdir() rio(%w/qp symlink0/) end
  def mkafile(*args)
    file = rio(*args)
    file < (0..1).map { |i| "L#{i}:#{file.to_s}\n" }
    file
  end
  def setup
    #$trace_states = true
    @cwd = ::Dir.getwd
    tdir.mkpath.chdir
  end
  def teardown
    ::Dir.chdir @cwd
  end
  def check_link(lnk,dst)
    assert(lnk.symlink?, "symlink?")
    assert_equal('link',lnk.ftype)
    assert_equal(dst.exist?,lnk.exist?)
    if dst.exist?
      assert_equal(dst.contents,lnk.contents)
    end
  end
  def compare_links(exp,ans)
    assert_equal(exp.exist?,ans.exist?)
    assert_equal(exp.symlink?,ans.symlink?)
    assert_equal(exp.ftype,ans.ftype)
    assert_equal(exp.readlink.to_s,ans.readlink.to_s)
  end
  def test_delete
    rio('delete').delete!.mkpath.chdir

    file = mkafile('f0')
    link = rio('l0')
    file.symlink(link)

    assert(file.exist?)
    assert(link.exist?)
    assert(link.symlink?)

    link.delete
    assert(file.file?,"deleted link, file still exists")
    assert!(link.exist?,"link is deleted")
    assert!(link.symlink?,"link is gone")
    
    file.symlink(link)
    assert(file.file?,"file exists")
    assert(link.exist?,"link exists")
    assert(link.symlink?,"link is a symlink")

    file.delete
    assert!(file.exist?,"file deleted")
    assert!(link.exist?,"file deleted, link.exist? returns false")
    assert(link.symlink?,"file deleted, link is a symlink")

    link.touch
    assert(file.exist?,"link.touch creates a file")
    assert(file.file?,"link.touch creates a file")

    file.delete
    assert!(file.exist?,"file deleted")
    assert!(link.exist?,"file deleted, link.exist? returns false")
    assert(link.symlink?,"file deleted, link is a symlink")

    link.mkdir
    assert(file.exist?,"link.touch creates a directory")
    assert(file.directory?,"link.touch creates a directory")
    

    rio('..').chdir
  end
  def test_create
    rio('create').delete!.mkpath.chdir

    file = mkafile('f0')
    link = rio('l0')
    file.symlink(link)

    assert(file.exist?)
    assert(link.exist?)
    assert(link.symlink?)
    file.delete
    assert!(file.exist?)
    assert!(link.exist?)
    assert(link.symlink?)

    begin
      afile = rio('fruby')
      alink = rio('alink')
      
      ::FileUtils.touch(afile.to_s)
      assert(afile.exist?)
      assert(afile.file?)
      
      ::File.symlink(afile.to_s,alink.delete.to_s)
      check_link(alink,afile)
      assert(afile.file?)
      assert(alink.exist?)
      assert(alink.symlink?)
      assert(alink.file?)
      
      ::File.delete(afile.to_s)
      assert!(afile.exist?)
      assert!(alink.exist?)
      assert!(alink.file?)
      assert(alink.symlink?)
      
      ::FileUtils.touch(alink)
      assert(afile.file?,"created a file via a symlink")
      assert(alink.exist?,"created a file via a symlink, link exists")
      assert(alink.symlink?,"created a file via a symlink, link is a symlink")
      assert(alink.file?,"created a file via a symlink, link is a file")

      ::File.delete(afile.to_s)
      assert!(afile.exist?)
      assert(alink.symlink?)
      
      rlink = ::File.readlink(alink.to_s)
      assert_equal(afile.to_s,rlink.to_s)

      ::FileUtils.touch(rlink)
      assert(afile.file?,"created a file via a readlink/symlink")
      assert(alink.exist?,"created a file via a readlink/symlink, link exists")
      assert(alink.symlink?,"created a file via a readlink/symlink, link is a symlink")
      assert(alink.file?,"created a file via a readlink/symlink, link is a file")
    end

    begin
      adir = rio('druby')
      alink = rio('ldruby')
      
      ::Dir.mkdir(adir.to_s)
      assert(adir.exist?)
      assert(adir.dir?)
      
      ::File.symlink(adir.to_s,alink.delete.to_s)
      
      begin
        assert(adir.dir?)
        assert(alink.exist?)
        assert(alink.symlink?)
        assert(alink.dir?)
        
        assert_raise(Errno::EEXIST) { 
          ::Dir.mkdir(alink.to_s) 
        }
      end

      ::Dir.delete(adir.to_s)

      begin
        assert!(adir.exist?)
        assert!(alink.exist?)
        assert!(alink.dir?)
        assert(alink.symlink?)
        
        assert_raise(Errno::EEXIST) { 
          ::Dir.mkdir(alink.to_s) 
        }
      end

      begin
        assert!(adir.exist?)
        assert!(alink.exist?)
        assert!(alink.dir?)
        assert(alink.symlink?)
        
        rlink = ::File.readlink(alink.to_s)
        assert_equal(adir.to_s,rlink.to_s)
        
        ::Dir.mkdir(rlink)
        assert(adir.dir?,"created a dir via a readlink/symlink")
        assert(alink.exist?,"created a dir via a readlink/symlink, link exists")
        assert(alink.symlink?,"created a dir via a readlink/symlink, link is a symlink")
        assert(alink.dir?,"created a dir via a readlink/symlink, link is a file")
      end

    end

    begin
      adir = rio('drio')
      alink = rio('ldrio')
      
      adir.mkdir
      assert(adir.exist?)
      assert(adir.dir?)
      
      adir.symlink(alink.delete)
      
      begin
        assert(adir.dir?)
        assert(alink.exist?)
        assert(alink.symlink?)
        assert(alink.dir?)
        
        assert_nothing_raised(Errno::EEXIST) { 
          adir.mkdir
        }
      end

      adir.delete

      begin
        assert!(adir.exist?)
        assert!(alink.exist?)
        assert!(alink.dir?)
        assert(alink.symlink?)
        #$trace_states = true
        assert_nothing_raised(Errno::EEXIST) { 
          alink.mkdir
        }
        #$trace_states = false
        assert(adir.dir?,"created a dir via a symlink")
        assert(alink.exist?,"created a dir via a symlink, link exists")
        assert(alink.symlink?,"created a dir via a symlink, link is a symlink")
        assert(alink.dir?,"created a dir via a symlink, link is a directory")
        
      end

      adir.delete
      
      begin
        assert!(adir.exist?)
        assert!(alink.exist?)
        assert!(alink.dir?)
        assert(alink.symlink?)
        
        rlink = alink.readlink
        assert_equal(adir.to_s,rlink.to_s)
        
        rlink.mkdir
        assert(adir.dir?,"created a dir via a readlink/symlink")
        assert(alink.exist?,"created a dir via a readlink/symlink, link exists")
        assert(alink.symlink?,"created a dir via a readlink/symlink, link is a symlink")
        assert(alink.dir?,"created a dir via a readlink/symlink, link is a directory")
      end

    end

    begin
      afile = rio('frio')
      alink = rio('lrio')
      
      afile.touch
      assert(afile.exist?)
      assert(afile.file?)
      
      afile.symlink(alink.delete)
      check_link(alink,afile)
      assert(afile.file?)
      assert(alink.exist?)
      assert(alink.symlink?)
      assert(alink.file?)
      
      afile.delete
      assert!(afile.exist?)
      assert!(alink.exist?)
      assert!(alink.file?)
      assert(alink.symlink?)
      
      alink.touch
      assert(afile.file?,"created a file via a symlink")
      assert(alink.exist?,"created a file via a symlink, link exists")
      assert(alink.symlink?,"created a file via a symlink, link is a symlink")
      assert(alink.file?,"created a file via a symlink, link is a file")

      afile.delete
      assert!(afile.exist?)
      assert(alink.symlink?)
      
      rlink = alink.readlink
      assert_equal(afile.to_s,rlink.to_s)

      rlink.touch
      assert(afile.file?,"created a file via a readlink/symlink")
      assert(alink.exist?,"created a file via a readlink/symlink, link exists")
      assert(alink.symlink?,"created a file via a readlink/symlink, link is a symlink")
      assert(alink.file?,"created a file via a readlink/symlink, link is a file")
    end

    rio('..').chdir
  end
end
