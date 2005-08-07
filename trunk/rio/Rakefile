#--
# =============================================================================== 
# Copyright (c) 2005, Christopher Kleckner
# All rights reserved
#
# This file is part of the Rio library for ruby.
#
# Rio is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Rio is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Rio; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
# =============================================================================== 
#
# To create the documentation for Rio run the command
#   rake rdoc
# from the distribution directory.
#++

begin
  require 'rubygems'
  require 'rake/gempackagetask'
rescue Exception
end

require 'rake/clean'
require 'rake/packagetask'
require 'rake/rdoctask'
require 'rake/testtask'

# General actions  ##############################################################

$:.push 'lib'
require 'rio/doc'

SVN_REPOSITORY_URL = 'file:///loc/svn/'
 
SRC_FILES = FileList['lib/**/*.rb']
DOC_FILES = FileList['README','lib/rio.rb','lib/rio/doc/*.rb',
                     'lib/rio/if/*.rb','lib/rio/kernel.rb','lib/rio/constructor.rb']
XMP_FILES = FileList['ex/*']

module PKG
  NAME = "rio"
  TITLE = RIO::TITLE
  VERSION = RIO::VERSION
  FULLNAME = PKG::NAME + "-" + PKG::VERSION
  SUMMARY = RIO::SUMMARY
  DESCRIPTION = RIO::DESCRIPTION
  FILES = FileList.new(['setup.rb', 'RUNME.1st.rb', 'COPYING', 'Rakefile', 'ChangeLog', 'VERSION', 
                        'test/**/*.rb','doc/**/*'] + SRC_FILES.to_a + DOC_FILES.to_a + XMP_FILES.to_a
                       ) do |fl|
    fl.exclude( /\bsvn\b/ )
    fl.exclude( 'test/qp' )
    fl.exclude( 'test/coverage' )
#    fl.exclude( 'doc/rdoc' )
  end
  OUT_DIR = 'pkg'
  OUT_FILES = %w[.gem .tar.gz .zip].map { |ex| OUT_DIR + '/' + FULLNAME + ex }
end
ZIP_DIR = "/zip/ruby/rio"


# The default task is run if rake is given no explicit arguments.

desc "Default Task"
task :default => :rdoc


# End user tasks ################################################################

desc "Prepares for installation"
task :prepare do
  ruby "setup.rb config"
  ruby "setup.rb setup"
end


desc "Installs the package #{PKG::NAME}"
task :install => [:prepare] do
  ruby "setup.rb install"
end


task :clean do
  ruby "setup.rb clean"
end


CLOBBER << "doc/rdoc"
desc "Builds the documentation"
task :doc => [:rdoc] do
    puts "\nGenerating online documentation..."
#    ruby %{-I../lib ../bin/webgen -V 2 }
end

RDOC_OPTIONS = ['--line-numbers', '-m RIO::Doc::SYNOPSIS' ]
rd = Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'doc/rdoc'
  rdoc.title    = PKG::TITLE
  rdoc.options = RDOC_OPTIONS
  DOC_FILES.to_a.each do |glb|
    rdoc.rdoc_files.include( glb )
  end
  rdoc.template = 'doc/generators/template/html/rio.rb'
end

CLOBBER << "test/rio.log"
task :test do |t|
  chdir 'test' do
    ruby "-I../lib -I. runtests.rb"
  end
end

#task :package => [:gen_files] do |var|
#  require 'rio/kernel'
#  rio(ZIP_DIR) << rio('pkg').files['*.tgz','*.tar.gz','*.zip','*.gem']
#end
task :ziparc do |var|
  require 'rio/kernel'
  #$trace_states = true
  rio(ZIP_DIR) < rio('pkg').files['*.tgz','*.tar.gz','*.zip','*.gem']
end

task :gen_changelog do
  sh "svn log -r HEAD:1 -v > ChangeLog"
end

task :gen_version do
  puts "Generating VERSION file"
  File.open( 'VERSION', 'w+' ) do |file| file.write( PKG::VERSION + "\n" ) end
end


#task :gen_files => [:gen_changelog, :gen_version, :gen_installrb]
#CLOBBER << "ChangeLog" << "VERSION" << "install.rb"

task :gen_files => [:gen_changelog, :gen_version]
CLOBBER << "ChangeLog" << "VERSION" 
task :no_old_pkg do
  unless Dir["pkg/#{PKG::FULLNAME}*"].empty?
    $stderr.puts("packages for version #{PKG::VERSION} exist!")
    $stderr.puts("Either delete them, or change the version number.")
    exit(-1)
  end
