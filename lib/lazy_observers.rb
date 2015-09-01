require 'lazy_observers/version'
require 'active_record'
require 'lazy_observers/rails_observer'
require 'lazy_observers/railtie' if defined?(Rails)

module LazyObservers
  def self.observed_loaded(klass)
    class_name = klass.name
    loaded << [klass, class_name]
    observers.each do |observer, observed|
      connect!(observer.instance, klass) if observed.include?(class_name)
    end
    (on_load_callbacks[class_name]||[]).each{|block| block.call(klass) }
  end

  def self.observer_loaded(observer, classes)
    observers[observer] = classes
  end

  def self.observer_ready(observer, classes)
    loaded.each do |klass, name|
      connect!(observer, klass) if classes.include?(name)
    end
  end

  def self.on_load(observed, &block)
    on_load_callbacks[observed] ||= []
    on_load_callbacks[observed] << block
  end

  # to check you did not specify a class that does not exist
  def self.check_classes
    observers.values.flatten.uniq.each { |klass| klass.constantize }
  end

  def self.debug_active_record_loading
    ActiveRecord::Base.send(:extend, LazyObservers::InheritedDebugger)
  end

  def self.clear
    @observers = {}
    @loaded = []
  end

  private

  def self.on_load_callbacks
    @on_loads ||= {}
  end

  def self.observers
    @observers ||= {}
  end

  def self.loaded
    @loaded ||= []
  end

  def self.connect!(observer, klass)
    return if connected?(observer, klass)
    observer.observed_class_inherited(klass)
  end

  def self.connected?(observer, klass)
    @connected ||= {}
    return true if @connected[[observer, klass]]
    @connected[[observer, klass]] = true
    false
  end

  module InheritedNotifier
    def inherited(subclass)
      LazyObservers.observed_loaded subclass
      super
    end
  end

  module InheritedDebugger
    def inherited(subclass)
      $lazy_observers_inherited_counter ||= 0
      $lazy_observers_inherited_counter += 1
      puts "##{$lazy_observers_inherited_counter} #{subclass}"
      puts caller
      puts "-" * 72
      super
    end
  end
end

descendants = (ActiveRecord::VERSION::MAJOR > 2 ? :descendants : :subclasses)
ActiveRecord::Base.send(descendants).each{|klass| LazyObservers.observed_loaded(klass) }

ActiveRecord::Observer.class_eval do
  def self.lazy_observe(*classes)
    raise "pass class names, not classes or symbols!" unless classes.all?{|klass| klass.is_a?(String) }
    define_method(:observed_classes) { Set.new } # prevent default of PostObserver -> Post
    LazyObservers.observer_loaded self, classes
    define_method(:lazy_observed_classes) { Set.new(classes) }
  end

  # since AR uses respond_to? on the observer we need our observer to be fully defined before registering
  alias_method :initialize_without_lazy, :initialize
  def initialize
    initialize_without_lazy
    if defined?(lazy_observed_classes)
      LazyObservers.observer_ready(self, lazy_observed_classes)
    end
  end
end

ActiveRecord::Base.send(:extend, LazyObservers::InheritedNotifier)
