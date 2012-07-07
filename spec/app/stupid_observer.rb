class StupidObserver < ActiveRecord::Observer
  lazy_observe Movie
end
