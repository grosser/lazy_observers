class MovieObserver < ActiveRecord::Observer
  lazy_observe "Movie"

  def called
    @called ||= []
  end

  def after_update(*args)
    @called << [:after_update, args]
  end

  def after_save(*args)
    @called << [:after_update, args]
  end

  def after_create(*args)
    @called << [:after_create, args]
  end
end
