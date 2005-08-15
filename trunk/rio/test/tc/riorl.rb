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

class TC_riorl < Test::RIO::TestCase
  @@once = false
  def self.once
    @@once = true
  end
  def setup
    super
    self.class.once unless @@once
    @tmpdir = "#{::Dir::tmpdir}"
    @tmppath = "#{@tmpdir}/rio"
  end

  def pathinfo(ario)
    h = {}
    [:scheme,:opaque,:path,:fspath,:to_s,:to_url,:to_uri].each do |sym|
      begin
        h[sym] = ario.__send__(sym)
      rescue
        h[sym] = 'error'
      end
    end
    h
  end
  def pinfo(fmt,pi)
    printf(fmt, pi[:scheme].inspect,pi[:opaque].inspect,pi[:path].inspect,
           pi[:fspath].inspect,pi[:to_s].inspect,pi[:to_url].inspect)
  end
  def mkrios1()
    rinfo = {
      ?- => ['stdio',"",nil,nil,"stdio:","stdio:"],
      ?= => ['stderr',"",nil,nil,"stderr:","stderr:"],
      ?" => ['strio',"",nil,nil,"strio:","strio:"],
      ?? => ['temp',@tmppath,nil,nil,"temp:#{@tmppath}","temp:#{@tmppath}"],
    }
    siopq = sprintf("0x%08x",$stdout.object_id)
    rinfo[?_] = ['sysio',siopq,nil,nil,"sysio:#{siopq}","sysio:#{siopq}"]
    rinfo[?`] = ['cmdio','echo%20x',nil,nil,'echo x','cmdio:echo%20x']
    rinfo[?#] = ['fd','1',nil,nil,'fd:1','fd:1']
    rios = {
      ?- => rio(?-),
      ?= => rio(?=),
      ?" => rio(?"),
      ?? => rio(??),
      ?_ => rio($stdout),
      ?` => rio(?`,'echo x'),
      ?# => rio(?#,1),
    }
    [rios,rinfo]
  end
  def mkrios2()
    rinfo = {
      ?- => ['stdout',/^$/,nil,nil,/^stdout:$/,/^stdout:$/],
      ?? => ['file',%r|//#{@tmppath}\d+\.\d+|,%r|#{@tmppath}\d+\.\d+|,%r|#{@tmppath}\d+\.\d+|,/#{@tmppath}\d+\.\d+/,/#{@tmppath}\d+\.\d+/],
    }
    siopq = sprintf("0x%08x",$stdout.object_id)
    rios = {
      ?- => rio(?-).print("."),
      ?? => rio(??).puts("hw"),
    }
    [rios,rinfo]
  end
  def test_specialpaths
    fmt = "%-12s %-12s %-8s %-8s %-20s %-20s\n"
    #printf(fmt,'scheme','opaque','path','fspath','to_s','url')
    rios,rinfo = mkrios1()
    rios.each do |k,r|
      #pinfo(fmt,pathinfo(r))
      assert_equal(r.scheme,rinfo[k][0])
      assert_equal(r.opaque,rinfo[k][1])
      assert_equal(r.path,rinfo[k][2])
      assert_equal(r.fspath,rinfo[k][3])
      assert_equal(r.to_s,rinfo[k][4])
      assert_equal(r.to_url,rinfo[k][5])
    end
  end

  def test_specialpaths_op
    fmt = "%-12s %-12s %-8s %-8s %-20s %-20s\n"
    #printf(fmt,'scheme','opaque','path','fspath','to_s','url')
    rios,rinfo = mkrios2()
    rios.each do |k,r|
      #pinfo(fmt,pathinfo(r))
      assert_equal(rinfo[k][0],r.scheme)
      assert(r.opaque =~ rinfo[k][1])
      assert(r.to_s =~ rinfo[k][4])
      assert(r.to_url =~ rinfo[k][5])
    end
    assert(rinfo[??][2] =~ rios[??].path)
    assert(rinfo[??][3] =~ rios[??].fspath)
  end
end
