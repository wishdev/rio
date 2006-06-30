$:.unshift 'doc/patched_rdoc'
require 'rdoc/generators/html_generator'
$:.unshift 'lib'
require 'rubygems'
require 'rio'
require 'rio/doc'

module PKG
  NAME = "rio"
  TITLE = RIO::TITLE
  VERSION = RIO::VERSION
  FULLNAME = PKG::NAME + "-" + PKG::VERSION
  SUMMARY = RIO::SUMMARY
  DESCRIPTION = RIO::DESCRIPTION
  SRC_FILES = rio('lib').all.files['*.rb']
  DOC_FILES = rio('.').files['README','lib/rio.rb','lib/rio/doc/*.rb',
                             'lib/rio/if/*.rb','lib/rio/kernel.rb','lib/rio/constructor.rb']
  XMP_FILES = rio('.').files['ex/*']
  MSC_FILES = rio('.').files['setup.rb', 'build_doc.rb', 'COPYING', 'Rakefile', 'ChangeLog', 'VERSION']
  D_FILES = rio('doc').norecurse('.svn','CVS','rdoc').all.files[]
  C_FILES = rio('doc/patched_rdoc').all.files['*.rb']
  T_FILES = rio('test').all.norecurse('qp').files['*.rb']

  FILES = SRC_FILES+DOC_FILES+XMP_FILES+MSC_FILES+D_FILES+T_FILES+C_FILES

  OUT_DIR = 'pkg'
  OUT_FILES = %w[.gem .tar.gz .zip].map { |ex| OUT_DIR + '/' + FULLNAME + ex }
end

spec = Gem::Specification.new do |s|
  s.name = PKG::NAME
  s.version = PKG::VERSION
  s.author = "Christopher Kleckner"
  s.email = "rio4ruby@rubyforge.org"
  s.homepage = "http://rio.rubyforge.org/"
  s.rubyforge_project = "rio"

  s.platform = Gem::Platform::RUBY
  s.summary = PKG::SUMMARY
  s.files = PKG::FILES.map { |rf| rf.to_s }
          #s.add_dependency( 'extensions', '>= 0.6.0' )

  s.require_path = 'lib'
  s.require_paths << 'doc/patched_rdoc'
  s.autorequire = 'rio'

  s.has_rdoc = true

  RDOC_OPTIONS = ['--line-numbers','-mRIO::Doc::SYNOPSIS','-Tdoc/generators/template/html/rio.rb']
  s.rdoc_options << RDOC_OPTIONS 
end

if $0==__FILE__
  Gem::manage_gems
  Gem::Builder.new(spec).build
end

