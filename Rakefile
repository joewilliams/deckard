require 'rubygems'
require 'rake/gempackagetask'
require 'rake/rdoctask'

spec = Gem::Specification.new do |s|
  s.name = "deckard"
  s.version = "0.5.7"
  s.author = "joe williams"
  s.email = "joe@joetify.com"
  s.homepage = "http://github.com/joewilliams/deckard"
  s.platform = Gem::Platform::RUBY
  s.summary = "a monitoring system built on couchdb"
  s.files = FileList["{bin,lib,config}/**/*"].to_a
  s.require_path = "lib"
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
  %w{mixlib-config mixlib-log tmail json fog notifo}.each { |gem| s.add_dependency gem }
  s.add_dependency("rest-client", "= 1.3.0")
  s.bindir = "bin"
  s.executables = %w( deckard )
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

Rake::RDocTask.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
end
