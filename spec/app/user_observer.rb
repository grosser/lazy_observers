class UserObserver < ActiveRecord::Observer
  lazy_observe "User"
end
