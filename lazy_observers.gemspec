$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
name = "lazy_observers"
require "#{name}/version"

Gem::Specification.new name, LazyObservers::VERSION do |s|
  s.summary = "Makes Activerecord Observers lazy, do not load model on startup and only listen once a model got loaded."
  s.authors = ["Michael Grosser"]
  s.email = "michael@grosser.it"
  s.homepage = "http://github.com/grosser/#{name}"
  s.files = `git ls-files`.split("\n")
  s.license = 'MIT'
  s.add_runtime_dependency "activerecord"
end