end

task :package => [:no_old_pkg, :gen_files]
PKG::OUT_FILES.each do |f|
  file f => [:package]
end

Rake::PackageTask.new( PKG::NAME, PKG::VERSION ) do |p|
  p.need_tar_gz = true
  p.need_zip = true
  p.package_files = PKG::FILES
end

desc "Make a new release (test,package,svn_version)"
task :release => [:test, :clobber, :rdoc , :package, :svn_version, :ziparc] do
  

end
desc "Save the current code as a new svn version"
task :svn_version do
  require 'rio'
  repos = rio(SVN_REPOSITORY_URL)
  proju = rio(repos,PKG::NAME,'trunk') 
  relu  = rio(repos,PKG::NAME,'tags','release-') + PKG::VERSION 
  relo =`svn list #{relu.to_url}`
  if relo.size > 0
    $stderr.puts "Release #{relu.to_url} exists!"
    exit(-1)
  end
  msg = "Release #{PKG::VERSION} of #{PKG::NAME}"
  cmd = sprintf('svn copy %s %s -m "%s"',proju.to_url, relu.to_url, msg)
  sh cmd
end

desc "Commit the current code to svn"
task :svn_commit do
  require 'rio'
  msg = rio(?-).print("Comment: ").chomp.gets
  cmd = sprintf('svn commit -m "%s"', msg)
  sh cmd
end

if !defined? Gem
  puts "Package Target requires RubyGEMs"
else
  spec = Gem::Specification.new do |s|

    #### Basic information

    s.name = PKG::NAME
    s.version = PKG::VERSION
    s.summary = PKG::SUMMARY
    s.description = PKG::DESCRIPTION

    #### Dependencies, requirements and files

    s.files = PKG::FILES.to_a
    s.add_dependency( 'extensions', '>= 0.6.0' )

    s.require_path = 'lib'
    s.autorequire = 'rio'

    #### Documentation

    s.has_rdoc = true
    #s.extra_rdoc_files = ['doc/generators/template/html/rio.rb']
    s.rdoc_options << RDOC_OPTIONS 

    #### Author and project details

    s.author = "Christopher Kleckner"
    s.email = "rio4ruby@rubyforge.org"
    s.homepage = "rio.rubyforge.org"
    s.rubyforge_project = "rio"
  end

  Rake::GemPackageTask.new( spec ) do |pkg|
    pkg.need_zip = true
    pkg.need_tar_gz = true
  end

end

=begin
desc "Creates a tag in the repository"
task :tag do
  repositoryPath = File.dirname( $1 ) if `svn info` =~ /^URL: (.*)$/
  fail "Tag already created in repository " if /#{PKG::NAME}/ =~ `svn ls #{repositoryPath}/versions`
  sh "svn cp -m 'Created version #{PKG::NAME}' #{repositoryPath}/trunk #{repositoryPath}/versions/#{PKG::NAME}"
end
=end

desc "Upload documentation to homepage"
task :uploaddoc => [:rdoc] do
  Dir.chdir('doc/rdoc')
  puts
  puts "rio4ruby@rubyforge.org:/var/www/gforge-projects/#{PKG::NAME}/"
  sh "scp -r * rio4ruby@rubyforge.org:/var/www/gforge-projects/#{PKG::NAME}/"
end


# Misc tasks ###################################################################


def count_lines( filename )
  lines = 0
  codelines = 0
  open( filename ) do |f|
    f.each do |line|
      lines += 1
      next if line =~ /^\s*$/
      next if line =~ /^\s*#/
      codelines += 1
    end
  end
  [lines, codelines]
end


def show_line( msg, lines, loc )
  printf "%6s %6s   %s\n", lines.to_s, loc.to_s, msg
end


desc "Show statistics"
task :statistics do
  total_lines = 0
  total_code = 0
  show_line( "File Name", "Lines", "LOC" )
  SRC_FILES.each do |fn|
    lines, codelines = count_lines fn
    show_line( fn, lines, codelines )
    total_lines += lines
    total_code  += codelines
  end
  show_line( "Total", total_lines, total_code )
end


def run_testsite( arguments = '' )
  chdir 'test' do
    ruby "-I../lib -I. #{arguments} runtests.rb"
  end
#  ruby %{-I../lib #{arguments} ../bin/webgen -V 3 }
end


CLOBBER << "test/qp" << "qp"
desc "Build the test site"
task :testsite do
  run_testsite
end


CLOBBER  << "test/coverage"
desc "Run the code coverage tool on the testsite"
task :coverage do
  run_testsite '-rcoverage'
end
