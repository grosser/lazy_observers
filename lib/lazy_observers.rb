require 'lazy_observers/version'
require 'active_record'
require 'active_record/observer'

module LazyObservers
  def self.register_observed(klass)
    loaded << klass
    observers.each do |observer, observed|
      connect!(observer, klass) if observed.include?(klass.name)
    end
  end

  def self.register_observer(observer, classes)
    observers[observer] = classes
    loaded.each do |klass|
      connect!(observer, klass) if classes.include?(klass.name)
    end
  end

  private

  def self.observers
    @observers ||= {}
  end

  def self.loaded
    @loaded ||= []
  end

  def self.connect!(observer, klass)
    observer.instance.observed_class_inherited(klass)
  end
end

ActiveRecord::Base.send(:subclasses).each{|klass| LazyObservers.register_observed(klass) }

ActiveRecord::Observer.class_eval do
  def self.lazy_observe(*classes)
    raise "pass class names, not classes or symbols!" unless classes.all?{|klass| klass.is_a?(String) }
    define_method(:observed_classes) { Set.new }
    LazyObservers.register_observer self, classes
  end
end

ActiveRecord::Base.class_eval do
  def self.inherited(subclass)
    LazyObservers.register_observed subclass
    super
  end
end
