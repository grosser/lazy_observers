require File.expand_path("../database", __FILE__)

$LOAD_PATH.unshift 'lib'

# movie is used to test that things loaded before lazy_observers also gets observed
raise if defined?(Movie)
raise if defined?(LazyObservers.loaded)
require File.expand_path("../app/movie", __FILE__)
require "lazy_observers"
raise unless defined?(LazyObservers.loaded)
