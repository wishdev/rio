#!/usr/local/bin/ruby
if $0 == __FILE__
  Dir.chdir File.dirname(__FILE__)+'/../'
  $:.unshift File.expand_path('../lib/')
end
require 'rio'
require 'test/unit'
require 'test/unit/testsuite'

class TC_RIO_methods < Test::Unit::TestCase
  def assert!(a,msg="negative assertion")
    assert((!(a)),msg)
  end

  def check_clone(ios)
    oexp = []
    cexp = []

    oexp << ios.gets
    ioc = ios.clone

    cexp << ioc.gets
    oexp << ios.gets
    until ioc.eof?
      cexp << ioc.gets
    end

    until ios.eof?
      oexp << ios.gets
    end
    return ioc,oexp,cexp
  end

  def check_dup(ios)
    oexp = []
    cexp = []

    oexp << ios.gets
    ioc = ios.dup
    assert_not_nil(ioc,"dup returns nil")
    cexp << ioc.gets
    oexp << ios.gets
    until ioc.eof?
      cexp << ioc.gets
    end

    until ios.eof?
      oexp << ios.gets
    end
    return ioc,oexp,cexp
  end

  def check_clone_close(ios,ioc)
    assert!(ios.closed?,"original not closed")
    assert!(ioc.closed?,"clone not closed")
    ioc.close
    assert(ioc.closed?,"clone closed?")
    assert!(ios.closed?," orignal still not closed?")
    ios.close
    assert(ios.closed?,"now original closed")
  end

  def check_dup_close(ios,ioc)
    assert!(ios.closed?,"original not closed")
    assert(ioc.closed?,"dup closed")
    ios.close
    assert(ios.closed?,"now original closed")
  end
  def setup
    @cwd = rio(::Dir.getwd)
    @dir = rio('qp/methods')
#    $trace_states = true
    @dir.mkpath.chdir
    @lines = (0..5).map { |n| "Line#{n}" }
    @chlines = @lines.map(&:chomp)
    ::File.open('lines','w') do |f|
      @lines.each do |li|
        f.puts(li)
      end
    end
    @lines = rio('lines').to_a
  end
  def teardown
    @cwd.chdir
  end

  def test_clone_like_IO

    ios = ::File.open('lines')
    ioc,oexp,cexp = check_clone(ios)
    check_clone_close(ios,ioc)
    ioc.close unless ioc.closed?
    ios.close unless ios.closed?

    ario = rio('lines').nocloseoneof
    crio,oans,cans = check_clone(ario)
    assert_equal(oexp,oans)
    assert_equal(cexp,cans)
    check_clone_close(ario,crio)

  end

  def test_dup_not_like_IO

    ios = ::File.open('lines')
    ioc,oexp,cexp = check_dup(ios)
    check_clone_close(ios,ioc)
    ario = rio('lines').nocloseoneof
    crio,oans,cans = check_dup(ario)
    assert_equal(@lines,oans)
    assert_equal(@lines,cans)
    check_dup_close(ario,crio)

  end


  def ztest_clone_own_context

    assert(rio.closeoncopy?,"closeoncopy is on")
    assert!(rio.nocloseoncopy.closeoncopy?,"nocloseoncopy is off")
    assert!(rio.chomp?,"chomp is off")
    chomper = rio.chomp
    assert(chomper.chomp?,"chomp is on")
    cl = chomper.clone
    assert(cl.chomp?,"cloned chomp is on")
    cl.nochomp
    assert!(cl.chomp?,"cloned chomp is off")
    assert(chomper.chomp?,"original chomp is still on")

    chomper.join!('lines')
    ans = chomper.to_a
    assert_equal(@chlines,ans)

    cl.join!('lines')
    ans = cl.to_a
    assert_equal(@lines,ans)

  end
  def ztest_clone_read_ruby

    #$trace_states = true
    afile = ::File.open('lines')
    arec = afile.gets
    assert_equal(@lines[0],arec)
    cfile = afile.dup
    #p "POS: a(#{afile.pos}) c(#{cfile.pos})"
    crec = cfile.gets
    #p "crec=#{crec} POS: a(#{afile.pos}) cfile(#{cfile.pos})"
    afile.close
  end
  def test_clone_read
    return unless $supports_symlink
    #$trace_states = true
    ario = rio('lines')
    arec = ario.getrec
    assert_equal(@lines[0],arec)
    #$trace_states = true
    crio = ario.clone.chomp
    #p "POS: ario(#{ario.pos}) crio(#{crio.pos})"
    crec = crio.getrec
    #p "crec=#{crec} POS: ario(#{ario.pos}) crio(#{crio.pos})"

    assert_equal(@chlines[1],crec)

    arec = ario.getrec
    #$trace_states = false
    assert_equal(@lines[1],arec)
    cremaining = crio.to_a

    assert_equal(@chlines[2...@lines.size],cremaining)
    #p "#{crio.eof?} #{crio.closed?}"
    assert(crio.eof?,"clone eof?") unless crio.closed?
    assert(crio.closed?,"clone closed?")

    assert!(ario.eof?,"orignal eof?") unless ario.closed?
    assert!(ario.closed?,"original closed?")

    aremaining = ario.readlines
    assert_equal(@lines[2...@lines.size],aremaining)
    assert(ario.eof?,"orignal eof?") unless ario.closed?
    assert(ario.closed?,"original closed?")

  end

end
